`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2024 04:16:18 PM
// Design Name: 
// Module Name: instruction_decode_stage
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


module instruction_decode_stage(
   input clk_i, rst_i,

   input [31:2] instr_i,
   input busywait,
   input flush,
   
   input [31:0] rd_data_i,
   input [4:0] rd_label_i,
   input rd_enable_i,

   input [31:2] pc_i,
   
   output hazard_o,
   
   output [31:2] pc_id_ex_o,
    
   output [31:0] rs1_value_id_ex_o,
   output [31:0] rs2_value_id_ex_o,  
   
   output [31:0] imm_value_id_ex_o,      
  
   output alu_op1_sel_id_ex_o,
   output alu_op2_sel_id_ex_o,
   output [3:0] read_write_sel_id_ex_o,
   output [1:0] wb_sel_id_ex_o,
   output reg_wb_en_id_ex_o,
   output [4:0] rd_id_ex_o,
   output [4:0] rs1_label_id_ex_o,
   output [4:0] rs2_label_id_ex_o,   
//   output reg [6:0] opcode_id_ex_o,  
   output is_memory_instruction_id_ex_o,
   output is_load_instruction_id_ex_o,
   output [2:0] funct3_id_ex_o,
   output [6:0] funct7_id_ex_o,
   output is_load_instr_id_ex_o,
   output is_store_instr_id_ex_o,
   output is_branch_instr_id_ex_o,
   output [1:0] EX_op_id_ex_o

);
   wire [4:0] rd_label = instr_i[11:7];
   wire [4:0] rs1_label = instr_i[19:15];
   wire [4:0] rs2_label = instr_i[24:20];

   wire [2:0] imm_sel;
   wire op1_sel;
   wire op2_sel;
   wire [4:0] alu_op;

   wire [3:0] read_write;
   wire [1:0] wb_sel;
   wire reg_wr_en;
   wire is_memory_instruction;
   wire is_load_instruction;
   
   
   //New Main Decoder Signals
   wire is_load_instr, is_store_instr;
   wire is_branch_instr;
   wire [2:0] funct3 = instr_i[14:12];
   wire [6:0] funct7 = instr_i[31:25];
   wire [2:0] imm_src; //Delete other imm_sel from countrol unit
   wire [1:0] EX_op;
   
   control_unit control_unit(
      .opcode_i({instr_i[6:2], 2'b11}),
      .funct3_i(funct3),
      .funct7_i(funct7),
      .read_write_o(read_write),
      .is_memory_instruction_o(is_memory_instruction),
      .is_load_instruction(is_load_instruction) 
   );
   
   
   main_decoder u_main_decoder(
      .opcode_i({instr_i[6:2], 2'b11}),
      .reg_wr_en(reg_wr_en),
      .wb_sel(wb_sel),
      .op1_sel(op1_sel),
      .op2_sel(op2_sel),
      .is_load_instr(is_load_instr),
      .is_store_instr(is_store_instr),
      .is_branch_instr(is_branch_instr),
      .imm_src(imm_src),
      .EX_op(EX_op)
      );
      
   wire [31:0] rs1_value, rs2_value;
   //Yazmaclarin durdugu yer
   regfile u_regfile
   (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .write_en_i(rd_enable_i),//yazmaca yaz sinyali (mem/wb asamasindan gelir)
      .rd_i(rd_label_i),//rd yazmac numarasi
      .rd_data_i(rd_data_i),//rd yazmac degeri
      .rs1_i(rs1_label),//rs1 yazmac numarasi (okumak icin)
      .rs2_i(rs2_label),//rs2 yazmac numarasi (okumak icin)
      .rs1_data_o(rs1_value),//rs1 yazmac degeri (cikis)
      .rs2_data_o(rs2_value)//rs2 yazmac degeri (cikis)
   );
   
       // Load Data Hazard durumlarindaki Pipeline'i stall etmek icin
   hazard_detection_unit hazard_detection_unit
   (
       .is_load_instruction(is_load_instruction_id_ex_o), // EX asamasinda LOAD islemi var
       .rd_label_id_ex_o(rd_id_ex_o), // EX asamasinda RD
       .rs1_label_if_id_o(rs1_label), // ID rs1 numarasi
       .rs2_label_if_id_o(rs2_label), // ID rs2 numarasi
       .hazard_o(hazard_o)  // cikis hazard_o sinyali
   );
   
   wire [31:0] imm;
   
   //Anlik genisletme birimi (umutun ara raporuna bakilmali)
    imm_gen u_imm_gen(
        .instr_i(instr_i[31:7]),
        .imm_src(imm_src),
        .imm_o(imm)
    );                   
   
//   wire flush_id_ex_o;
   id_ex_stage_reg id_ex(
     .clk_i(clk_i),
     .rst_i(rst_i),
     .busywait(busywait),
     .flush(flush),
     .hazard_i(hazard_o),
     
     .pc_id_ex_i(pc_i),          //passing PC for the Branch UNIT
     .pc_id_ex_o(pc_id_ex_o),
     
     .rs1_value_id_ex_i(rs1_value),       // passing rs1 32 bit value
     .rs1_value_id_ex_o(rs1_value_id_ex_o),
     
     .rs2_value_id_ex_i(rs2_value),       //passinng rs2 32bit value
     .rs2_value_id_ex_o(rs2_value_id_ex_o),
     
     .imm_value_id_ex_i(imm),       // passing the 32bit imm result
     .imm_value_id_ex_o(imm_value_id_ex_o),
     
     .alu_op1_sel_id_ex_i(op1_sel), //alu op1 1bitsignal
     .alu_op1_sel_id_ex_o(alu_op1_sel_id_ex_o),
     
     .alu_op2_sel_id_ex_i(op2_sel), //alu op2 1 bit signal
     .alu_op2_sel_id_ex_o(alu_op2_sel_id_ex_o),
          
     
     .read_write_sel_id_ex_i(read_write), //in case of stall, send 0
     //else send old value
     .read_write_sel_id_ex_o(read_write_sel_id_ex_o),
     
     .wb_sel_id_ex_i(wb_sel),//
     .wb_sel_id_ex_o(wb_sel_id_ex_o),
     
     .reg_wb_en_id_ex_i(reg_wr_en),
     .reg_wb_en_id_ex_o(reg_wb_en_id_ex_o),
     
     .rd_id_ex_i(rd_label),
     .rd_id_ex_o(rd_id_ex_o),
     
     .rs1_label_id_ex_i(rs1_label),
     .rs1_label_id_ex_o(rs1_label_id_ex_o),
     .rs2_label_id_ex_i(rs2_label),
     .rs2_label_id_ex_o(rs2_label_id_ex_o),
//     .opcode_id_ex_i(instruction_opcode_if_id_o),
//     .opcode_id_ex_o(opcode_id_ex_o),
     .is_memory_instruction_id_ex_i(is_memory_instruction),
     .is_memory_instruction_id_ex_o(is_memory_instruction_id_ex_o),
     .is_load_instruction_id_ex_i(is_load_instruction),
     .is_load_instruction_id_ex_o(is_load_instruction_id_ex_o),
     
     .funct3_id_ex_i(funct3),
     .funct3_id_ex_o(funct3_id_ex_o),
     
     .funct7_id_ex_i(funct7),
     .funct7_id_ex_o(funct7_id_ex_o),
     
     .is_load_instr_id_ex_i(is_load_instr),
     .is_load_instr_id_ex_o(is_load_instr_id_ex_o),

     .is_store_instr_id_ex_i(is_store_instr),
     .is_store_instr_id_ex_o(is_store_instr_id_ex_o),
     
     .is_branch_instr_id_ex_i(is_branch_instr),
     .is_branch_instr_id_ex_o(is_branch_instr_id_ex_o),

     .EX_op_id_ex_i(EX_op),
     .EX_op_id_ex_o(EX_op_id_ex_o)
   );

endmodule
