`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 06:13:44 PM
// Design Name: 
// Module Name: increment
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


module increment
    #(
        parameter DATA_WIDTH = 32
    )(
        input [DATA_WIDTH - 1 : 0] value_i,
        output [DATA_WIDTH - 1 : 0] value_o,
        output carry_o
    );
    
wire [DATA_WIDTH : 0] tmp = value_i + 1;
assign value_o = tmp[DATA_WIDTH - 1 : 0];
assign carry_o = tmp[DATA_WIDTH];

endmodule
