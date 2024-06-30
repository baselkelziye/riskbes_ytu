`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2024 05:29:57 PM
// Design Name: 
// Module Name: instruction_execution_stage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module instruction_execution_stage(
   input        clk_i,
   input        rst_i,
   input        busywait,

   //Inputs and Outputs for the Pipeline Register
   input [4:0 ] rd_ex_mem_i,
   input [31:0] pc_ex_mem_i,
   input [1:0 ] wb_sel_ex_mem_i,
   input [31:0] imm_ex_mem_i,
   input [4:0 ] rs1_label_ex_mem_i,
   input [4:0 ] rs2_label_ex_mem_i,
   input [2:0] funct3_ex_mem_i,
   input [6:0] funct7_ex_mem_i,
   input is_load_instr_ex_mem_i, 
   input is_store_instr_ex_mem_i,    

   input is_mret_i,
   input [1:0] branch_jump_op_i,
   input ID_exception_detected_i,
   input [3:0] exception_i,
   input CSR_en_i,
   input [1:0] CSR_op_i,
   input CSR_source_sel_i,
   input [3:0] ALU_op_i,
   input [4:0] BMU_op_i,
   input MDU_en_i,
   input [2:0] MDU_op_i,
   input [1:0] chip_select_i,
   input rs1_shift_sel_i,
   input rs2_negate_sel_i,

   output reg [31:2] branch_target_o,
   output reg [4:0] rd_ex_mem_o,
   output reg [31:0] pc_ex_mem_o,
   output reg [1:0] wb_sel_ex_mem_o,
   output reg [31:0] imm_ex_mem_o,
   output reg [4:0] rs1_label_ex_mem_o,
   output reg [4:0] rs2_label_ex_mem_o,
   output reg [2:0] funct3_ex_mem_o,
   output reg [6:0] funct7_ex_mem_o,
   output reg is_load_instr_ex_mem_o,
   output reg is_store_instr_ex_mem_o,

   //outputs that are generted localy
   output reg [31:0] rs2_ex_mem_o,
   output reg [31:0] alu_out_ex_mem_o,
   output reg branching_o,

   //inputs required from prev stage to ex stage
   input [4:0] rd_mem_wb_i,
   input is_load_instr_mem_wb_i,

   //Inputs for Forwarding Unit
   input [31:0] rs1_value_ex_mem_i,
   input [31:0] rs2_value_ex_mem_i,
   input [31:0] alu_out_mem_wb_o,
   input [31:0] rd_data_mem_wb_o,
   input alu_op1_sel_ex_mem_i,
   input alu_op2_sel_ex_mem_i,
   output wire mul_stall_o,
   output wire div_stall_o,

   //Uzantı destek bitleri (Forwarded)
   output is_a_supported_o,
   output is_b_supported_o,
   output is_f_supported_o,
   output is_m_supported_o,

   output reg exception_detected_o
);
   wire EX_en = !branching_o && !busywait && !exception_detected_o;

   //Exception detection
   wire ID_exception_detected = EX_en && ID_exception_detected_i;
   wire EX_exception_detected = EX_en && branching_next && branch_target_misaligned;
   wire exception_detected = ID_exception_detected || EX_exception_detected;
   reg [3:0] exception_last;
   
   wire [31:0] mtvec_value, mepc_value;

   wire [31:0] alu_in1_w;
   wire [31:0] alu_in2_w;
   wire [31:0] alu_out_next;
   wire [1:0]  forwardA;
   wire [1:0]  forwardB;
   wire [31:0] rs1_tmp;
   wire [31:0] shifted_rs1;
   
   wire [31:0] ALU_res, MDU_res, BMU_res;
   
   wire [31:0] alu_in1_forwarded_input;
   wire [31:0] alu_in2_forwarded_input;
   
   
   localparam [2:0]  MUL_FUNCT3    = 3'b000,
                     MULH_FUNCT3   = 3'b001,
                     MULHSU_FUNCT3 = 3'b010,
                     MULHU_FUNCT3  = 3'b011,
                     DIV_FUNCT3    = 3'b100,
                     DIVU_FUNCT3   = 3'b101,
                     REM_FUNCT3    = 3'b110,
                     REMU_FUNCT3   = 3'b111;
   
   //Dallanma birimi
   wire branching_next;
   wire [1:0] branch_target_sel;
   wire [31:1] branch_target_value;
   wire [31:2] branch_target_next = branch_target_value[31:2];
   wire branch_target_misaligned = branch_target_value[1];

   branch_jump u_branch_jump(
      .rs1_i(alu_in1_w), 
      .rs2_i(alu_in2_w),
      .is_mret_i(is_mret_i),
      .branch_jump_op_i(branch_jump_op_i),
      .has_exception_i(ID_exception_detected), 
      .jump_to_exception_i(exception_detected_o),
      .funct3_i(funct3_ex_mem_i),
      .branching_o(branching_next),
      .target_sel_o(branch_target_sel)
   );

   mux_4x1 #(
      .DATA_WIDTH(31)
   ) branch_target_selector (
      .in0(alu_out_next[31:1]),
      .in1(mtvec_value[31:1]),
      .in2(mepc_value[31:1]),
      .in3(31'hBADC0DE),

      .select(branch_target_sel),
      .out(branch_target_value)
   );
   
   forwarding_unit forwarding_unit(
      .rd_label_ex_mem_i(rd_ex_mem_o),
      .rd_label_mem_wb_i(rd_mem_wb_i),
      .rs1_label_i(rs1_label_ex_mem_i),
      .rs2_label_i(rs2_label_ex_mem_i),
      .is_load_instr_mem_wb_i(is_load_instr_mem_wb_i),
      .forwardA_o(forwardA),
      .forwardB_o(forwardB)
   );
   
   mux_4x1 #(
      .DATA_WIDTH(32)
   ) rs1_latest_value_selector (
      .in0(rs1_value_ex_mem_i),   // X0
      .in1(alu_out_mem_wb_o),     // X1
      .in2(alu_out_ex_mem_o),     // X2
      .in3(rd_data_mem_wb_o),     // X3
      .select(forwardA),
      .out(alu_in1_w)
   );
   
   mux_2x1 #(
      .DATA_WIDTH(32)
   ) pc_or_rs1_selector (
      .in0(alu_in1_w),             // X0: Most recent rs1 value
      .in1(pc_ex_mem_i),           // X1: PC value
      .select(alu_op1_sel_ex_mem_i),
      .out(rs1_tmp)
   );
   
   barrel_shifter_32bit u_barrel_shifter (
      .data_i(rs1_tmp),
      .ctrl_i(funct3_ex_mem_i[2:1]),// upper 2 bits of funct3 tells us the amount of shift
      .data_o(shifted_rs1)
   );
   
   //mux for Shifting RS1
   mux_2x1 #(
      .DATA_WIDTH(32)
   ) u_rs1_shift_sel_i_mux(
      .in0(rs1_tmp),
      .in1(shifted_rs1),
      .select(rs1_shift_sel_i), 
      .out(alu_in1_forwarded_input)
   );

   
   mux_4x1 #(
      .DATA_WIDTH(32)
   ) rs2_latest_value_selector (
      .in0(rs2_value_ex_mem_i),   // X0
      .in1(alu_out_mem_wb_o),     // X1
      .in2(alu_out_ex_mem_o),     // X2
      .in3(rd_data_mem_wb_o),     // X3
      .select(forwardB),
      .out(alu_in2_w)
   );

   wire [31:0] rs2_tmp;
   mux_2x1 #(
      .DATA_WIDTH(32)
   ) imm_or_rs2_selector (
      .in0(alu_in2_w),            // X0: Most recent rs2 value
      .in1(imm_ex_mem_i),         // X1: Immediate value
      .select(alu_op2_sel_ex_mem_i),
      .out(rs2_tmp)
   );

   mux_2x1 #(
      .DATA_WIDTH(32)
   ) u_rs2_negate_sel_i_mux(
      .in0(rs2_tmp),
      .in1(~rs2_tmp),
      .select(rs2_negate_sel_i),
      .out(alu_in2_forwarded_input)
   );
   
   alu u_alu(
      .alu1_i(alu_in1_forwarded_input),  //bunlar anlik cikis oldugu icin pipeline'a girmelerine gerek yok.
      .alu2_i(alu_in2_forwarded_input),
      .chip_select(chip_select_i),
      .alu_op_i(ALU_op_i),
      .result_o(ALU_res)
   );

   MDU u_MDU(
      .clk_i(clk_i),//clock for pipelined mul/div operations
      .rst_i(rst_i),
      .alu1_i(alu_in1_forwarded_input),
      .alu2_i(alu_in2_forwarded_input),
      .en_i(EX_en && MDU_en_i),
      .MDU_op(MDU_op_i),
      .result_o(MDU_res),
      .mul_stall(mul_stall_o),
      .div_stall(div_stall_o)
   );
   
   BMU u_BMU(
      .rs1_value_i(alu_in1_forwarded_input),
      .rs2_value_i(alu_in2_forwarded_input),
      .BMU_opcode_i(BMU_op_i),
      .BMU_result_o(BMU_res)
   );
   
   wire [11:0] CSR_addr = imm_ex_mem_i[11:0];
   wire [31:0] CSR_res;
   
   csr_unit u_CSR(
      .clk_i(clk_i),
      .rst_i(rst_i),
 
      .en_i(EX_en && CSR_en_i),
      .op_i(CSR_op_i),
      .source_sel_i(CSR_source_sel_i),

      .exception_detected_i(exception_detected_o),
      .exception_i(exception_last),
      .pc_last_i(pc_ex_mem_o[31:2]),
      
      .rs1_label_i(rs1_label_ex_mem_i),
      .rs1_value_i(alu_in1_w), //Most recent RS1 value
      
      .addr_i(CSR_addr),
      
      .read_o(CSR_res),

      .mtvec_o(mtvec_value),
      .mepc_o(mepc_value),

      .is_a_supported_o(is_a_supported_o),
      .is_b_supported_o(is_b_supported_o),
      .is_f_supported_o(is_f_supported_o),
      .is_m_supported_o(is_m_supported_o)
   );

   mux_4x1 #(
      .DATA_WIDTH(32)
   ) u_EX_res_select_mux (
      .in0(ALU_res),   // X0
      .in1(MDU_res),   // X1
      .in2(BMU_res),   // X2
      .in3(CSR_res),   // X3
      .select(chip_select_i),
      .out(alu_out_next)
   );

   always @(posedge clk_i) begin
      if(rst_i || branching_o) begin
         branching_o <= !rst_i && exception_detected_o; //Misaligned Instruction Exception için (burada !rst_i testi gerekli mi?)
         branch_target_o <= mtvec_value[31:2]; //Misaligned Instruction Exception için
         alu_out_ex_mem_o <= 32'd0;
         rd_ex_mem_o <= 5'd0;
         pc_ex_mem_o <= 32'd0;
         wb_sel_ex_mem_o <= 2'd0;
         imm_ex_mem_o <= 32'd0;
         rs1_label_ex_mem_o <= 5'd0;
         rs2_label_ex_mem_o <= 5'd0;
         rs2_ex_mem_o <= 32'd0;
         funct3_ex_mem_o <= 3'b0;
         funct7_ex_mem_o <= 7'b0;
         is_load_instr_ex_mem_o <= 1'b0;
         is_store_instr_ex_mem_o <= 1'b0;
         exception_detected_o <= 1'b0;
         exception_last <= 0;
      end else if(!busywait) begin
         if (!mul_stall_o && !div_stall_o) begin
            branching_o <= branching_next;     
            branch_target_o <= branch_target_next;
            alu_out_ex_mem_o <= alu_out_next;
            rd_ex_mem_o <= rd_ex_mem_i;
            pc_ex_mem_o <= pc_ex_mem_i;
            wb_sel_ex_mem_o <= wb_sel_ex_mem_i;
            imm_ex_mem_o <= imm_ex_mem_i;
            rs1_label_ex_mem_o <= rs1_label_ex_mem_i;
            rs2_label_ex_mem_o <= rs2_label_ex_mem_i;
            rs2_ex_mem_o <= alu_in2_w;
            funct3_ex_mem_o <= funct3_ex_mem_i;
            funct7_ex_mem_o <= funct7_ex_mem_i;
            is_load_instr_ex_mem_o <= is_load_instr_ex_mem_i;
            is_store_instr_ex_mem_o <= is_store_instr_ex_mem_i;
            exception_detected_o <= exception_detected;
            exception_last <= exception_i;
         end else begin // Mul stall da yazma!
            rd_ex_mem_o <= 0;
         end
      end     
   end
   
endmodule
