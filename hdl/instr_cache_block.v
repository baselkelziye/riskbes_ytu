`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/26/2024 06:45:10 PM
// Design Name: 
// Module Name: instr_cache_block
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


module instr_cache_block(
   input [20:0] tag_i,
   input [4:0] offset_i,
   output reg [31:0] data_o,
   output valid_o
);

assign valid_o = 1'b1; //For now, it's always valid.

reg [31:0] cache[0:31];

always @(*) begin
   data_o = cache[offset_i];
end

endmodule
