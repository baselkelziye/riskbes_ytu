`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2024 04:52:38 PM
// Design Name: 
// Module Name: data_cache_block
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


module data_cache_block(
   input clk_i,
   input [1:0] sel_i,
   input [31:0] data_i,
   input [3:0] write_en_i,
   output reg [31:0] data_o,
   
   input [31:0] dbg_initial_value_i
);

   reg [7:0] data_a [0:3];
   reg [7:0] data_b [0:3];
   reg [7:0] data_c [0:3];
   reg [7:0] data_d [0:3];
   
   always @(posedge clk_i) begin
      data_o <= {data_d[sel_i], data_c[sel_i], data_b[sel_i], data_a[sel_i]};
   
      if(write_en_i[0]) begin
         data_a[sel_i] <= data_i[7:0];
      end
      
      if(write_en_i[1]) begin
         data_b[sel_i] <= data_i[15:8];
      end
      
      if(write_en_i[2]) begin
         data_c[sel_i] <= data_i[23:16];
      end
      
      if(write_en_i[3]) begin
         data_d[sel_i] <= data_i[31:24];
      end
   end
   
   integer I;
   
   initial begin //DEBUG AMAÇLI
      for(I = 0; I < 4; I = I + 1) begin
         data_a[I] = 0;
         data_b[I] = 0;
         data_c[I] = 0;
         data_d[I] = 0;
      end
   end 

endmodule
