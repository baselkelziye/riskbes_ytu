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

   input stall_i,
   
   input branching_i,
   input [31:2] branch_target_i,
   
   output reg [31:2] pc_o
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

   always @(posedge clk_i) begin
      if(!rst_i) begin
         if(!stall_i) begin
            pc_o <= {1'b1, pc};

            if(branching_i) begin
               pc <= branch_target_i[30:2];
            end else begin
               pc <= pc_increment;
            end
         end
      end else begin
         pc <= 29'b0000_00000_00000_00000_00000_00000;
      end
   end

endmodule