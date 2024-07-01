`timescale 1ns / 1ps
//TODO

//6.01.2023


//TEKNOFEST ICIN YAPILACAKLAR
//resetleri aktif 0 yap
//Hazard detection yapinca aradaki komutu NOP yapmamiz gerekir mi?

`define DEBUG 1

module core(
   input clk_i,
   input rst_i,
   
   input instr_cache_blocking_n_i,
   input data_cache_blocking_n_i,
   
   input [31:2] instr_cache_instr_i,
   input [31:0] data_cache_data_i,
   
   output [31:2] instr_cache_address_o,
   output [31:2] data_cache_address_o,
   output [3:0] data_cache_write_en_o,
   output [31:0] data_cache_data_o,
   output data_cache_enabled_o
);
   
   //***********IF-ID STAGE VARIABLES************
   wire [31:2] pc_if_id_o; //ID asamasina giren PC olduugu icin PC_ID_O isimlend
   wire [31:2] instruction_if_id_o;

   wire [1:0] branch_jump_op_if_id_o;
   wire [2:0] imm_src_if_id_o;
      
   wire [4:0] rd_if_id_o  = instruction_if_id_o[11:7]; 
   wire [4:0] rs1_if_id_o = instruction_if_id_o[19:15]; 
   wire [4:0] rs2_if_id_o = instruction_if_id_o[24:20];
   wire [6:0] instruction_opcode_if_id_o = {instruction_if_id_o[6:2], 2'b11};
   wire [2:0] instruction_funct3_if_id_o = instruction_if_id_o[14:12];
   wire [6:0] instruction_funct7_if_id_o = instruction_if_id_o[31:25];
   wire [24:0] instruction_payload_if_id_o = instruction_if_id_o[31:7];
      
      
   //*******************ID-EX STAGE VARIABLES***********   
   wire [31:0] rs1_value_id_ex_o;
   
   wire [31:0] pc_id_ex_o; //pass PC to ID/EX stage

   wire [31:0] rs2_value_id_ex_o;

   wire [31:0] imm_value_id_ex_o;
   wire alu_op1_sel_id_ex_o;

   wire alu_op2_sel_id_ex_o;

   wire [1:0] wb_sel_id_ex_o;

   wire [4:0] rd_id_ex_o; //pass rd label for the writeback   
   wire [4:0] rs1_label_id_ex_o; //forwarding unit
   
   wire [4:0] rs2_label_id_ex_o;
   
   wire [2:0] funct3_id_ex_o;
   wire [6:0] funct7_id_ex_o;

   wire is_load_instr_id_ex_o;
   wire is_store_instr_id_ex_o;
   wire is_mret_id_ex_o;
   wire [1:0] branch_jump_op_id_ex_o;
   
   wire ID_exception_detected_id_ex_o;
   wire [3:0] exception_id_ex_o;
   wire CSR_en_id_ex_o;
   wire [1:0] CSR_op_id_ex_o;
   wire CSR_source_sel_id_ex_o;
   wire [3:0] ALU_op_id_ex_o;
   wire [4:0] BMU_op_id_ex_o;
   wire MDU_en_id_ex_o;
   wire [2:0] MDU_op_id_ex_o;
   wire [1:0] chip_select_id_ex_o;
   wire rs1_shift_sel_id_ex_o;
   wire rs2_negate_sel_id_ex_o;

   wire [1:0] mem_data_sel_id_ex_o;
   wire sets_reservation_id_ex_o;
   wire uses_reservation_id_ex_o;
   
   //*****************EX-MEM******************
   wire [31:2] branch_target;
   wire [31:0] alu_out_ex_mem_o;
   wire [4:0] rd_ex_mem_o;  
   wire [31:0] pc_ex_mem_o;  
   wire [1:0] wb_sel_ex_mem_o; // control signal to WB                              
   wire [31:0] imm_ex_mem_o;   
   wire [4:0] rs1_label_ex_mem_o;
   wire [4:0] rs2_label_ex_mem_o;   
   wire [31:0] rs2_ex_mem_o;
   wire branching;

   wire exception_detected_ex_mem_o;

   wire [1:0] mem_data_sel_ex_mem_o;
   wire sets_reservation_ex_mem_o;
   wire uses_reservation_ex_mem_o;
   
   wire [2:0] funct3_ex_mem_o;
   wire is_load_instr_ex_mem_o;
   wire is_store_instr_ex_mem_o;
   
   //    *********** MEM-WB STAGE *************** 
   wire [4:0] rd_mem_wb_o;  
   wire [31:0] alu_out_mem_wb_o;  
   wire [1:0] wb_sel_mem_wb_o; // control signal to write back to reg file (which value) 
   wire [31:0] rd_data_mem_wb_o; 
   wire [31:0] imm_mem_wb_o;
   wire [31:0] pc_mem_wb_o;
   wire is_load_instr_mem_wb_o; 
   wire [31:0] rs2_mem_wb_o;   
   wire [31:0] pc_mem_wb_o_4; 

   //************ stall signals *******************\\
   wire mul_stall;
   wire div_stall_core;
   reg data_cache_blocking_n_last;
   
   always @(posedge clk_i) begin
      data_cache_blocking_n_last <= data_cache_blocking_n_i;
   end

   wire load_stall;
   wire id_stall = load_stall | mul_stall | div_stall_core ;
   wire if_stall = load_stall | ~data_cache_blocking_n_last | ~data_cache_blocking_n_i | mul_stall | div_stall_core;

   wire [31:0] reg_wb_data_w;
   wire busy_w;

   //Uzantı destek bitleri (Forwarded)
   wire is_a_supported, is_b_supported, is_f_supported, is_m_supported;
   
   assign busy_w = ~data_cache_blocking_n_last | ~data_cache_blocking_n_i;

   instruction_fetch_stage u_if(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .cache_blocking_n_i(instr_cache_blocking_n_i),
      .cache_data_i(instr_cache_instr_i),
      .cache_address_o(instr_cache_address_o),

      .stall_i(if_stall),
      .branching_i(branching),
      .branch_target_i(branch_target),
      .instr_o(instruction_if_id_o),
      .branch_jump_op_o(branch_jump_op_if_id_o),
      .imm_src_o(imm_src_if_id_o),
      .pc_o(pc_if_id_o)
   );

   wire [6:2] opcode_id_ex_o; //TEMPORARY
   wire [31:2] u_id_pc_o;  
   assign pc_id_ex_o = {u_id_pc_o, 2'b00};   
   instruction_decode_stage u_id(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .instr_i(instruction_if_id_o),
      .branch_jump_op_i(branch_jump_op_if_id_o),
      .imm_src_i(imm_src_if_id_o),
      .busywait_i(busy_w),
      .branching_i(branching),
      .stall_id_i(id_stall),
      .load_stall_o(load_stall),
      .rd_label_i(rd_mem_wb_o),
      .rd_data_i(reg_wb_data_w),
      .pc_i(pc_if_id_o),
      .pc_o(u_id_pc_o),        
      .rs1_value_o(rs1_value_id_ex_o),
      .rs2_value_o(rs2_value_id_ex_o),
      .imm_value_o(imm_value_id_ex_o),
      .alu_op1_sel_o(alu_op1_sel_id_ex_o),
      .alu_op2_sel_o(alu_op2_sel_id_ex_o),
      .wb_sel_o(wb_sel_id_ex_o),
      .rd_o(rd_id_ex_o),
      .rs1_label_o(rs1_label_id_ex_o),
      .rs2_label_o(rs2_label_id_ex_o),
      .funct3_o(funct3_id_ex_o),
      .funct7_o(funct7_id_ex_o),
      .is_load_instr_o(is_load_instr_id_ex_o),
      .is_store_instr_o(is_store_instr_id_ex_o),
      .is_mret_o(is_mret_id_ex_o),
      .branch_jump_op_o(branch_jump_op_id_ex_o),

      .ID_exception_detected_o(ID_exception_detected_id_ex_o),
      .exception_o(exception_id_ex_o),
      .CSR_en_o(CSR_en_id_ex_o),
      .CSR_op_o(CSR_op_id_ex_o),
      .CSR_source_sel_o(CSR_source_sel_id_ex_o),
      .ALU_op_o(ALU_op_id_ex_o),
      .BMU_op_o(BMU_op_id_ex_o),
      .MDU_en_o(MDU_en_id_ex_o),
      .MDU_op_o(MDU_op_id_ex_o),
      .chip_select_o(chip_select_id_ex_o),
      .rs1_shift_sel_o(rs1_shift_sel_id_ex_o),
      .rs2_negate_sel_o(rs2_negate_sel_id_ex_o),

      .is_a_supported_i(is_a_supported),
      .is_b_supported_i(is_b_supported),
      .is_f_supported_i(is_f_supported),
      .is_m_supported_i(is_m_supported),

      .mem_data_sel_o(mem_data_sel_id_ex_o),
      .sets_reservation_o(sets_reservation_id_ex_o),
      .uses_reservation_o(uses_reservation_id_ex_o)
   );

   instruction_execution_stage u_ex(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .busywait(busy_w),
      .alu_out_ex_mem_o(alu_out_ex_mem_o),//internal
      
      .rd_ex_mem_i(rd_id_ex_o), //in_id nin cikisini ver buraya
      .rd_ex_mem_o(rd_ex_mem_o),
      
      
      .imm_ex_mem_i(imm_value_id_ex_o),
      .imm_ex_mem_o(imm_ex_mem_o),
      
      .pc_ex_mem_i(pc_id_ex_o),
      .pc_ex_mem_o(pc_ex_mem_o),
      
      .wb_sel_ex_mem_i(wb_sel_id_ex_o),
      .wb_sel_ex_mem_o(wb_sel_ex_mem_o),
      
      .rs1_label_ex_mem_i(rs1_label_id_ex_o), 
      .rs1_label_ex_mem_o(rs1_label_ex_mem_o),
      
      .rs2_label_ex_mem_i(rs2_label_id_ex_o),
      .rs2_label_ex_mem_o(rs2_label_ex_mem_o),
      
      .rs2_ex_mem_o(rs2_ex_mem_o),

      .funct3_ex_mem_i(funct3_id_ex_o),
      .funct3_ex_mem_o(funct3_ex_mem_o),
      
      .funct7_ex_mem_i(funct7_id_ex_o),
      
      .is_load_instr_ex_mem_i(is_load_instr_id_ex_o),
      .is_load_instr_ex_mem_o(is_load_instr_ex_mem_o),
      
      .is_store_instr_ex_mem_i(is_store_instr_id_ex_o), 
      .is_store_instr_ex_mem_o(is_store_instr_ex_mem_o),

      .is_mret_i(is_mret_id_ex_o),
      .branch_jump_op_i(branch_jump_op_id_ex_o),

      .branching_o(branching),
      .branch_target_o(branch_target),
      
      .rd_mem_wb_i(rd_mem_wb_o),
      .is_load_instr_mem_wb_i(is_load_instr_mem_wb_o),
      .rs1_value_ex_mem_i(rs1_value_id_ex_o),
      .rs2_value_ex_mem_i(rs2_value_id_ex_o),
      .alu_out_mem_wb_o(alu_out_mem_wb_o),
      .rd_data_mem_wb_o(rd_data_mem_wb_o),
      .alu_op1_sel_ex_mem_i(alu_op1_sel_id_ex_o),
      .alu_op2_sel_ex_mem_i(alu_op2_sel_id_ex_o),
      .mul_stall_o(mul_stall),
      .div_stall_o(div_stall_core),

      .ID_exception_detected_i(ID_exception_detected_id_ex_o),
      .exception_i(exception_id_ex_o),
      .CSR_en_i(CSR_en_id_ex_o),
      .CSR_op_i(CSR_op_id_ex_o),
      .CSR_source_sel_i(CSR_source_sel_id_ex_o),
      .ALU_op_i(ALU_op_id_ex_o),
      .BMU_op_i(BMU_op_id_ex_o),
      .MDU_en_i(MDU_en_id_ex_o),
      .MDU_op_i(MDU_op_id_ex_o),
      .chip_select_i(chip_select_id_ex_o),
      .rs1_shift_sel_i(rs1_shift_sel_id_ex_o),
      .rs2_negate_sel_i(rs2_negate_sel_id_ex_o),

      .is_a_supported_o(is_a_supported),
      .is_b_supported_o(is_b_supported),
      .is_f_supported_o(is_f_supported),
      .is_m_supported_o(is_m_supported),

      .exception_detected_o(exception_detected_ex_mem_o),

      .mem_data_sel_i(mem_data_sel_id_ex_o),
      .mem_data_sel_o(mem_data_sel_ex_mem_o),

      .sets_reservation_i(sets_reservation_id_ex_o),
      .sets_reservation_o(sets_reservation_ex_mem_o),

      .uses_reservation_i(uses_reservation_id_ex_o),
      .uses_reservation_o(uses_reservation_ex_mem_o)
   );
      

   memory_stage u_mem(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .busywait_i(busy_w),
      .data_cache_blocking_n_i(data_cache_blocking_n_i),
      
      .data_cache_data_i(data_cache_data_i),
      .funct3_i(funct3_ex_mem_o),
      .rd_label_i(rd_ex_mem_o),
      .alu_out_i(alu_out_ex_mem_o),
      .wb_sel_i(wb_sel_ex_mem_o),
      .imm_i(imm_ex_mem_o),
      .pc_i(pc_ex_mem_o),
      .is_load_instruction_i(is_load_instr_ex_mem_o),
      .is_store_instruction_i(is_store_instr_ex_mem_o),
      .rs2_data_i(rs2_ex_mem_o),
      
      .data_cache_data_o(data_cache_data_o),
      .data_cache_write_en_o(data_cache_write_en_o),
      .data_cache_address_o(data_cache_address_o),
      .data_cache_enabled_o(data_cache_enabled_o),
      .mem_data_o(rd_data_mem_wb_o),

      .rd_label_o(rd_mem_wb_o),
      .alu_out_o(alu_out_mem_wb_o),
      .wb_sel_o(wb_sel_mem_wb_o),
      .imm_o(imm_mem_wb_o),
      .pc_o(pc_mem_wb_o),
      .is_load_instruction_o(is_load_instr_mem_wb_o),
      .rs2_data_o(rs2_mem_wb_o),

      .exception_detected_i(exception_detected_ex_mem_o),

      .mem_data_sel_i(mem_data_sel_ex_mem_o),
      .sets_reservation_i(sets_reservation_ex_mem_o),
      .uses_reservation_i(uses_reservation_ex_mem_o)
   );

   pc_adder u_pc_adder1(
      .in_i(pc_mem_wb_o), //PC i 4 ile toplar
      .out_o(pc_mem_wb_o_4) // cunku son muxta PC+4 var, su ana kadar sadece PC i ilettik biz, 4 ile toplayip yollamamiz lazim.
   );

   mux_4x1 #(
   .DATA_WIDTH(32)
   ) writeback_mux (
   .in0(alu_out_mem_wb_o),
   .in1(rd_data_mem_wb_o),
   .in2(imm_mem_wb_o),
   .in3(pc_mem_wb_o_4),
   .select(wb_sel_mem_wb_o),    // Selection signal
   .out(reg_wb_data_w)          // Output of the MUX
   );

   `ifdef DEBUG
      localparam [31:0] NOP = 32'h13;
   
      wire [31:0] INSTRUCTION_IF = {instr_cache_instr_i, 2'b11};
      reg [31:0] INSTRUCTION_ID;
      reg [31:0] INSTRUCTION_EX;
      reg [31:0] INSTRUCTION_MEM;
      
      always @(posedge clk_i) begin
         if(branching) begin
            INSTRUCTION_ID <= NOP;
            INSTRUCTION_EX <= NOP;
            INSTRUCTION_MEM <= NOP;
         end else begin
            INSTRUCTION_ID <= instr_cache_blocking_n_i ? INSTRUCTION_IF : NOP;
            INSTRUCTION_EX <= INSTRUCTION_ID;
            INSTRUCTION_MEM <= INSTRUCTION_EX;
         end
      end
   `endif
endmodule
