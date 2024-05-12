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
   input [ADDR_WIDTH - 1 : 0] addr_r_i,
   output [31:0] data_o,
   input [ADDR_WIDTH - 1 : 0] addr_w_i,
   input [31:0] data_i,
   input [3:0] write_en_i
);

   genvar I;
   
   localparam SUB_COUNT = 4;
   
   wire [7:0] sub_data_r [0 : SUB_COUNT - 1];
   
   assign sub_data_r[0] = data_i[7:0];
   assign sub_data_r[1] = data_i[15:8];
   assign sub_data_r[2] = data_i[23:16];
   assign sub_data_r[3] = data_i[31:24];
   
   wire [7:0] sub_data_w [0 : SUB_COUNT - 1];
   
   assign data_o[7:0] = sub_data_w[0];
   assign data_o[15:8] = sub_data_w[1];
   assign data_o[23:16] = sub_data_w[2];
   assign data_o[31:24] = sub_data_w[3];
   
   generate
      for(I = 0; I < SUB_COUNT; I = I + 1) begin
         data_cache_byte_block #(
            .ADDR_WIDTH(ADDR_WIDTH)
         ) sub (
            .clk_i(clk_i),
            .addr_r_i(addr_r_i),
            .addr_w_i(addr_w_i),
            .data_i(sub_data_r[I]),
            .write_en_i(write_en_i[I]),
            .data_o(sub_data_w[I])
         );
      end
   endgenerate

endmodule
