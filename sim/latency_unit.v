`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2024 09:02:17 PM
// Design Name: 
// Module Name: latency_unit
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


// data_i değiştiğinde LATENCY sayıda çevrim olana kadar valid'i 0'a çeker
module latency_unit #(
   parameter LATENCY = 3,
   parameter DATA_WIDTH = 1
)(
   input clk_i, rst_i,
   input [DATA_WIDTH - 1 : 0] data_i,
   output valid_o
);

   reg [DATA_WIDTH - 1 : 0] data [0 : LATENCY];
   
   genvar I;
   
   generate
      for(I = 1; I <= LATENCY; I = I + 1) begin //Evet <= olacak < değil
         always @(posedge clk_i) begin
            if(rst_i) begin
               data[I] <= {DATA_WIDTH{1'bx}};
            end else begin
               data[I] <= data[I - 1];
            end
         end
      end
   endgenerate
   
   always @(*) begin
      data[0] = data_i;
   end
   
   assign valid_o = data_i == data[LATENCY];
   
endmodule
