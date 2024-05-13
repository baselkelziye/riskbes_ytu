`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/13/2024 11:56:47 PM
// Design Name: 
// Module Name: cache_arbiter
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

//Bus'ı hangi önbelleğin kontrol edeceğini belirler.
module cache_arbiter(
   input clk_i,
   input rst_i,
   input bus_valid_i,
   input instr_cache_blocking_n_i,
   input instr_cache_flushing_n_i,
   input data_cache_flushing_n_i,
   output reg cache_sel_o //0 = Instruction Cache; 1 = Data Cache
);

   wire no_flush = cache_sel_o ? data_cache_flushing_n_i : instr_cache_flushing_n_i;
 
   always @(posedge clk_i) begin
      if (rst_i) begin
         cache_sel_o <= 0;
      end else if (bus_valid_i | no_flush) begin
         // I$ Blocking + D$ Flushing = I$
         // I$ Non-blocking + D$ Flushing = D$
         // I$ Blocking + D$ Non-flushing = I$
         // I$ Non-blocking + D$ Non-flushing = I$
         cache_sel_o <= instr_cache_blocking_n_i & !data_cache_flushing_n_i;
      end
   end
   
endmodule
