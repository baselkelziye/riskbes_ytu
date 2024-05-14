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
module cache_arbiter #(
   parameter BUS_ADDRESS_WIDTH = 20,
   parameter BUS_DATA_WIDTH_SHIFT = 4
)(
   input clk_i,
   input rst_i,
   
   input icache_blocking_n_i,
   input icache_flushing_n_i,
   input dcache_flushing_n_i,
   
   input [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] icache_bus_addr_i,
   input icache_bus_valid_i,
   output icache_bus_valid_o,
   
   input [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] dcache_bus_addr_i,
   input dcache_bus_we_i,
   input dcache_bus_valid_i,
   output dcache_bus_valid_o,
   
   output [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] bus_addr_o,
   output bus_we_o,
   output bus_valid_o,
   
   input bus_valid_i
);

   localparam BUS_DATA_WIDTH = (2 ** BUS_DATA_WIDTH_SHIFT) * 8;
   
   reg cache_sel; //0 = Instruction cache, 1 = Data cache
   // I$ Blocking + D$ Flushing = I$
   // I$ Non-blocking + D$ Flushing = D$
   // I$ Blocking + D$ Non-flushing = I$
   // I$ Non-blocking + D$ Non-flushing = I$
   wire cache_sel_next = icache_blocking_n_i & !dcache_flushing_n_i;
   reg updating;
   
   assign bus_addr_o = cache_sel ? dcache_bus_addr_i : icache_bus_addr_i;
   assign bus_valid_o = (cache_sel ? dcache_bus_valid_i : icache_bus_valid_i) & !updating;
   assign bus_we_o = cache_sel & dcache_bus_we_i;
   
   assign icache_bus_valid_o = !cache_sel & bus_valid_i;
   assign dcache_bus_valid_o = cache_sel & bus_valid_i;

   always @(negedge clk_i) begin
      if (rst_i) begin
         cache_sel <= 0; //I$
         updating <= 0;
      end else if (updating) begin
         if (!bus_valid_i) begin
            cache_sel <= cache_sel_next;
            updating <= 0;
         end
      end else begin
         if ((!bus_valid_o) & (cache_sel != cache_sel_next)) begin
            updating <= 1;
         end 
      end
   end
   
endmodule
