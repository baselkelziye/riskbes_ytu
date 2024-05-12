`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2024 05:39:11 PM
// Design Name: 
// Module Name: data_cache_qword_block
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


module data_cache_qword_block #(
   parameter ADDR_WIDTH = 5
)(
   input clk_i,
   input [ADDR_WIDTH - 1 : 0] addr_r_i,
   output [31:0] data_o,
   input [ADDR_WIDTH - 1 : 0] addr_w_i,
   input [31:0] data_i,
   input [3:0] write_en_i
);

   wire [1:0] sel_r = addr_r_i[1:0];
   wire [1:0] sel_w = addr_w_i[1:0];
   
   localparam SUB_ADDR_WIDTH = ADDR_WIDTH - 2;
   
   wire [SUB_ADDR_WIDTH - 1 : 0] sub_addr_r = addr_r_i[ADDR_WIDTH - 1 : 2];
   wire [SUB_ADDR_WIDTH - 1 : 0] sub_addr_w = addr_w_i[ADDR_WIDTH - 1 : 2];
   
   localparam SUB_COUNT = 4;
   
   wire [31:0] sub_data_r [0 : SUB_COUNT - 1];
   
   genvar I;
   
   generate
      for(I = 0; I < SUB_COUNT; I = I + 1) begin
         wire [3:0] wen = sel_w == I ? write_en_i : 4'b0;
      
         data_cache_word_block #(
            .ADDR_WIDTH(SUB_ADDR_WIDTH)
         ) sub (
            .clk_i(clk_i),
            .addr_r_i(sub_addr_r),
            .addr_w_i(sub_addr_w),
            .data_i(data_i),
            .write_en_i(wen),
            .data_o(sub_data_r[I])
         );
      end
   endgenerate

   assign data_o = sub_data_r[sel_r];

endmodule
