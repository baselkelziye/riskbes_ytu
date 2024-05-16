`timescale 1ns / 1ps
//TODO

//6.01.2023


//TEKNOFEST ICIN YAPILACAKLAR
//otomatik bi sekilde OBJ KODLARI OKUYUP INSTURCTION CACHE'e YERLESTIR
//memory erisiminde adres alignment bakilacak mi?
//resetleri aktif 0 yap
//Hazard detection yapinca aradaki komutu NOP yapmamiz gerekir mi?

module core(
   input clk_i,
   input rst_i,
   
   input instr_cache_blocking_n_i,
   input data_cache_blocking_n_i,
   
   input [31:0] instr_cache_data_i,
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
    wire [3:0] read_write_sel_id_ex_o; 

    wire [1:0] wb_sel_id_ex_o;

    wire reg_wb_en_id_ex_o;  
    
    wire [4:0] rd_id_ex_o; //pass rd label for the writeback   
    wire [4:0] rs1_label_id_ex_o; //forwarding unit
    
    wire [4:0] rs2_label_id_ex_o;    
    wire is_memory_instruction_id_ex_o;
    
    wire [2:0] funct3_id_ex_o;
    wire [6:0] funct7_id_ex_o;

    wire is_load_instr_id_ex_o;
    wire is_store_instr_id_ex_o;
    wire is_branch_instr_id_ex_o;
    wire [1:0] EX_op_id_ex_o;
    
    //*****************EX-MEM******************
    wire [31:0] alu_out_ex_mem_i; // for alu output
    wire [31:0] alu_out_ex_mem_o;
    wire reg_wb_en_ex_mem_o;
    wire [4:0] rd_ex_mem_o;  
    wire [31:0] pc_ex_mem_o;  
    wire [1:0] wb_sel_ex_mem_o; // control signal to WB                              
    wire [31:0] imm_ex_mem_o;   
    wire [3:0] read_write_sel_ex_mem_o;
    wire [4:0] rs1_label_ex_mem_o;
    wire [4:0] rs2_label_ex_mem_o;   
    wire [31:0] rs2_ex_mem_o; 
    wire is_memory_instruction_ex_mem_o;  
    wire PC_sel_w_ex_mem_o;
    
// forwarding unit                   
    wire [31:0] alu_in1_forwarded_input;
    wire [31:0] alu_in2_forwarded_input;
    wire [1:0]  forwardA;
    wire [1:0]  forwardB;
    
    wire [2:0] funct3_ex_mem_o;
    wire [6:0] funct7_ex_mem_o;
    wire is_load_instr_ex_mem_o;
    wire is_store_instr_ex_mem_o;
    
    //    *********** MEM-WB STAGE ***************
    wire reg_wb_en_mem_wb_o;  
    wire [4:0] rd_mem_wb_o;  
    wire [31:0] alu_out_mem_wb_o;  
    wire [1:0] wb_sel_mem_wb_o; // control signal to write back to reg file (which value) 
    wire [31:0] rd_data_mem_wb_o; 
    wire [31:0] imm_mem_wb_o;
    wire [31:0] pc_mem_wb_o;
    wire is_memory_instruction_mem_wb_o; 
    wire [31:0] rs2_mem_wb_o;   
    wire [31:0] pc_mem_wb_o_4; 

    //************ tmp values *******************\\

    reg data_cache_blocking_n_last;
    
    always @(posedge clk_i) begin
      data_cache_blocking_n_last <= data_cache_blocking_n_i;
    end

    //tmp control signals
    wire id_stall;
    wire if_stall = id_stall | ~data_cache_blocking_n_last | ~data_cache_blocking_n_i;
    wire [31:0] alu_in1_w;
    wire [31:0] alu_in2_w; 
    wire [31:0] reg_wb_data_w;
    wire ins_busy_w;
    wire busy_w;
    wire write_en_w;
    
    assign busy_w = ins_busy_w | ~data_cache_blocking_n_last | ~data_cache_blocking_n_i;
    assign write_en_w = (reg_wb_en_mem_wb_o & ~busy_w); //reg i mem_wb_o yapmak laizm en son

   instruction_fetch_stage u_if(
     .clk_i(clk_i),
     .rst_i(rst_i),
     .cache_blocking_n_i(instr_cache_blocking_n_i),
     .cache_data_i(instr_cache_data_i[31:2]),
     .cache_address_o(instr_cache_address_o),
     .ins_busywait_o(ins_busy_w),

     .stall_i(if_stall),
     .branching(PC_sel_w_ex_mem_o),
     .branch_pc(alu_out_ex_mem_o[31:1]),
     .instr_o(instruction_if_id_o),
     .pc_o(pc_if_id_o)
   );
    
        
   wire [31:2] u_id_pc_o;  
   assign pc_id_ex_o = {u_id_pc_o, 2'b00};   
   instruction_decode_stage u_id(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .instr_i(instruction_if_id_o),
      .busywait(busy_w),
      .flush(PC_sel_w_ex_mem_o),
      .stall(id_stall),
      
      .rd_label_i(rd_mem_wb_o),
      .rd_data_i(reg_wb_data_w),
      .rd_enable_i(reg_wb_en_mem_wb_o),
      
      .pc_i(pc_if_id_o),
      .pc_id_ex_o(u_id_pc_o),
        
      .rs1_value_id_ex_o(rs1_value_id_ex_o),
      .rs2_value_id_ex_o(rs2_value_id_ex_o),
      .imm_value_id_ex_o(imm_value_id_ex_o),
      .alu_op1_sel_id_ex_o(alu_op1_sel_id_ex_o),
      .alu_op2_sel_id_ex_o(alu_op2_sel_id_ex_o),
      .read_write_sel_id_ex_o(read_write_sel_id_ex_o),
      .wb_sel_id_ex_o(wb_sel_id_ex_o),
      .reg_wb_en_id_ex_o(reg_wb_en_id_ex_o),
      .rd_id_ex_o(rd_id_ex_o),
      .rs1_label_id_ex_o(rs1_label_id_ex_o),
      .rs2_label_id_ex_o(rs2_label_id_ex_o),
      .is_memory_instruction_id_ex_o(is_memory_instruction_id_ex_o),
      .is_load_instruction_id_ex_o(is_load_instruction_id_ex_o),
      .funct3_id_ex_o(funct3_id_ex_o),
      .funct7_id_ex_o(funct7_id_ex_o),
      .is_load_instr_id_ex_o(is_load_instr_id_ex_o),
      .is_store_instr_id_ex_o(is_store_instr_id_ex_o),
      .is_branch_instr_id_ex_o(is_branch_instr_id_ex_o),
      .EX_op_id_ex_o(EX_op_id_ex_o)
   );
            
    //Dallanma birimi (umutuun raporuna bakilmali)
    branch_jump u_branch_jump(
        .in1_i(alu_in1_w),          //alu output yap
        .in2_i(alu_in2_w),
        .is_branch_instr(is_branch_instr_id_ex_o),
        .funct3_i(funct3_id_ex_o),
        .PC_sel_o(PC_sel_w)            //sinyal
    );


                 
     //Yonlendirma birimi, kendi dosyasinda aciklama yapildi
    forwarding_unit forwarding_unit(
        .rd_label_ex_mem_o(rd_ex_mem_o),
        .rd_label_mem_wb_o(rd_mem_wb_o),
        .rs1_label_id_ex_o(rs1_label_id_ex_o),
        .rs2_label_id_ex_o(rs2_label_id_ex_o),
        .reg_wb_en_ex_mem_o(reg_wb_en_ex_mem_o),
        .reg_wb_en_mem_wb_o(reg_wb_en_mem_wb_o),
        .is_memory_instruction_mem_wb_o(is_memory_instruction_mem_wb_o),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );
    
    

    mux_4x1 #(
    .DATA_WIDTH(32)
    ) rs1_latest_value_selector (
    .in0(rs1_value_id_ex_o),    // X0
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
    .in1(pc_id_ex_o),            // X1: PC value
    .select(alu_op1_sel_id_ex_o),
    .out(alu_in1_forwarded_input)
    );

    mux_2x1 #(
    .DATA_WIDTH(32)
    ) imm_or_rs2_selector (
    .in0(alu_in2_w),                 // X0: Most recent rs2 value
    .in1(imm_value_id_ex_o),         // X1: Immediate value
    .select(alu_op2_sel_id_ex_o),
    .out(alu_in2_forwarded_input)
    );


   
    mux_4x1 #(
    .DATA_WIDTH(32)
    ) rs2_latest_value_selector (
    .in0(rs2_value_id_ex_o),    // X0
    .in1(alu_out_mem_wb_o),     // X1
    .in2(alu_out_ex_mem_o),     // X2
    .in3(rd_data_mem_wb_o),     // X3
    .select(forwardB),
    .out(alu_in2_w)
    );


    
    //EX_Decoder sinyalleri, Sonra yukariya EX Stage sinyallerin altina Aynen tasinsin
    wire [1:0] chip_select;
    wire [4:0] ALU_op;
    wire [4:0] BMU_op;
    wire [2:0] MDU_op;
    wire [31:0] ALU_res, MDU_res, BMU_res;
    
    EX_Decoder u_EX_Decoder(
                   .EX_op (EX_op_id_ex_o), 
                   .funct3(funct3_id_ex_o),
                   .funct7(funct7_id_ex_o),
                   .ALU_op(ALU_op),
                //    .BMU_op(BMU_op),
                   .MDU_op(MDU_op),
                   .chip_select(chip_select)
    );

    MDU u_MDU(
        .alu1_i(alu_in1_w),
        .alu2_i(alu_in2_w),
        .chip_select(chip_select),
        .MDU_op(MDU_op),
        .result_o(MDU_res)
    );
                                   
    alu u_alu(
        .alu1_i(alu_in1_forwarded_input),  //bunlar anlik cikis oldugu icin pipeline'a girmelerine gerek yok.
        .alu2_i(alu_in2_forwarded_input),
        .chip_select(chip_select),
        .alu_op_i(ALU_op),
        .result_o(ALU_res)
    );


    mux_4x1 #(
    .DATA_WIDTH(32)
    ) u_EX_res_select_mux (
       .in0(ALU_res),        // X0
       .in1(MDU_res),        // X1
       .in2(32'hdeadbeef),   // X2
       .in3(32'hdeadbeef),   // X3
       .select(chip_select),
       .out(alu_out_ex_mem_i)
    );
    
    
    ex_mem_stage_reg ex_mem(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .busywait(busy_w),
        .alu_out_ex_mem_i(alu_out_ex_mem_i),
        .alu_out_ex_mem_o(alu_out_ex_mem_o),
        .reg_wb_en_ex_mem_i(reg_wb_en_id_ex_o),
        .reg_wb_en_ex_mem_o(reg_wb_en_ex_mem_o),
        .rd_ex_mem_i(rd_id_ex_o), //in_id nin cikisini ver buraya
        .rd_ex_mem_o(rd_ex_mem_o),
        .pc_ex_mem_i(pc_id_ex_o),
        .pc_ex_mem_o(pc_ex_mem_o),
        .wb_sel_ex_mem_i(wb_sel_id_ex_o),
        .wb_sel_ex_mem_o(wb_sel_ex_mem_o),
        .imm_ex_mem_i(imm_value_id_ex_o),
        .imm_ex_mem_o(imm_ex_mem_o),
        .rs1_label_ex_mem_i(rs1_label_id_ex_o),
        .rs1_label_ex_mem_o(rs1_label_ex_mem_o),
        .rs2_label_ex_mem_i(rs2_label_id_ex_o),
        .rs2_label_ex_mem_o(rs2_label_ex_mem_o),
        .read_write_sel_ex_mem_i(read_write_sel_id_ex_o),
        .read_write_sel_ex_mem_o(read_write_sel_ex_mem_o),
        .rs2_ex_mem_i(alu_in2_w),
        .rs2_ex_mem_o(rs2_ex_mem_o),
        .is_memory_instruction_ex_mem_i(is_memory_instruction_id_ex_o),
        .is_memory_instruction_ex_mem_o(is_memory_instruction_ex_mem_o),
        .PC_sel_w_ex_mem_i(PC_sel_w),
        .PC_sel_w_ex_mem_o(PC_sel_w_ex_mem_o),
        .funct3_ex_mem_i(funct3_id_ex_o),
        .funct3_ex_mem_o(funct3_ex_mem_o),
        
        .funct7_ex_mem_i(funct7_id_ex_o),
        .funct7_ex_mem_o(funct7_ex_mem_o),

        .is_load_instr_ex_mem_i(is_load_instr_id_ex_o),
        .is_load_instr_ex_mem_o(is_load_instr_ex_mem_o),

        .is_store_instr_ex_mem_i(is_store_instr_id_ex_o),
        .is_store_instr_ex_mem_o(is_store_instr_ex_mem_o)
    );
    
   memory_stage u_mem(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .busywait_i(busy_w),
      .data_cache_blocking_n_i(data_cache_blocking_n_i),
      
      .data_cache_data_i(data_cache_data_i),
      .op_type_i(read_write_sel_ex_mem_o),
      .reg_wb_en_i(reg_wb_en_ex_mem_o),
      .rd_label_i(rd_ex_mem_o),
      .alu_out_i(alu_out_ex_mem_o),
      .wb_sel_i(wb_sel_ex_mem_o),
      .imm_i(imm_ex_mem_o),
      .pc_i(pc_ex_mem_o),
      .is_memory_instruction_i(is_memory_instruction_ex_mem_o),
      .rs2_data_i(rs2_ex_mem_o),
      
      .data_cache_data_o(data_cache_data_o),
      .data_cache_write_en_o(data_cache_write_en_o),
      .data_cache_address_o(data_cache_address_o),
      .data_cache_enabled_o(data_cache_enabled_o),
      .load_val_o(rd_data_mem_wb_o),
      
      .reg_wb_en_o(reg_wb_en_mem_wb_o),
      .rd_label_o(rd_mem_wb_o),
      .alu_out_o(alu_out_mem_wb_o),
      .wb_sel_o(wb_sel_mem_wb_o),
      .imm_o(imm_mem_wb_o),
      .pc_o(pc_mem_wb_o),
      .is_memory_instruction_o(is_memory_instruction_mem_wb_o),
      .rs2_data_o(rs2_mem_wb_o)
   );

    pc_adder u_pc_adder1(
        .in_i(pc_mem_wb_o), //PC i 4 ile toplar
        .out_o(pc_mem_wb_o_4) // cunku son muxta PC+4 var, su ana kadar sadece PC i ilettik biz, 4 ile toplayip yollamamiz lazim.
    );

    mux #(
        .DATA_WIDTH(32),    // Set the data width of each input to 32 bits
        .NUM_INPUTS(4)      // Set the number of inputs to 4 (for a 4-to-1 MUX)
    ) u_wb_mux (
        .in_flat({pc_mem_wb_o_4, imm_mem_wb_o, rd_data_mem_wb_o, alu_out_mem_wb_o}), // Concatenate inputs for the mux
        .select(wb_sel_mem_wb_o),    // Selection signal
        .out(reg_wb_data_w)          // Output of the MUX
    );
     
endmodule
