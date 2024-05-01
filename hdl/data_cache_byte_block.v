`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2024 06:14:13 PM
// Design Name: 
// Module Name: data_cache_byte_block
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


module data_cache_byte_block #(
   parameter ADDR_WIDTH = 3
)(
   input clk_i,
   input [ADDR_WIDTH - 1 : 0] addr_i,
   input [7:0] data_i,
   input write_en_i,
   output [7:0] data_o
);

localparam CACHE_SIZE = 2 ** ADDR_WIDTH;

reg [7:0] bytes [0:CACHE_SIZE - 1];

assign data_o = bytes[addr_i];

always @(clk_i) begin
   if(write_en_i) begin
      bytes[addr_i] <= data_i;
   end
end

integer I;

initial begin //DEBUG AMAÇLI
   for(I = 0; I < CACHE_SIZE; I = I + 1) begin
      bytes[I] = 0;
   end
end

endmodule
