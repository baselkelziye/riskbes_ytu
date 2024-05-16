`timescale 1ns / 1ps

module pc_adder(
    input [31:0]in_i,
    output [31:0]out_o
    );
    
    assign out_o = in_i + 32'd4;
    
endmodule
