
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
      input  clk,
      input  rst,
      input  [31:0] a,
      input  [31:0] b,
      input  start,
      output reg  [63:0] product,
      output reg done
);


reg [3:0] A [7:0];
reg [3:0] B [7:0];

// pseudo-reduction layers
reg [63:0] rl1 [14:0];
reg [63:0] rl2 [14:0];

reg [31:0] counter;


always @ (posedge clk) begin

      if(rst) counter <= 32'd0;
      else if(start & (counter > 32'd3)) counter <= 32'd0;
      else if(start) counter <= counter + 32'd1;
      else counter <= 32'd0;

      A[0] <= a[3:0];
      A[1] <= a[7:4];
      A[2] <= a[11:8];
      A[3] <= a[15:12];
      A[4] <= a[19:16];
      A[5] <= a[23:20];
      A[6] <= a[27:24];
      A[7] <= a[31:28];

      B[0] <= b[3:0];
      B[1] <= b[7:4];
      B[2] <= b[11:8];
      B[3] <= b[15:12];
      B[4] <= b[19:16];
      B[5] <= b[23:20];
      B[6] <= b[27:24];
      B[7] <= b[31:28];

//      rl1[0]  <= mult(A[0], B[0]);
//      rl1[1]  <= mult(A[0], B[1]) + mult(A[1], B[0]);
//      rl1[2]  <= mult(A[0], B[2]) + mult(A[1], B[1]) + mult(A[2], B[0]);
//      rl1[3]  <= mult(A[0], B[3]) + mult(A[1], B[2]) + mult(A[2], B[1]) + mult(A[3], B[0]);
//      rl1[4]  <= mult(A[0], B[4]) + mult(A[1], B[3]) + mult(A[2], B[2]) + mult(A[3], B[1]);
//      rl1[5]  <= mult(A[0], B[5]) + mult(A[1], B[4]) + mult(A[2], B[3]) + mult(A[3], B[2]);
//      rl1[6]  <= mult(A[0], B[6]) + mult(A[1], B[5]) + mult(A[2], B[4]) + mult(A[3], B[3]);
//      rl1[7]  <= mult(A[0], B[7]) + mult(A[1], B[6]) + mult(A[2], B[5]) + mult(A[3], B[4]);
//      rl1[8]  <= mult(A[1], B[7]) + mult(A[2], B[6]) + mult(A[3], B[5]) + mult(A[4], B[4]);
//      rl1[9]  <= mult(A[2], B[7]) + mult(A[3], B[6]) + mult(A[4], B[5]) + mult(A[5], B[4]);
//      rl1[10] <= mult(A[3], B[7]) + mult(A[4], B[6]) + mult(A[5], B[5]) + mult(A[6], B[4]);
//      rl1[11] <= mult(A[4], B[7]) + mult(A[5], B[6]) + mult(A[6], B[5]) + mult(A[7], B[4]);
//      rl1[12] <= mult(A[5], B[7]) + mult(A[6], B[6]) + mult(A[7], B[5]);
//      rl1[13] <= mult(A[6], B[7]) + mult(A[7], B[6]);
//      rl1[14] <= mult(A[7], B[7]);


      rl1[0]  <= A[0] * B[0];
      rl1[1]  <= A[0] * B[1] + A[1] * B[0];
      rl1[2]  <= A[0] * B[2] + A[1] * B[1] + A[2] * B[0];
      rl1[3]  <= A[0] * B[3] + A[1] * B[2] + A[2] * B[1] + A[3] * B[0];
      rl1[4]  <= A[0] * B[4] + A[1] * B[3] + A[2] * B[2] + A[3] * B[1];
      rl1[5]  <= A[0] * B[5] + A[1] * B[4] + A[2] * B[3] + A[3] * B[2];
      rl1[6]  <= A[0] * B[6] + A[1] * B[5] + A[2] * B[4] + A[3] * B[3];
      rl1[7]  <= A[0] * B[7] + A[1] * B[6] + A[2] * B[5] + A[3] * B[4];
      rl1[8]  <= A[1] * B[7] + A[2] * B[6] + A[3] * B[5] + A[4] * B[4];
      rl1[9]  <= A[2] * B[7] + A[3] * B[6] + A[4] * B[5] + A[5] * B[4];
      rl1[10] <= A[3] * B[7] + A[4] * B[6] + A[5] * B[5] + A[6] * B[4];
      rl1[11] <= A[4] * B[7] + A[5] * B[6] + A[6] * B[5] + A[7] * B[4];
      rl1[12] <= A[5] * B[7] + A[6] * B[6] + A[7] * B[5];
      rl1[13] <= A[6] * B[7] + A[7] * B[6];
      rl1[14] <= A[7] * B[7];

//      rl2[0] <= rl1[0];
//      rl2[1] <= rl1[1];
//      rl2[2] <= rl1[2];
//      rl2[3] <= rl1[3];
//      rl2[4] <= rl1[4] + mult(A[4], B[0]);
//      rl2[5] <= rl1[5] + mult(A[4], B[1]) + mult(A[5], B[0]);
//      rl2[6] <= rl1[6] + mult(A[4], B[2]) + mult(A[5], B[1]) + mult(A[6], B[0]);
//      rl2[7] <= rl1[7] + mult(A[4], B[3]) + mult(A[5], B[2]) + mult(A[6], B[1]) + mult(A[7], B[0]);
//      rl2[8] <= rl1[8] + mult(A[5], B[3]) + mult(A[6], B[2]) + mult(A[7], B[1]);
//      rl2[9] <= rl1[9] + mult(A[6], B[3]) + mult(A[7], B[2]);
//      rl2[10] <= rl1[10] + mult(A[7], B[3]);
//      rl2[11] <= rl1[11];
//      rl2[12] <= rl1[12];
//      rl2[13] <= rl1[13];
//      rl2[14] <= rl1[14];

      rl2[0]  <= rl1[0];
      rl2[1]  <= rl1[1];
      rl2[2]  <= rl1[2];
      rl2[3]  <= rl1[3];
      rl2[4]  <= rl1[4] + A[4] * B[0];
      rl2[5]  <= rl1[5] + A[4] * B[1] + A[5] * B[0];
      rl2[6]  <= rl1[6] + A[4] * B[2] + A[5] * B[1] + A[6] * B[0];
      rl2[7]  <= rl1[7] + A[4] * B[3] + A[5] * B[2] + A[6] * B[1] + A[7] * B[0];
      rl2[8]  <= rl1[8] + A[5] * B[3] + A[6] * B[2] + A[7] * B[1];
      rl2[9]  <= rl1[9] + A[6] * B[3] + A[7] * B[2];
      rl2[10] <= rl1[10] + A[7] * B[3];
      rl2[11] <= rl1[11];
      rl2[12] <= rl1[12];
      rl2[13] <= rl1[13];
      rl2[14] <= rl1[14];


      product <= (rl2[0] << 0) + (rl2[1] << 4) + (rl2[2] << 8) + (rl2[3] << 12) + (rl2[4] << 16) + (rl2[5] << 20) + (rl2[6] << 24) + (rl2[7] << 28) + (rl2[8] << 32) + (rl2[9] << 36) + (rl2[10] << 40) + (rl2[11] << 44) + (rl2[12] << 48) + (rl2[13] << 52) + (rl2[14] << 56);
      done <= (counter == 32'd3);
end






endmodule
