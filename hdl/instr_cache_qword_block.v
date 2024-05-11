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
   input clk_i,
   input rst_i,
   
   input [ADDR_WIDTH - 1 : 0] addr_i,
   output [31:0] data_o,
   
   input [127:0] flush_data_i,
   input [WORD_PER_BLOCK_COUNT - 1 : 0] flushing_n_i
);
   localparam WORD_PER_BLOCK_COUNT = 2 ** SUB_ADDR_WIDTH;

   localparam BUS_DATA_WIDTH_SHIFT = 4;

   wire [1:0] sel = addr_i[1:0];
   
   localparam SUB_ADDR_WIDTH = ADDR_WIDTH - 2;
   
   wire [SUB_ADDR_WIDTH - 1 : 0] sub_addr = addr_i[ADDR_WIDTH - 1 : 2];
   
   localparam SUB_COUNT = 4;
   
   wire [31:0] sub_data [0 : SUB_COUNT - 1];
   
   genvar I;
   
   generate
      for(I = 0; I < SUB_COUNT; I = I + 1) begin
         localparam FLUSH_LSB = I * 32;
         localparam FLUSH_MSB = FLUSH_LSB + 31;
      
         instr_cache_word_block #(
            .ADDR_WIDTH(SUB_ADDR_WIDTH)
         ) sub (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .addr_i(sub_addr),
            .data_o(sub_data[I]),
            .flushing_n_i(flushing_n_i),
            .flush_data_i(flush_data_i[FLUSH_MSB : FLUSH_LSB])
         );
      end
   endgenerate
   
   assign data_o = sub_data[sel];

endmodule
