`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2024 08:51:38 PM
// Design Name: 
// Module Name: slow_ram
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


module slow_ram #(
   parameter ADDRESS_WIDTH = 20,
   parameter DATA_WIDTH_SHIFT = 4,
   parameter LATENCY = 3
)(
   input clk_i, rst_i,
   
   input [ADDRESS_WIDTH - DATA_WIDTH_SHIFT - 1 : 0] addr_i,
   input [DATA_WIDTH - 1 : 0] data_i,
   input we_i,
   input valid_i,
   
   output reg [DATA_WIDTH - 1 : 0] data_o,
   output reg valid_o
);

   localparam DATA_WIDTH = (2 ** DATA_WIDTH_SHIFT) * 8;
   
   localparam SIZE = (2 ** ADDRESS_WIDTH) / (DATA_WIDTH / 8);
   
   reg [DATA_WIDTH - 1 : 0] data [0 : SIZE - 1];
   reg valid_i_last;
   integer count;
   
   always @(posedge clk_i) begin
      valid_i_last <= valid_i;
   
      if(rst_i) begin
         count <= LATENCY;
      end else begin
         if (valid_i) begin
            if (count == 1) begin
               data_o <= data[addr_i];
               if (we_i) begin
                  data[addr_i] = data_i;
               end
               valid_o <= 1;
            end else begin
               count <= count - 1;
               data_o <= 'bx;
               if (we_i) begin
                  data[addr_i] = 'bx;
               end
               valid_o <= 0;
            end
         end else begin
            count <= LATENCY;
            valid_o <= 0;
         end
      end
   end
   
   always @(addr_i or we_i) begin
      if (valid_i & valid_i_last & !rst_i) begin
         $display("WARNING: slow_ram input changed while valid_i is high.");
      end
   end
   
   always @(data_i) begin
      if (we_i & valid_i & valid_i_last & !rst_i) begin
         $display("WARNING: slow_ram input changed while valid_i is high.");
      end
   end
   
   always @(negedge valid_i) begin
      if(!valid_o & !rst_i) begin
         $display("WARNING: slow_ram valid_i became low before valid_o became high.");
      end
   end
   
endmodule
