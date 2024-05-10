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


module instr_cache_word_block #(
   parameter ADDR_WIDTH = 3
)(
   input clk_i,
   input rst_i,
   
   input [ADDR_WIDTH - 1 : 0] addr_i,
   output reg [31:0] data_o,
   
   input flushing_n_i,
   input [31:0] flush_data_i,
   input [ADDR_WIDTH - 1 : 0] flush_counter_i
);
   localparam BUS_DATA_WIDTH_SHIFT = 4;
   localparam WORD_COUNT = 2 ** ADDR_WIDTH;
   
   reg [31:0] words[0 : WORD_COUNT - 1];
   
   always @(*) begin
      data_o = words[addr_i];
   end
   
   always @(posedge clk_i) begin
      if(!flushing_n_i) begin
         words[flush_counter_i] = flush_data_i;
      end
   end

endmodule
