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
   
   input is_long_i,
   input [31:1] pc_i,
   
   output stall,
   
   output [31:1] pc_id_ex_o,
    
   output [31:0] rs1_value_id_ex_o,
   output [31:0] rs2_value_id_ex_o,  
   
   output [31:0] imm_value_id_ex_o,      
   
   output [2:0] imm_sel_id_ex_o,
   output alu_op1_sel_id_ex_o,
   output alu_op2_sel_id_ex_o,
   output [4:0] alu_op_id_ex_o,
   output [2:0] branch_sel_id_ex_o,
   output [3:0] read_write_sel_id_ex_o,
   output [1:0] wb_sel_id_ex_o,
   output reg_wb_en_id_ex_o,
   output [4:0] rd_id_ex_o,
   output [4:0] rs1_label_id_ex_o,
   output [4:0] rs2_label_id_ex_o,   
//   output reg [6:0] opcode_id_ex_o,  
   output is_memory_instruction_id_ex_o,
   output is_load_instruction_id_ex_o,
   output is_long_id_ex_o
);
   wire [4:0] rd_label = instr_i[11:7];
   wire [4:0] rs1_label = instr_i[19:15];
   wire [4:0] rs2_label = instr_i[24:20];

   wire [2:0] imm_sel;
   wire op1_sel;
   wire op2_sel;
   wire [4:0] alu_op;
   wire [2:0] branch_sel;
   wire [3:0] read_write;
   wire [1:0] wb_sel;
   wire reg_w_en;
   wire is_memory_instruction;
   wire is_load_instruction;
   
   control_unit control_unit(
      .opcode_i({instr_i[6:2], 2'b11}),
      .funct3_i(instr_i[14:12]),
      .funct7_i(instr_i[31:25]),
      .imm_sel_o(imm_sel),
      .op1_sel_o(op1_sel),
      .op2_sel_o(op2_sel),
      .alu_op_o(alu_op),
      .branch_sel_o(branch_sel),
      .read_write_o(read_write),
      .wb_sel_o(wb_sel),
      .reg_w_en_o(reg_w_en),
      .is_memory_instruction_o(is_memory_instruction),
      .is_load_instruction(is_load_instruction) 
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
       .stall(stall)  // cikis stall sinyali
   );
   
   wire [31:0] imm;
   
   //Anlik genisletme birimi (umutun ara raporuna bakilmali)
    imm_gen u_imm_gen(
        .instr_i(instr_i[31:7]),
        .imm_sel_i(imm_sel),
        .imm_o(imm)
    );                   
   
//   wire flush_id_ex_o;
   id_ex_stage_reg id_ex(
     .clk_i(clk_i),
     .rst_i(rst_i),
     .busywait(busywait),
     .flush(flush),
     
     .is_long_id_ex_i(is_long_i),
     .is_long_id_ex_o(is_long_id_ex_o),
     
     .pc_id_ex_i(pc_i),          //passing PC for the Branch UNIT
     .pc_id_ex_o(pc_id_ex_o),
     
     .rs1_value_id_ex_i(rs1_value),       // passing rs1 32 bit value
     .rs1_value_id_ex_o(rs1_value_id_ex_o),
     
     .rs2_value_id_ex_i(rs2_value),       //passinng rs2 32bit value
     .rs2_value_id_ex_o(rs2_value_id_ex_o),
     
     .imm_value_id_ex_i(imm),       // passing the 32bit imm result
     .imm_value_id_ex_o(imm_value_id_ex_o),
     
     .imm_sel_id_ex_i(imm_sel),//passing 3 bit selection for imm unit
     .imm_sel_id_ex_o(imm_sel_id_ex_o),
     
     .alu_op1_sel_id_ex_i(op1_sel), //alu op1 1bitsignal
     .alu_op1_sel_id_ex_o(alu_op1_sel_id_ex_o),
     
     .alu_op2_sel_id_ex_i(op2_sel), //alu op2 1 bit signal
     .alu_op2_sel_id_ex_o(alu_op2_sel_id_ex_o),
     
     .alu_op_id_ex_i(alu_op),   //alu operation signal 5bit
     .alu_op_id_ex_o(alu_op_id_ex_o),
     
     .branch_sel_id_ex_i(branch_sel),   //branch unit select
     .branch_sel_id_ex_o(branch_sel_id_ex_o),   //signal 3 bit
     
     .read_write_sel_id_ex_i(read_write), //in case of stall, send 0
     //else send old value
     .read_write_sel_id_ex_o(read_write_sel_id_ex_o),
     
     .wb_sel_id_ex_i(wb_sel),//
     .wb_sel_id_ex_o(wb_sel_id_ex_o),
     
     .reg_wb_en_id_ex_i(reg_w_en),
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
     .is_load_instruction_id_ex_o(is_load_instruction_id_ex_o)
   );

endmodule
