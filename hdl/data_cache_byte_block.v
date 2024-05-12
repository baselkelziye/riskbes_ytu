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
   
   input [ADDR_WIDTH - 1 : 0] addr_r_i, //READ
   output [7:0] data_o,
   
   input [ADDR_WIDTH - 1 : 0] addr_w_i, //WRITE
   input [7:0] data_i,
   input write_en_i
);

localparam CACHE_SIZE = 2 ** ADDR_WIDTH;

reg [7:0] bytes [0 : CACHE_SIZE - 1];

//Positive edge yazma
always @(posedge clk_i) begin
   if(write_en_i) begin
      bytes[addr_w_i] <= data_i;
   end
end

//Negative edge okuma (data_cache.v)
assign data_o = bytes[addr_r_i];

//DEBUG AMAÇLI

integer I;

initial begin
   for(I = 0; I < CACHE_SIZE; I = I + 1) begin
      bytes[I] = 0;
   end
end

endmodule
