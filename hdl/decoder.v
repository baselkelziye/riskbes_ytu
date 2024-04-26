`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2024 04:46:38 PM
// Design Name: 
// Module Name: decoder
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


//Source: https://stackoverflow.com/questions/58192902/what-will-be-a-good-way-to-write-10bits-decoder
module decoder #(
  parameter InputSize  = 2,
  parameter OutputSize = 1 << InputSize
)
(
  input      [InputSize-1:0]    in_i,
  output reg [OutputSize-1:0]   out_o
);

  integer i;

  always @* begin
    // Use an unrollable loop.
    for (i = 0; i < OutputSize; i = i + 1) begin
      // (in_i == i) returns a 1-bit value
      out_o[i] = (in_i == i);
    end
  end

endmodule