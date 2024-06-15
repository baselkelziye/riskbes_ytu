
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/29/2024 06:02:15 PM
// Design Name: 
// Module Name: multiplier_unsigned
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
`timescale 1ns / 1ps
//`include "./mult_precomputed.sv"


module multiplier_unsigned (
      input  clk_i,
      input  rst_i,
      input  [31:0] a,
      input  [31:0] b,
      input  start,
      input a31_bit_i,
      input b31_bit_i,
      output reg a31_bit_o,
      output reg b31_bit_o,
      output reg  [63:0] product,
      output reg done
      
);


reg [3:0] A [7:0];
reg [3:0] B [7:0];

// pseudo-reduction layers
reg [63:0] rl1 [14:0];
reg [63:0] rl2 [14:0];

reg [31:0] counter;

reg [31:0] latched_a, latched_b;
//reg a31_reg, b31_reg;

//variable for pre-computed 
wire [7:0] mul_A0B0, mul_A0B1, mul_A0B2, mul_A0B3, mul_A0B4, mul_A0B5, mul_A0B6, mul_A0B7;
wire [7:0] mul_A1B0, mul_A1B1, mul_A1B2, mul_A1B3, mul_A1B4, mul_A1B5, mul_A1B6, mul_A1B7;
wire [7:0] mul_A2B0, mul_A2B1, mul_A2B2, mul_A2B3, mul_A2B4, mul_A2B5, mul_A2B6, mul_A2B7;
wire [7:0] mul_A3B0, mul_A3B1, mul_A3B2, mul_A3B3, mul_A3B4, mul_A3B5, mul_A3B6, mul_A3B7;
wire [7:0] mul_A4B4, mul_A4B5, mul_A4B6, mul_A4B7;
wire [7:0] mul_A5B4, mul_A5B5, mul_A5B6, mul_A5B7;
wire [7:0] mul_A6B4, mul_A6B5, mul_A6B6, mul_A6B7;
wire [7:0] mul_A7B4, mul_A7B5, mul_A7B6, mul_A7B7;

// Declare wire variables that were not defined before
wire [7:0] mul_A4B0, mul_A4B1, mul_A4B2, mul_A4B3;
wire [7:0] mul_A5B0, mul_A5B1, mul_A5B2, mul_A5B3;
wire [7:0] mul_A6B0, mul_A6B1, mul_A6B2, mul_A6B3;
wire [7:0] mul_A7B0, mul_A7B1, mul_A7B2, mul_A7B3;




always @* begin
      if(counter == 0) begin
            latched_a = a;
            latched_b = b;
            a31_bit_o = a31_bit_i;
            b31_bit_o = b31_bit_i;
      end
end
always @ (posedge clk_i) begin
      

      if(rst_i) counter <= 32'd0;
      else if(start & (counter > 32'd3)) counter <= 32'd0;
      else if(start) counter <= counter + 32'd1;
      else counter <= 32'd0;

      A[0] <= latched_a[3:0];
      A[1] <= latched_a[7:4];
      A[2] <= latched_a[11:8];
      A[3] <= latched_a[15:12];
      A[4] <= latched_a[19:16];
      A[5] <= latched_a[23:20];
      A[6] <= latched_a[27:24];
      A[7] <= latched_a[31:28];

      B[0] <= latched_b[3:0];
      B[1] <= latched_b[7:4];
      B[2] <= latched_b[11:8];
      B[3] <= latched_b[15:12];
      B[4] <= latched_b[19:16];
      B[5] <= latched_b[23:20];
      B[6] <= latched_b[27:24];
      B[7] <= latched_b[31:28];




        rl1[0]  <= mul_A0B0;
        rl1[1]  <= mul_A0B1 + mul_A1B0;
        rl1[2]  <= mul_A0B2 + mul_A1B1 + mul_A2B0;
        rl1[3]  <= mul_A0B3 + mul_A1B2 + mul_A2B1 + mul_A3B0;
        rl1[4]  <= mul_A0B4 + mul_A1B3 + mul_A2B2 + mul_A3B1;
        rl1[5]  <= mul_A0B5 + mul_A1B4 + mul_A2B3 + mul_A3B2;
        rl1[6]  <= mul_A0B6 + mul_A1B5 + mul_A2B4 + mul_A3B3;
        rl1[7]  <= mul_A0B7 + mul_A1B6 + mul_A2B5 + mul_A3B4;
        rl1[8]  <= mul_A1B7 + mul_A2B6 + mul_A3B5 + mul_A4B4;
        rl1[9]  <= mul_A2B7 + mul_A3B6 + mul_A4B5 + mul_A5B4;
        rl1[10] <= mul_A3B7 + mul_A4B6 + mul_A5B5 + mul_A6B4;
        rl1[11] <= mul_A4B7 + mul_A5B6 + mul_A6B5 + mul_A7B4;
        rl1[12] <= mul_A5B7 + mul_A6B6 + mul_A7B5;
        rl1[13] <= mul_A6B7 + mul_A7B6;
        rl1[14] <= mul_A7B7;



        rl2[0]  <= rl1[0];
        rl2[1]  <= rl1[1];
        rl2[2]  <= rl1[2];
        rl2[3]  <= rl1[3];
        rl2[4]  <= rl1[4] + mul_A4B0;
        rl2[5]  <= rl1[5] + mul_A4B1 + mul_A5B0;
        rl2[6]  <= rl1[6] + mul_A4B2 + mul_A5B1 + mul_A6B0;
        rl2[7]  <= rl1[7] + mul_A4B3 + mul_A5B2 + mul_A6B1 + mul_A7B0;
        rl2[8]  <= rl1[8] + mul_A5B3 + mul_A6B2 + mul_A7B1;
        rl2[9]  <= rl1[9] + mul_A6B3 + mul_A7B2;
        rl2[10] <= rl1[10] + mul_A7B3;
        rl2[11] <= rl1[11];
        rl2[12] <= rl1[12];
        rl2[13] <= rl1[13];
        rl2[14] <= rl1[14];


      product <= (rl2[0] << 0) + (rl2[1] << 4) + (rl2[2] << 8) + (rl2[3] << 12) + (rl2[4] << 16) + (rl2[5] << 20) + (rl2[6] << 24) + (rl2[7] << 28) + (rl2[8] << 32) + (rl2[9] << 36) + (rl2[10] << 40) + (rl2[11] << 44) + (rl2[12] << 48) + (rl2[13] << 52) + (rl2[14] << 56);
      done <= (counter == 32'd3);
end




mult_precomputed u_mult_precomputed(
    .A0_i(A[0]),
    .A1_i(A[1]),
    .A2_i(A[2]),
    .A3_i(A[3]),
    .A4_i(A[4]),
    .A5_i(A[5]),
    .A6_i(A[6]),
    .A7_i(A[7]),
    .B0_i(B[0]),
    .B1_i(B[1]),
    .B2_i(B[2]),
    .B3_i(B[3]),
    .B4_i(B[4]),
    .B5_i(B[5]),
    .B6_i(B[6]),
    .B7_i(B[7]),
    .A0B0_o(mul_A0B0),
    .A0B1_o(mul_A0B1),
    .A0B2_o(mul_A0B2),
    .A0B3_o(mul_A0B3),
    .A0B4_o(mul_A0B4),
    .A0B5_o(mul_A0B5),
    .A0B6_o(mul_A0B6),
    .A0B7_o(mul_A0B7),
    .A1B0_o(mul_A1B0),
    .A1B1_o(mul_A1B1),
    .A1B2_o(mul_A1B2),
    .A1B3_o(mul_A1B3),
    .A1B4_o(mul_A1B4),
    .A1B5_o(mul_A1B5),
    .A1B6_o(mul_A1B6),
    .A1B7_o(mul_A1B7),
    .A2B0_o(mul_A2B0),
    .A2B1_o(mul_A2B1),
    .A2B2_o(mul_A2B2),
    .A2B3_o(mul_A2B3),
    .A2B4_o(mul_A2B4),
    .A2B5_o(mul_A2B5),
    .A2B6_o(mul_A2B6),
    .A2B7_o(mul_A2B7),
    .A3B0_o(mul_A3B0),
    .A3B1_o(mul_A3B1),
    .A3B2_o(mul_A3B2),
    .A3B3_o(mul_A3B3),
    .A3B4_o(mul_A3B4),
    .A3B5_o(mul_A3B5),
    .A3B6_o(mul_A3B6),
    .A3B7_o(mul_A3B7),
    .A4B4_o(mul_A4B4),
    .A4B5_o(mul_A4B5),
    .A4B6_o(mul_A4B6),
    .A4B7_o(mul_A4B7),
    .A5B4_o(mul_A5B4),
    .A5B5_o(mul_A5B5),
    .A5B6_o(mul_A5B6),
    .A5B7_o(mul_A5B7),
    .A6B4_o(mul_A6B4),
    .A6B5_o(mul_A6B5),
    .A6B6_o(mul_A6B6),
    .A6B7_o(mul_A6B7),
    .A7B4_o(mul_A7B4),
    .A7B5_o(mul_A7B5),
    .A7B6_o(mul_A7B6),
    .A7B7_o(mul_A7B7),
    .A4B0_o(mul_A4B0),
    .A4B1_o(mul_A4B1),
    .A4B2_o(mul_A4B2),
    .A4B3_o(mul_A4B3),
    .A5B0_o(mul_A5B0),
    .A5B1_o(mul_A5B1),
    .A5B2_o(mul_A5B2),
    .A5B3_o(mul_A5B3),
    .A6B0_o(mul_A6B0),
    .A6B1_o(mul_A6B1),
    .A6B2_o(mul_A6B2),
    .A6B3_o(mul_A6B3),
    .A7B0_o(mul_A7B0),
    .A7B1_o(mul_A7B1),
    .A7B2_o(mul_A7B2),
    .A7B3_o(mul_A7B3)
);



endmodule
