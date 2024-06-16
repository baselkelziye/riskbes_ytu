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


module instr_cache_qinstr_block #(
   parameter ADDR_WIDTH = 5
)(
   input clk_i,
   input rst_i,
   
   input [ADDR_WIDTH - 1 : 0] addr_i,
   output [31:2] instr_o,
   
   input [31:2] flush_instr0_i, flush_instr1_i, flush_instr2_i, flush_instr3_i,

   input [QWORD_PER_BLOCK_COUNT - 1 : 0] flushing_n_i
);
   localparam QWORD_PER_BLOCK_COUNT = 2 ** SUB_ADDR_WIDTH;

   wire [1:0] sel = addr_i[1:0];
   
   localparam SUB_ADDR_WIDTH = ADDR_WIDTH - 2;
   
   wire [SUB_ADDR_WIDTH - 1 : 0] sub_addr = addr_i[ADDR_WIDTH - 1 : 2];

   localparam SUB_COUNT = 4;
   
   wire [31:2] sub_instr [0 : SUB_COUNT - 1];
   
   wire [31:2] flush_instr_list [0 : SUB_COUNT - 1];
   assign flush_instr_list[0] = flush_instr0_i;
   assign flush_instr_list[1] = flush_instr1_i;
   assign flush_instr_list[2] = flush_instr2_i;
   assign flush_instr_list[3] = flush_instr3_i;

   genvar I;
   
   generate
      for(I = 0; I < SUB_COUNT; I = I + 1) begin
         localparam FLUSH_LSB = I * 30;
         localparam FLUSH_MSB = FLUSH_LSB + 29;
      
         instr_cache_instr_block #(
            .ADDR_WIDTH(SUB_ADDR_WIDTH)
         ) sub (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .addr_i(sub_addr),
            .instr_o(sub_instr[I]),
            .flushing_n_i(flushing_n_i),
            .flush_instr_i(flush_instr_list[I])
         );
      end
   endgenerate
   
   assign instr_o = sub_instr[sel];

endmodule
