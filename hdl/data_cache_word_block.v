`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/30/2024 11:22:27 PM
// Design Name: 
// Module Name: data_cache_word_block
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


module data_cache_word_block #(
   parameter ADDR_WIDTH = 3
)(
   input clk_i,
   input [ADDR_WIDTH - 1 : 0] addr_i,
   input [31:0] data_i,
   input [3:0] write_en_i,
   output [31:0] data_o
);

   data_cache_byte_block #(
      .ADDR_WIDTH(ADDR_WIDTH)
   ) bytes_a (
      .clk_i(clk_i),
      .addr_i(addr_i),
      .data_i(data_i[7:0]),
      .write_en_i(write_en_i[0]),
      .data_o(data_o[7:0])
   );
   
   data_cache_byte_block #(
      .ADDR_WIDTH(ADDR_WIDTH)
   ) bytes_b (
      .clk_i(clk_i),
      .addr_i(addr_i),
      .data_i(data_i[15:8]),
      .write_en_i(write_en_i[1]),
      .data_o(data_o[15:8])
   );
   
   data_cache_byte_block #(
      .ADDR_WIDTH(ADDR_WIDTH)
   ) bytes_c (
      .clk_i(clk_i),
      .addr_i(addr_i),
      .data_i(data_i[23:16]),
      .write_en_i(write_en_i[2]),
      .data_o(data_o[23:16])
   );
   
   data_cache_byte_block #(
      .ADDR_WIDTH(ADDR_WIDTH)
   ) bytes_d (
      .clk_i(clk_i),
      .addr_i(addr_i),
      .data_i(data_i[31:24]),
      .write_en_i(write_en_i[3]),
      .data_o(data_o[31:24])
   );

endmodule
