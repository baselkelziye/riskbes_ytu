`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/14/2023 10:10:54 PM
// Design Name: 
// Module Name: branch_jump
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


module branch_jump(
   input [31:0] rs1_i,
   input [31:0] rs2_i,
   input is_mret_i,
   input [1:0] branch_jump_op_i,
   input [1:0] exception_i,
   input [2:0] funct3_i,
   output reg branching_o,
   output reg [1:0] target_sel_o
);

   localparam [1:0] ALU_TARGET   = 2'b00,
                    MTVEC_TARGET = 2'b01,
                    MEPC_TARGET  = 2'b10;

   localparam [2:0] BEQ_FUNCT3  = 3'b000,
                    BNE_FUNCT3  = 3'b001,
                    BLT_FUNCT3  = 3'b100,
                    BGE_FUNCT3  = 3'b101,
                    BLTU_FUNCT3 = 3'b110,
                    BGEU_FUNCT3 = 3'b111;

   wire beq_reg =  rs1_i == rs2_i ? 1 : 0;
   wire blt_reg =  $signed(rs1_i) < $signed(rs2_i) ? 1 : 0;
   wire bltu_reg = $unsigned(rs1_i) < $unsigned(rs2_i) ? 1 : 0;

   wire is_branch_instr = branch_jump_op_i[1];
   wire is_jump_instr = branch_jump_op_i[0];
   
   reg condition;

   always @(*) begin
      case(funct3_i)
         BEQ_FUNCT3:  condition = beq_reg;
         BNE_FUNCT3:  condition = ~beq_reg;
         BLT_FUNCT3:  condition = blt_reg;
         BGE_FUNCT3:  condition = ~blt_reg;
         BLTU_FUNCT3: condition = bltu_reg;
         BGEU_FUNCT3: condition = ~bltu_reg;
         default:     condition = 1'bX;
      endcase
   end

   wire has_exception = |exception_i;

   always @(*) begin
      branching_o = has_exception || is_jump_instr || (is_branch_instr && condition) || is_mret_i;
      if (has_exception) begin
         target_sel_o = MTVEC_TARGET;
      end else if (is_mret_i) begin
         target_sel_o = MEPC_TARGET;
      end else begin
         target_sel_o = ALU_TARGET;
      end
   end   
   
endmodule