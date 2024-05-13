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
   input write_en_i,
   
   input [7:0] flush_data_i,
   input [BYTE_COUNT - 1 : 0] flushing_n_i
);

   genvar I;
   
   localparam BYTE_COUNT = 2 ** ADDR_WIDTH;
   
   reg [7:0] bytes [0 : BYTE_COUNT - 1];
   
   //Positive edge yazma
   generate
      for (I = 0; I < BYTE_COUNT; I = I + 1) begin
         always @(posedge clk_i) begin
            if (flushing_n_i[I]) begin
               if(write_en_i && (addr_w_i == I)) begin
                  bytes[I] <= data_i;
               end
            end else begin
               bytes[I] <= flush_data_i;
            end
         end
      end
   endgenerate
   
   //Negative edge okuma (data_cache.v)
   assign data_o = bytes[addr_r_i];
   
endmodule
