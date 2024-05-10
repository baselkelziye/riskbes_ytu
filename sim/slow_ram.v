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
   
   output reg [DATA_WIDTH - 1 : 0] data_o,
   output valid_o
);

   localparam DATA_WIDTH = (2 ** DATA_WIDTH_SHIFT) * 8;


   latency_unit #(
      .LATENCY(LATENCY),
      .DATA_WIDTH(ADDRESS_WIDTH - DATA_WIDTH_SHIFT + 1)
   ) lu (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .data_i({addr_i, we_i}),
      .valid_o(valid_o)
   );
   
   localparam SIZE = (2 ** ADDRESS_WIDTH) / (DATA_WIDTH / 8);
   
   reg [DATA_WIDTH - 1 : 0] data [0 : SIZE - 1];
   
   always @(posedge valid_o) begin
      if(we_i) begin
         data[addr_i] = data_i;
      end
      
      data_o = data[addr_i];
   end

endmodule
