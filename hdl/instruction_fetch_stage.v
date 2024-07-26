`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2024 04:45:10 PM
// Design Name: 
// Module Name: instruction_fetch_stage
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


module instruction_fetch_stage(
   input clk_i,
   input rst_i,
   
   output [30:2] cache_address_o,
   input cache_blocking_n_i,

   input stall_i,
   
   input branching_i,
   input [31:2] branch_target_i,
   
   output reg [31:2] pc_o,

   output reg [1:0] branch_jump_op_o,
   output reg [2:0] imm_src_o
);
   localparam [31:2] INSTR_NOP = 30'b000000000000000000000000000100;
   localparam [1:0] BRANCH_JUMP_NOP = 2'b00;
   localparam [2:0] IMM_SRC_NOP = 3'bXXX;
   
   reg [30:2] pc;

   assign cache_address_o = pc;

   wire [30:2] pc_increment;
   wire pc_carry;
   
   increment #(.DATA_WIDTH(29)) u_pc_increment
   (
       .value_i(pc),
       .value_o(pc_increment),
       .carry_o(pc_carry)
   );

   wire [1:0] branch_jump_op;
   wire [2:0] imm_src;

   quick_decoder u_quick_decoder(
      .opcode_i(cache_data_i[6:2]),
      .branch_jump_op_o(branch_jump_op),
      .imm_src_o(imm_src)
   );

   always @(posedge clk_i) begin
      if(!rst_i) begin
         if(!stall_i) begin
            pc_o <= pc;

            if(branching_i) begin
               pc <= branch_target_i;

               branch_jump_op_o <= BRANCH_JUMP_NOP;
               imm_src_o <= IMM_SRC_NOP;
            end else if(cache_blocking_n_i) begin
               pc <= pc_increment;

               branch_jump_op_o <= branch_jump_op;
               imm_src_o <= imm_src;
            end else begin
               branch_jump_op_o <= BRANCH_JUMP_NOP;
               imm_src_o <= IMM_SRC_NOP;
            end
         end
      end else begin
         pc <= 29'b0000_00000_00000_00000_00000_00000;

         branch_jump_op_o <= BRANCH_JUMP_NOP;
         imm_src_o <= IMM_SRC_NOP;
      end
   end

endmodule