`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/07/2024 04:50:47 PM
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
   input [1:0] sel_i,
   output [31:0] data_o
);

reg [31:0] data [0:3];

assign data_o = data[sel_i];

endmodule
