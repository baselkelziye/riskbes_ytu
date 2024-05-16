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
   
   input [31:2] cache_data_i,
   output [31:2] cache_address_o,
   input cache_blocking_n_i,
   
   output ins_busywait_o,
   input stall_i,
   
   input branching,
   input [31:1] branch_pc,
   
   output reg [31:2] instr_o,
   output reg [31:2] pc_o
);
   reg branched;
   
   assign ins_busywait_o = branched ^ branching;
   
   localparam FETCH_WIDTH = 29;
   localparam [31:2] INSTR_NOP = 30'b000000000000000000000000000100;
   
   reg [FETCH_WIDTH - 1:0] fetch_counter;
   assign cache_address_o = fetch_counter;
   
   wire [FETCH_WIDTH - 1:0] fetch_counter_next;
   wire fetch_counter_carry;
   
   wire [31:2] branch_fetch_counter = branch_pc[31:2];
   wire branch_aligned_n = branch_pc[1];
   
   increment #(.DATA_WIDTH(FETCH_WIDTH)) fetch_counter_inc
   (
       .value_i(fetch_counter),
       .value_o(fetch_counter_next),
       .carry_o(fetch_counter_carry)
   );

   always @(posedge clk_i) begin
      if(!rst_i) begin
         if(!stall_i) begin
            if(cache_blocking_n_i) begin         
               branched <= branching;
               
               if(branching) begin
                  fetch_counter <= branch_fetch_counter;
                  instr_o <= INSTR_NOP;
               end else begin
                  fetch_counter <= fetch_counter_next;
                  instr_o <= cache_data_i;
               end
                 
               pc_o <= fetch_counter;
            end else begin
               instr_o <= INSTR_NOP;
            end
         end
      end else begin
         fetch_counter <= {FETCH_WIDTH{1'b0}};
         instr_o <= INSTR_NOP;
      end
   end

endmodule