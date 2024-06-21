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
   input [1:0] branch_jump_op_i,
   input [2:0] imm_src_i,

   input busywait_i,
   input branching_i,
   
   input [31:0] rd_data_i,
   input [4:0] rd_label_i,

   input [31:2] pc_i,
   input stall_id_i,
   
   output load_stall_o,
   
   output reg [31:2] pc_o,
    
   output reg [31:0] rs1_value_o,
   output reg [31:0] rs2_value_o,  
   output reg [31:0] imm_value_o,      
  
   output reg alu_op1_sel_o,
   output reg alu_op2_sel_o,
   output reg [1:0] wb_sel_o,
   output reg [4:0] rd_o,
   output reg [4:0] rs1_label_o,
   output reg [4:0] rs2_label_o,   
   output reg is_load_instr_o,
   output reg is_store_instr_o,
   output reg is_mret_o,
   output reg [1:0] branch_jump_op_o,

   output reg [2:0] funct3_o,
   output reg [6:0] funct7_o,

   output reg [1:0] exception_o,
   output reg CSR_en_o,
   output reg [1:0] CSR_op_o,
   output reg CSR_source_sel_o,
   output reg [3:0] ALU_op_o ,
   output reg [4:0] BMU_op_o ,
   output reg MDU_en_o,
   output reg [2:0] MDU_op_o ,
   output reg [1:0] chip_select_o,
   output reg rs1_shift_sel_o,
   output reg rs2_negate_sel_o
);
   wire [6:2] opcode = instr_i[6:2];
   wire [2:0] funct3 = instr_i[14:12];
   wire [6:0] funct7 = instr_i[31:25];
   wire [4:0] rd_label = instr_i[11:7];
   wire [4:0] rs1_label = instr_i[19:15];
   wire [4:0] rs2_label = instr_i[24:20];

   //EX_Decoder sinyalleri, Sonra yukariya EX Stage sinyallerin altina Aynen tasinsin
   wire [1:0] chip_select;
   wire CSR_en;
   wire [1:0] CSR_op;
   wire CSR_source_sel;
   wire [1:0] exception;
   wire [3:0] ALU_op;
   wire [4:0] BMU_op;
   wire MDU_en;
   wire [2:0] MDU_op;
   wire rs1_shift_sel, rs2_negate_sel;
   wire is_load_instr, is_store_instr, is_mret;
   wire op1_sel;
   wire op2_sel;

   wire [1:0] wb_sel;
   wire reg_wr_en;
   wire is_load_instruction;

   full_decoder u_full_decoder(
      .instr_i(instr_i),

      .exception_o(exception),
      .CSR_en_o(CSR_en),
      .CSR_op_o(CSR_op),
      .CSR_source_sel_o(CSR_source_sel),
      .ALU_op_o(ALU_op),
      .BMU_op_o(BMU_op),
      .MDU_en_o(MDU_en),
      .MDU_op_o(MDU_op),
      .chip_select_o(chip_select),
      .rs1_shift_sel_o(rs1_shift_sel),
      .rs2_negate_sel_o(rs2_negate_sel),
      .reg_wr_en_o(reg_wr_en),
      .wb_sel_o(wb_sel),
      .op1_sel_o(op1_sel),
      .op2_sel_o(op2_sel),
      .is_load_instr_o(is_load_instr),
      .is_store_instr_o(is_store_instr),
      .is_mret_o(is_mret)
   );      

   wire [31:0] rs1_value, rs2_value;
   //Yazmaclarin durdugu yer
   regfile u_regfile
   (
      .clk_i(clk_i),
      .rst_i(rst_i),
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
       .is_load_instruction_ex_i(is_load_instr_o), // EX asamasinda LOAD islemi var
       .rd_label_ex_i(rd_o), // EX asamasinda RD
       .rs1_label_id_i(rs1_label), // ID rs1 numarasi
       .rs2_label_id_i(rs2_label), // ID rs2 numarasi

       .stall_o(load_stall_o)  // cikis stall sinyali
   );
   
   wire [31:0] imm;
   
   //Anlik genisletme birimi (umutun ara raporuna bakilmali)
   imm_gen u_imm_gen(
      .instr_i(instr_i[31:7]),
      .imm_src_i(imm_src_i),
      .imm_o(imm)
   );

   wire [4:0] rd_label_final;

   mux_2x1 #(
      .DATA_WIDTH(5)
   ) u_rd_label_sel(
      .in0(5'b0),
      .in1(rd_label),
      .select(reg_wr_en),
      .out(rd_label_final)
   );                   
    
   always @(posedge clk_i)begin
      if(!rst_i && !branching_i) begin
         if(!busywait_i) begin
            if(!stall_id_i)begin
               pc_o  <= pc_i;
               rs1_value_o <= rs1_value;
               rs2_value_o <= rs2_value;
               imm_value_o <= imm; 
               alu_op1_sel_o <= op1_sel;
               alu_op2_sel_o <= op2_sel;
               wb_sel_o <= wb_sel;
               rd_o <= rd_label_final;
               rs1_label_o <= rs1_label;
               rs2_label_o <= rs2_label;
               funct3_o <= funct3;
               funct7_o <= funct7;
               is_load_instr_o <= is_load_instr;
               is_store_instr_o <= is_store_instr;
               branch_jump_op_o <= branch_jump_op_i;
               exception_o <= exception;
               CSR_en_o <= CSR_en;
               CSR_op_o <= CSR_op;
               CSR_source_sel_o <= CSR_source_sel;
               ALU_op_o <= ALU_op;
               BMU_op_o <= BMU_op;
               MDU_en_o <= MDU_en;
               MDU_op_o <= MDU_op;
               chip_select_o <= chip_select;
               rs1_shift_sel_o <= rs1_shift_sel;
               rs2_negate_sel_o <= rs2_negate_sel;
               is_mret_o <= is_mret;
            end else if(load_stall_o) begin
               pc_o                     <= 0;
               rs1_value_o              <= 0;
               rs2_value_o              <= 0;
               imm_value_o              <= 0;
               alu_op1_sel_o            <= 0;
               alu_op2_sel_o            <= 0;
               wb_sel_o                 <= 0;
               rd_o                     <= 0;
               rs1_label_o              <= 0;
               funct3_o                 <= 0;
               funct7_o                 <= 0;
               is_load_instr_o          <= 0; 
               is_store_instr_o         <= 0;
               branch_jump_op_o         <= 0;
               exception_o              <= 0;
               CSR_en_o                 <= 0;
               CSR_op_o                 <= 0;
               CSR_source_sel_o         <= 0;
               ALU_op_o                 <= 0;
               BMU_op_o                 <= 0;
               MDU_en_o                 <= 0;
               MDU_op_o                 <= 0;
               chip_select_o            <= 0;
               rs1_shift_sel_o          <= 0;
               rs2_negate_sel_o         <= 0;
               is_mret_o                <= 0;
            end
          end
      end else begin
         pc_o                     <= 0;
         rs1_value_o              <= 0;
         rs2_value_o              <= 0;
         imm_value_o              <= 0;
         alu_op1_sel_o            <= 0;
         alu_op2_sel_o            <= 0;
         wb_sel_o                 <= 0;
         rd_o                     <= 0;
         rs1_label_o              <= 0;
         funct3_o                 <= 0;
         funct7_o                 <= 0;
         is_load_instr_o          <= 0; 
         is_store_instr_o         <= 0;
         branch_jump_op_o         <= 0;
         exception_o              <= 0;
         CSR_en_o                 <= 0;
         CSR_op_o                 <= 0;
         CSR_source_sel_o         <= 0;
         ALU_op_o                 <= 0;
         BMU_op_o                 <= 0;
         MDU_en_o                 <= 0;
         MDU_op_o                 <= 0;
         chip_select_o            <= 0;
         rs1_shift_sel_o          <= 0;
         rs2_negate_sel_o         <= 0;
         is_mret_o                <= 0;
      end
   end
endmodule