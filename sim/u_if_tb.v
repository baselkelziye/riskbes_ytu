`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2024 06:42:49 PM
// Design Name: 
// Module Name: u_if_tb
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


module u_if_tb();

reg clk_i, rst_i, busywait, stall, flush;
wire [31:2] instr_o;
wire is_long_o;
wire [31:1] pc_o;

reg branching;
reg [31:1] branch_pc;

u_if u_if(
    clk_i,
    rst_i,
    
    busywait,
    stall,
    flush,
    
    branching,
    branch_pc,
    
    instr_o,
    is_long_o,
    pc_o);

initial begin
    flush = 0;
    busywait = 0;
    stall = 0;
    rst_i = 1;
    clk_i = 0;
    branching = 0;
    
    #3;
    
    rst_i = 0;
    
    #10;
    
    branch_pc = 0;
    branching = 1;
    #1 branching = 0;
    
    #9;
    
    branch_pc = 2;
    branching = 1;
    #1 branching = 0;
    
    #9;
    
    branch_pc = 3;
    branching = 1;
    #1 branching = 0;
    
    #10
    
    $finish;
end

always #1 clk_i = ~clk_i;

endmodule
