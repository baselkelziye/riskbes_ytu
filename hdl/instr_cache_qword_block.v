`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2024 05:08:45 PM
// Design Name: 
// Module Name: instr_cache_qword_block
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


module instr_cache_qword_block #(
   parameter ADDR_WIDTH = 5
)(
   input [ADDR_WIDTH - 1 : 0] addr_i,
   output [31:0] data_o
);

   wire [1:0] sel = addr_i[1:0];
   
   localparam SUB_ADDR_WIDTH = ADDR_WIDTH - 2;
   
   wire [SUB_ADDR_WIDTH - 1 : 0] sub_addr = addr_i[ADDR_WIDTH - 1 : 2];
   
   localparam SUB_COUNT = 4;
   
   wire [31:0] sub_data [0 : SUB_COUNT - 1];
   
   genvar I;
   
   generate
      for(I = 0; I < SUB_COUNT; I = I + 1) begin
         instr_cache_word_block #(
            .ADDR_WIDTH(SUB_ADDR_WIDTH)
         ) sub (
            .addr_i(sub_addr),
            .data_o(sub_data[I])
         );
      end
   endgenerate
   
   assign data_o = sub_data[sel];

endmodule
