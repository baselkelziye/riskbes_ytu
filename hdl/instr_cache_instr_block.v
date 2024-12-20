`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2024 06:45:10 PM
// Design Name: 
// Module Name: instr_cache_block
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


module instr_cache_instr_block #(
   parameter ADDR_WIDTH = 3
)(
   input clk_i,
   input rst_i,
   
   input [ADDR_WIDTH - 1 : 0] addr_i,
   output reg [31:2] instr_o,
  
   input [31:2] flush_instr_i,
   input [WORD_COUNT - 1 : 0] flushing_n_i
);
   genvar I;

   localparam BUS_DATA_WIDTH_SHIFT = 4;
   localparam WORD_COUNT = 2 ** ADDR_WIDTH;
   
   reg [31:2] words[0 : WORD_COUNT - 1];
   
   always @(*) begin
      instr_o = words[addr_i];
   end
   
   generate
      for(I = 0; I < WORD_COUNT; I = I + 1) begin
         always @(posedge clk_i) begin
            if(!flushing_n_i[I]) begin
               words[I] <= flush_instr_i;
            end
         end
      end
   endgenerate

endmodule
