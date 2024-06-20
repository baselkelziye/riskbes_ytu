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
   input stall_id_i,
   
   output load_stall_o,
   
   output reg [31:2] pc_id_ex_o,
    
   output reg [31:0] rs1_value_id_ex_o,
   output reg [31:0] rs2_value_id_ex_o,  
   
   output reg [31:0] imm_value_id_ex_o,      
  
   output reg alu_op1_sel_id_ex_o,
   output reg alu_op2_sel_id_ex_o,
   output reg [3:0] read_write_sel_id_ex_o,
   output reg [1:0] wb_sel_id_ex_o,
   output reg reg_wb_en_id_ex_o,
   output reg [4:0] rd_id_ex_o,
   output reg [4:0] rs1_label_id_ex_o,
   output reg [4:0] rs2_label_id_ex_o,   
   output reg [6:2] opcode_id_ex_o,  
   output reg is_memory_instruction_id_ex_o,
   output reg is_load_instruction_id_ex_o,
   output reg [2:0] funct3_id_ex_o,
   output reg [6:0] funct7_id_ex_o,
   output reg is_load_instr_id_ex_o,
   output reg is_store_instr_id_ex_o,
   output reg is_branch_instr_id_ex_o,
   output reg is_jump_instr_id_ex_o,
   output reg [2:0] EX_op_id_ex_o

);
   wire [4:0] rd_label = instr_i[11:7];
   wire [4:0] rs1_label = instr_i[19:15];
   wire [4:0] rs2_label = instr_i[24:20];

   wire op1_sel;
   wire op2_sel;

   wire [3:0] read_write;
   wire [1:0] wb_sel;
   wire reg_wr_en;
   wire is_memory_instruction;
   wire is_load_instruction;
   
   
   //New Main Decoder Signals
   wire is_load_instr, is_store_instr;
   wire is_branch_instr, is_jump_instr;
   wire [2:0] funct3 = instr_i[14:12];
   wire [6:0] funct7 = instr_i[31:25];
   wire [2:0] imm_src;
   wire [2:0] EX_op;
   
   control_unit control_unit(
      .opcode_i({instr_i[6:2], 2'b11}),
      .funct3_i(funct3),
      .funct7_i(funct7),
      .read_write_o(read_write),
      .is_memory_instruction_o(is_memory_instruction),
      .is_load_instruction(is_load_instruction) 
   );
   
   
   main_decoder u_main_decoder(
      .opcode_i(instr_i[6:2]),
      .reg_wr_en(reg_wr_en),
      .wb_sel(wb_sel),
      .op1_sel(op1_sel),
      .op2_sel(op2_sel),
      .is_load_instr(is_load_instr),
      .is_store_instr(is_store_instr),
      .is_branch_instr(is_branch_instr),
      .is_jump_instr(is_jump_instr),
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
       .stall(load_stall_o)  // cikis stall sinyali
   );
   
   wire [31:0] imm;
   
   //Anlik genisletme birimi (umutun ara raporuna bakilmali)
    imm_gen u_imm_gen(
        .instr_i(instr_i[31:7]),
        .imm_src(imm_src),
        .imm_o(imm)
    );                   
    
    always @(posedge clk_i)begin
      if(!rst_i && !flush) begin
         if(!busywait) begin
            if(!stall_id_i)begin
               pc_id_ex_o  <= pc_i;
               rs1_value_id_ex_o <= rs1_value;
               rs2_value_id_ex_o <= rs2_value;
               imm_value_id_ex_o <= imm; 
               alu_op1_sel_id_ex_o <= op1_sel;
               alu_op2_sel_id_ex_o <= op2_sel;
               read_write_sel_id_ex_o <= read_write;
               wb_sel_id_ex_o <= wb_sel;
               reg_wb_en_id_ex_o <= reg_wr_en;  
               rd_id_ex_o <= rd_label;
               rs1_label_id_ex_o <= rs1_label;
               rs2_label_id_ex_o <= rs2_label;
               is_memory_instruction_id_ex_o <= is_memory_instruction;
               is_load_instruction_id_ex_o <= is_load_instruction;
               funct3_id_ex_o <= funct3;
               funct7_id_ex_o <= funct7;
               is_load_instr_id_ex_o <= is_load_instr;
               is_store_instr_id_ex_o <= is_store_instr;
               is_branch_instr_id_ex_o <= is_branch_instr;
               is_jump_instr_id_ex_o <= is_jump_instr;
               opcode_id_ex_o <= instr_i[6:2];
            end else if(load_stall_o) begin
               pc_id_ex_o                     <= 30'd0;
               rs1_value_id_ex_o              <= 32'd0;
               rs2_value_id_ex_o              <= 32'd0;
               imm_value_id_ex_o              <= 32'd0;
               alu_op1_sel_id_ex_o            <= 0;
               alu_op2_sel_id_ex_o            <= 0;
               read_write_sel_id_ex_o         <= 4'd0;
               wb_sel_id_ex_o                 <= 2'd0;
               reg_wb_en_id_ex_o              <= 0;
               rd_id_ex_o                     <= 5'd0;
               rs1_label_id_ex_o              <= 5'd0;
               is_memory_instruction_id_ex_o  <= 1'b0;
               is_load_instruction_id_ex_o    <= 1'b0;
               funct3_id_ex_o                 <= 3'b0;
               funct7_id_ex_o                 <= 7'b0;
               is_load_instr_id_ex_o          <= 1'b0; 
               is_store_instr_id_ex_o         <= 1'b0;
               is_branch_instr_id_ex_o        <= 1'b0;
               is_jump_instr_id_ex_o          <= 0;
               opcode_id_ex_o                 <= 5'b0;
            end
          end
       end else begin
         pc_id_ex_o                     <= 30'd0;
         rs1_value_id_ex_o              <= 32'd0;
         rs2_value_id_ex_o              <= 32'd0;
         imm_value_id_ex_o              <= 32'd0;
         alu_op1_sel_id_ex_o            <= 0;
         alu_op2_sel_id_ex_o            <= 0;
         read_write_sel_id_ex_o         <= 4'd0;
         wb_sel_id_ex_o                 <= 2'd0;
         reg_wb_en_id_ex_o              <= 0;
         rd_id_ex_o                     <= 5'd0;
         rs1_label_id_ex_o              <= 5'd0;
         is_memory_instruction_id_ex_o  <= 1'b0;
         is_load_instruction_id_ex_o    <= 1'b0;
         funct3_id_ex_o                 <= 3'b0;
         funct7_id_ex_o                 <= 7'b0;
         is_load_instr_id_ex_o          <= 1'b0; 
         is_store_instr_id_ex_o         <= 1'b0;
         is_branch_instr_id_ex_o        <= 1'b0;
         is_jump_instr_id_ex_o          <= 0;
         opcode_id_ex_o                 <= 5'b0;
      end
    end
endmodule