`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2024 03:00:36 AM
// Design Name: 
// Module Name: csr_constant
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


module csr_zero #(
   parameter [11:0] ADDRESS = 0
)(
   input en_i,
   input [11:0] addr_i,
   output ack_o //Acknowledge sinyali
);

assign ack_o = en_i && (addr_i == ADDRESS);

endmodule
