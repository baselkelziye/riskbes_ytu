`timescale 1ns / 1ps

module pc_adder(
    input [31:0]in_i,
    input is_long,
    output [31:0]out_o
    );
    
    assign out_o = in_i + (is_long ? 32'd4 : 32'd2);
    
endmodule
