`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/18/2024 04:16:18 PM
// Design Name: 
// Module Name: instruction_decode_stage
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


module instruction_decode_stage(
   input [31:2] instr_i
);

control_unit control_unit(
   .opcode_i(instr_i[6:2]),
   .funct3_i(instr_i[14:12]),
   .funct7_i(instr_i[31:25])
);

endmodule
