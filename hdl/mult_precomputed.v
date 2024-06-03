`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/03/2024 11:44:56 AM
// Design Name: 
// Module Name: mult_precomputed
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


module mult_precomputed(
    input [3:0] A0_i,
    input [3:0] A1_i,
    input [3:0] A2_i,
    input [3:0] A3_i,
    input [3:0] A4_i,
    input [3:0] A5_i,
    input [3:0] A6_i,
    input [3:0] A7_i,
    input [3:0] B0_i,
    input [3:0] B1_i,
    input [3:0] B2_i,
    input [3:0] B3_i,
    input [3:0] B4_i,
    input [3:0] B5_i,
    input [3:0] B6_i,
    input [3:0] B7_i,
    
    output [7:0] A0B0_o,
    output [7:0] A0B1_o,
    output [7:0] A0B2_o,
    output [7:0] A0B3_o,
    output [7:0] A0B4_o,
    output [7:0] A0B5_o,
    output [7:0] A0B6_o,
    output [7:0] A0B7_o,
    output [7:0] A1B0_o,
    output [7:0] A1B1_o,
    output [7:0] A1B2_o,
    output [7:0] A1B3_o,
    output [7:0] A1B4_o,
    output [7:0] A1B5_o,
    output [7:0] A1B6_o,
    output [7:0] A1B7_o,
    output [7:0] A2B0_o,
    output [7:0] A2B1_o,
    output [7:0] A2B2_o,
    output [7:0] A2B3_o,
    output [7:0] A2B4_o,
    output [7:0] A2B5_o,
    output [7:0] A2B6_o,
    output [7:0] A2B7_o,
    output [7:0] A3B0_o,
    output [7:0] A3B1_o,
    output [7:0] A3B2_o,
    output [7:0] A3B3_o,
    output [7:0] A3B4_o,
    output [7:0] A3B5_o,
    output [7:0] A3B6_o,
    output [7:0] A3B7_o,
    output [7:0] A4B4_o,
    output [7:0] A4B5_o,
    output [7:0] A4B6_o,
    output [7:0] A4B7_o,
    output [7:0] A5B4_o,
    output [7:0] A5B5_o,
    output [7:0] A5B6_o,
    output [7:0] A5B7_o,
    output [7:0] A6B4_o,
    output [7:0] A6B5_o,
    output [7:0] A6B6_o,
    output [7:0] A6B7_o,
    output [7:0] A7B4_o,
    output [7:0] A7B5_o,
    output [7:0] A7B6_o,
    output [7:0] A7B7_o,

    output [7:0] A4B0_o,
    output [7:0] A4B1_o,
    output [7:0] A4B2_o,
    output [7:0] A4B3_o,
    output [7:0] A5B0_o,
    output [7:0] A5B1_o,
    output [7:0] A5B2_o,
    output [7:0] A5B3_o,
    output [7:0] A6B0_o,
    output [7:0] A6B1_o,
    output [7:0] A6B2_o,
    output [7:0] A6B3_o,
    output [7:0] A7B0_o,
    output [7:0] A7B1_o,
    output [7:0] A7B2_o,
    output [7:0] A7B3_o
);

    
    reg [7:0] mul_ROM[255:0];
    
initial begin
    mul_ROM[{4'd15, 4'd15}] = 8'd225;
    mul_ROM[{4'd15, 4'd14}] = 8'd210;
    mul_ROM[{4'd15, 4'd13}] = 8'd195;
    mul_ROM[{4'd15, 4'd12}] = 8'd180;
    mul_ROM[{4'd15, 4'd11}] = 8'd165;
    mul_ROM[{4'd15, 4'd10}] = 8'd150;
    mul_ROM[{4'd15, 4'd9}] = 8'd135;
    mul_ROM[{4'd15, 4'd8}] = 8'd120;
    mul_ROM[{4'd15, 4'd7}] = 8'd105;
    mul_ROM[{4'd15, 4'd6}] = 8'd90;
    mul_ROM[{4'd15, 4'd5}] = 8'd75;
    mul_ROM[{4'd15, 4'd4}] = 8'd60;
    mul_ROM[{4'd15, 4'd3}] = 8'd45;
    mul_ROM[{4'd15, 4'd2}] = 8'd30;
    mul_ROM[{4'd15, 4'd1}] = 8'd15;
    mul_ROM[{4'd15, 4'd0}] = 8'd0;

    mul_ROM[{4'd14, 4'd15}] = 8'd210;
    mul_ROM[{4'd14, 4'd14}] = 8'd196;
    mul_ROM[{4'd14, 4'd13}] = 8'd182;
    mul_ROM[{4'd14, 4'd12}] = 8'd168;
    mul_ROM[{4'd14, 4'd11}] = 8'd154;
    mul_ROM[{4'd14, 4'd10}] = 8'd140;
    mul_ROM[{4'd14, 4'd9}] = 8'd126;
    mul_ROM[{4'd14, 4'd8}] = 8'd112;
    mul_ROM[{4'd14, 4'd7}] = 8'd98;
    mul_ROM[{4'd14, 4'd6}] = 8'd84;
    mul_ROM[{4'd14, 4'd5}] = 8'd70;
    mul_ROM[{4'd14, 4'd4}] = 8'd56;
    mul_ROM[{4'd14, 4'd3}] = 8'd42;
    mul_ROM[{4'd14, 4'd2}] = 8'd28;
    mul_ROM[{4'd14, 4'd1}] = 8'd14;
    mul_ROM[{4'd14, 4'd0}] = 8'd0;

    mul_ROM[{4'd13, 4'd15}] = 8'd195;
    mul_ROM[{4'd13, 4'd14}] = 8'd182;
    mul_ROM[{4'd13, 4'd13}] = 8'd169;
    mul_ROM[{4'd13, 4'd12}] = 8'd156;
    mul_ROM[{4'd13, 4'd11}] = 8'd143;
    mul_ROM[{4'd13, 4'd10}] = 8'd130;
    mul_ROM[{4'd13, 4'd9}] = 8'd117;
    mul_ROM[{4'd13, 4'd8}] = 8'd104;
    mul_ROM[{4'd13, 4'd7}] = 8'd91;
    mul_ROM[{4'd13, 4'd6}] = 8'd78;
    mul_ROM[{4'd13, 4'd5}] = 8'd65;
    mul_ROM[{4'd13, 4'd4}] = 8'd52;
    mul_ROM[{4'd13, 4'd3}] = 8'd39;
    mul_ROM[{4'd13, 4'd2}] = 8'd26;
    mul_ROM[{4'd13, 4'd1}] = 8'd13;
    mul_ROM[{4'd13, 4'd0}] = 8'd0;

    mul_ROM[{4'd12, 4'd15}] = 8'd180;
    mul_ROM[{4'd12, 4'd14}] = 8'd168;
    mul_ROM[{4'd12, 4'd13}] = 8'd156;
    mul_ROM[{4'd12, 4'd12}] = 8'd144;
    mul_ROM[{4'd12, 4'd11}] = 8'd132;
    mul_ROM[{4'd12, 4'd10}] = 8'd120;
    mul_ROM[{4'd12, 4'd9}] = 8'd108;
    mul_ROM[{4'd12, 4'd8}] = 8'd96;
    mul_ROM[{4'd12, 4'd7}] = 8'd84;
    mul_ROM[{4'd12, 4'd6}] = 8'd72;
    mul_ROM[{4'd12, 4'd5}] = 8'd60;
    mul_ROM[{4'd12, 4'd4}] = 8'd48;
    mul_ROM[{4'd12, 4'd3}] = 8'd36;
    mul_ROM[{4'd12, 4'd2}] = 8'd24;
    mul_ROM[{4'd12, 4'd1}] = 8'd12;
    mul_ROM[{4'd12, 4'd0}] = 8'd0;

    mul_ROM[{4'd11, 4'd15}] = 8'd165;
    mul_ROM[{4'd11, 4'd14}] = 8'd154;
    mul_ROM[{4'd11, 4'd13}] = 8'd143;
    mul_ROM[{4'd11, 4'd12}] = 8'd132;
    mul_ROM[{4'd11, 4'd11}] = 8'd121;
    mul_ROM[{4'd11, 4'd10}] = 8'd110;
    mul_ROM[{4'd11, 4'd9}] = 8'd99;
    mul_ROM[{4'd11, 4'd8}] = 8'd88;
    mul_ROM[{4'd11, 4'd7}] = 8'd77;
    mul_ROM[{4'd11, 4'd6}] = 8'd66;
    mul_ROM[{4'd11, 4'd5}] = 8'd55;
    mul_ROM[{4'd11, 4'd4}] = 8'd44;
    mul_ROM[{4'd11, 4'd3}] = 8'd33;
    mul_ROM[{4'd11, 4'd2}] = 8'd22;
    mul_ROM[{4'd11, 4'd1}] = 8'd11;
    mul_ROM[{4'd11, 4'd0}] = 8'd0;

    mul_ROM[{4'd10, 4'd15}] = 8'd150;
    mul_ROM[{4'd10, 4'd14}] = 8'd140;
    mul_ROM[{4'd10, 4'd13}] = 8'd130;
    mul_ROM[{4'd10, 4'd12}] = 8'd120;
    mul_ROM[{4'd10, 4'd11}] = 8'd110;
    mul_ROM[{4'd10, 4'd10}] = 8'd100;
    mul_ROM[{4'd10, 4'd9}] = 8'd90;
    mul_ROM[{4'd10, 4'd8}] = 8'd80;
    mul_ROM[{4'd10, 4'd7}] = 8'd70;
    mul_ROM[{4'd10, 4'd6}] = 8'd60;
    mul_ROM[{4'd10, 4'd5}] = 8'd50;
    mul_ROM[{4'd10, 4'd4}] = 8'd40;
    mul_ROM[{4'd10, 4'd3}] = 8'd30;
    mul_ROM[{4'd10, 4'd2}] = 8'd20;
    mul_ROM[{4'd10, 4'd1}] = 8'd10;
    mul_ROM[{4'd10, 4'd0}] = 8'd0;

    mul_ROM[{4'd9, 4'd15}] = 8'd135;
    mul_ROM[{4'd9, 4'd14}] = 8'd126;
    mul_ROM[{4'd9, 4'd13}] = 8'd117;
    mul_ROM[{4'd9, 4'd12}] = 8'd108;
    mul_ROM[{4'd9, 4'd11}] = 8'd99;
    mul_ROM[{4'd9, 4'd10}] = 8'd90;
    mul_ROM[{4'd9, 4'd9}] = 8'd81;
    mul_ROM[{4'd9, 4'd8}] = 8'd72;
    mul_ROM[{4'd9, 4'd7}] = 8'd63;
    mul_ROM[{4'd9, 4'd6}] = 8'd54;
    mul_ROM[{4'd9, 4'd5}] = 8'd45;
    mul_ROM[{4'd9, 4'd4}] = 8'd36;
    mul_ROM[{4'd9, 4'd3}] = 8'd27;
    mul_ROM[{4'd9, 4'd2}] = 8'd18;
    mul_ROM[{4'd9, 4'd1}] = 8'd9;
    mul_ROM[{4'd9, 4'd0}] = 8'd0;

    mul_ROM[{4'd8, 4'd15}] = 8'd120;
    mul_ROM[{4'd8, 4'd14}] = 8'd112;
    mul_ROM[{4'd8, 4'd13}] = 8'd104;
    mul_ROM[{4'd8, 4'd12}] = 8'd96;
    mul_ROM[{4'd8, 4'd11}] = 8'd88;
    mul_ROM[{4'd8, 4'd10}] = 8'd80;
    mul_ROM[{4'd8, 4'd9}] = 8'd72;
    mul_ROM[{4'd8, 4'd8}] = 8'd64;
    mul_ROM[{4'd8, 4'd7}] = 8'd56;
    mul_ROM[{4'd8, 4'd6}] = 8'd48;
    mul_ROM[{4'd8, 4'd5}] = 8'd40;
    mul_ROM[{4'd8, 4'd4}] = 8'd32;
    mul_ROM[{4'd8, 4'd3}] = 8'd24;
    mul_ROM[{4'd8, 4'd2}] = 8'd16;
    mul_ROM[{4'd8, 4'd1}] = 8'd8;
    mul_ROM[{4'd8, 4'd0}] = 8'd0;

    mul_ROM[{4'd7, 4'd15}] = 8'd105;
    mul_ROM[{4'd7, 4'd14}] = 8'd98;
    mul_ROM[{4'd7, 4'd13}] = 8'd91;
    mul_ROM[{4'd7, 4'd12}] = 8'd84;
    mul_ROM[{4'd7, 4'd11}] = 8'd77;
    mul_ROM[{4'd7, 4'd10}] = 8'd70;
    mul_ROM[{4'd7, 4'd9}] = 8'd63;
    mul_ROM[{4'd7, 4'd8}] = 8'd56;
    mul_ROM[{4'd7, 4'd7}] = 8'd49;
    mul_ROM[{4'd7, 4'd6}] = 8'd42;
    mul_ROM[{4'd7, 4'd5}] = 8'd35;
    mul_ROM[{4'd7, 4'd4}] = 8'd28;
    mul_ROM[{4'd7, 4'd3}] = 8'd21;
    mul_ROM[{4'd7, 4'd2}] = 8'd14;
    mul_ROM[{4'd7, 4'd1}] = 8'd7;
    mul_ROM[{4'd7, 4'd0}] = 8'd0;

    mul_ROM[{4'd6, 4'd15}] = 8'd90;
    mul_ROM[{4'd6, 4'd14}] = 8'd84;
    mul_ROM[{4'd6, 4'd13}] = 8'd78;
    mul_ROM[{4'd6, 4'd12}] = 8'd72;
    mul_ROM[{4'd6, 4'd11}] = 8'd66;
    mul_ROM[{4'd6, 4'd10}] = 8'd60;
    mul_ROM[{4'd6, 4'd9}] = 8'd54;
    mul_ROM[{4'd6, 4'd8}] = 8'd48;
    mul_ROM[{4'd6, 4'd7}] = 8'd42;
    mul_ROM[{4'd6, 4'd6}] = 8'd36;
    mul_ROM[{4'd6, 4'd5}] = 8'd30;
    mul_ROM[{4'd6, 4'd4}] = 8'd24;
    mul_ROM[{4'd6, 4'd3}] = 8'd18;
    mul_ROM[{4'd6, 4'd2}] = 8'd12;
    mul_ROM[{4'd6, 4'd1}] = 8'd6;
    mul_ROM[{4'd6, 4'd0}] = 8'd0;

    mul_ROM[{4'd5, 4'd15}] = 8'd75;
    mul_ROM[{4'd5, 4'd14}] = 8'd70;
    mul_ROM[{4'd5, 4'd13}] = 8'd65;
    mul_ROM[{4'd5, 4'd12}] = 8'd60;
    mul_ROM[{4'd5, 4'd11}] = 8'd55;
    mul_ROM[{4'd5, 4'd10}] = 8'd50;
    mul_ROM[{4'd5, 4'd9}] = 8'd45;
    mul_ROM[{4'd5, 4'd8}] = 8'd40;
    mul_ROM[{4'd5, 4'd7}] = 8'd35;
    mul_ROM[{4'd5, 4'd6}] = 8'd30;
    mul_ROM[{4'd5, 4'd5}] = 8'd25;
    mul_ROM[{4'd5, 4'd4}] = 8'd20;
    mul_ROM[{4'd5, 4'd3}] = 8'd15;
    mul_ROM[{4'd5, 4'd2}] = 8'd10;
    mul_ROM[{4'd5, 4'd1}] = 8'd5;
    mul_ROM[{4'd5, 4'd0}] = 8'd0;

    mul_ROM[{4'd4, 4'd15}] = 8'd60;
    mul_ROM[{4'd4, 4'd14}] = 8'd56;
    mul_ROM[{4'd4, 4'd13}] = 8'd52;
    mul_ROM[{4'd4, 4'd12}] = 8'd48;
    mul_ROM[{4'd4, 4'd11}] = 8'd44;
    mul_ROM[{4'd4, 4'd10}] = 8'd40;
    mul_ROM[{4'd4, 4'd9}] = 8'd36;
    mul_ROM[{4'd4, 4'd8}] = 8'd32;
    mul_ROM[{4'd4, 4'd7}] = 8'd28;
    mul_ROM[{4'd4, 4'd6}] = 8'd24;
    mul_ROM[{4'd4, 4'd5}] = 8'd20;
    mul_ROM[{4'd4, 4'd4}] = 8'd16;
    mul_ROM[{4'd4, 4'd3}] = 8'd12;
    mul_ROM[{4'd4, 4'd2}] = 8'd8;
    mul_ROM[{4'd4, 4'd1}] = 8'd4;
    mul_ROM[{4'd4, 4'd0}] = 8'd0;

    mul_ROM[{4'd3, 4'd15}] = 8'd45;
    mul_ROM[{4'd3, 4'd14}] = 8'd42;
    mul_ROM[{4'd3, 4'd13}] = 8'd39;
    mul_ROM[{4'd3, 4'd12}] = 8'd36;
    mul_ROM[{4'd3, 4'd11}] = 8'd33;
    mul_ROM[{4'd3, 4'd10}] = 8'd30;
    mul_ROM[{4'd3, 4'd9}] = 8'd27;
    mul_ROM[{4'd3, 4'd8}] = 8'd24;
    mul_ROM[{4'd3, 4'd7}] = 8'd21;
    mul_ROM[{4'd3, 4'd6}] = 8'd18;
    mul_ROM[{4'd3, 4'd5}] = 8'd15;
    mul_ROM[{4'd3, 4'd4}] = 8'd12;
    mul_ROM[{4'd3, 4'd3}] = 8'd9;
    mul_ROM[{4'd3, 4'd2}] = 8'd6;
    mul_ROM[{4'd3, 4'd1}] = 8'd3;
    mul_ROM[{4'd3, 4'd0}] = 8'd0;

    mul_ROM[{4'd2, 4'd15}] = 8'd30;
    mul_ROM[{4'd2, 4'd14}] = 8'd28;
    mul_ROM[{4'd2, 4'd13}] = 8'd26;
    mul_ROM[{4'd2, 4'd12}] = 8'd24;
    mul_ROM[{4'd2, 4'd11}] = 8'd22;
    mul_ROM[{4'd2, 4'd10}] = 8'd20;
    mul_ROM[{4'd2, 4'd9}] = 8'd18;
    mul_ROM[{4'd2, 4'd8}] = 8'd16;
    mul_ROM[{4'd2, 4'd7}] = 8'd14;
    mul_ROM[{4'd2, 4'd6}] = 8'd12;
    mul_ROM[{4'd2, 4'd5}] = 8'd10;
    mul_ROM[{4'd2, 4'd4}] = 8'd8;
    mul_ROM[{4'd2, 4'd3}] = 8'd6;
    mul_ROM[{4'd2, 4'd2}] = 8'd4;
    mul_ROM[{4'd2, 4'd1}] = 8'd2;
    mul_ROM[{4'd2, 4'd0}] = 8'd0;

    mul_ROM[{4'd1, 4'd15}] = 8'd15;
    mul_ROM[{4'd1, 4'd14}] = 8'd14;
    mul_ROM[{4'd1, 4'd13}] = 8'd13;
    mul_ROM[{4'd1, 4'd12}] = 8'd12;
    mul_ROM[{4'd1, 4'd11}] = 8'd11;
    mul_ROM[{4'd1, 4'd10}] = 8'd10;
    mul_ROM[{4'd1, 4'd9}] = 8'd9;
    mul_ROM[{4'd1, 4'd8}] = 8'd8;
    mul_ROM[{4'd1, 4'd7}] = 8'd7;
    mul_ROM[{4'd1, 4'd6}] = 8'd6;
    mul_ROM[{4'd1, 4'd5}] = 8'd5;
    mul_ROM[{4'd1, 4'd4}] = 8'd4;
    mul_ROM[{4'd1, 4'd3}] = 8'd3;
    mul_ROM[{4'd1, 4'd2}] = 8'd2;
    mul_ROM[{4'd1, 4'd1}] = 8'd1;
    mul_ROM[{4'd1, 4'd0}] = 8'd0;

    mul_ROM[{4'd0, 4'd15}] = 8'd0;
    mul_ROM[{4'd0, 4'd14}] = 8'd0;
    mul_ROM[{4'd0, 4'd13}] = 8'd0;
    mul_ROM[{4'd0, 4'd12}] = 8'd0;
    mul_ROM[{4'd0, 4'd11}] = 8'd0;
    mul_ROM[{4'd0, 4'd10}] = 8'd0;
    mul_ROM[{4'd0, 4'd9}] = 8'd0;
    mul_ROM[{4'd0, 4'd8}] = 8'd0;
    mul_ROM[{4'd0, 4'd7}] = 8'd0;
    mul_ROM[{4'd0, 4'd6}] = 8'd0;
    mul_ROM[{4'd0, 4'd5}] = 8'd0;
    mul_ROM[{4'd0, 4'd4}] = 8'd0;
    mul_ROM[{4'd0, 4'd3}] = 8'd0;
    mul_ROM[{4'd0, 4'd2}] = 8'd0;
    mul_ROM[{4'd0, 4'd1}] = 8'd0;
    mul_ROM[{4'd0, 4'd0}] = 8'd0;
end

    assign A0B0_o = mul_ROM[{A0_i, B0_i}];
    assign A0B1_o = mul_ROM[{A0_i, B1_i}];
    assign A0B2_o = mul_ROM[{A0_i, B2_i}];
    assign A0B3_o = mul_ROM[{A0_i, B3_i}];
    assign A0B4_o = mul_ROM[{A0_i, B4_i}];
    assign A0B5_o = mul_ROM[{A0_i, B5_i}];
    assign A0B6_o = mul_ROM[{A0_i, B6_i}];
    assign A0B7_o = mul_ROM[{A0_i, B7_i}];
    assign A1B0_o = mul_ROM[{A1_i, B0_i}];
    assign A1B1_o = mul_ROM[{A1_i, B1_i}];
    assign A1B2_o = mul_ROM[{A1_i, B2_i}];
    assign A1B3_o = mul_ROM[{A1_i, B3_i}];
    assign A1B4_o = mul_ROM[{A1_i, B4_i}];
    assign A1B5_o = mul_ROM[{A1_i, B5_i}];
    assign A1B6_o = mul_ROM[{A1_i, B6_i}];
    assign A1B7_o = mul_ROM[{A1_i, B7_i}];
    assign A2B0_o = mul_ROM[{A2_i, B0_i}];
    assign A2B1_o = mul_ROM[{A2_i, B1_i}];
    assign A2B2_o = mul_ROM[{A2_i, B2_i}];
    assign A2B3_o = mul_ROM[{A2_i, B3_i}];
    assign A2B4_o = mul_ROM[{A2_i, B4_i}];
    assign A2B5_o = mul_ROM[{A2_i, B5_i}];
    assign A2B6_o = mul_ROM[{A2_i, B6_i}];
    assign A2B7_o = mul_ROM[{A2_i, B7_i}];
    assign A3B0_o = mul_ROM[{A3_i, B0_i}];
    assign A3B1_o = mul_ROM[{A3_i, B1_i}];
    assign A3B2_o = mul_ROM[{A3_i, B2_i}];
    assign A3B3_o = mul_ROM[{A3_i, B3_i}];
    assign A3B4_o = mul_ROM[{A3_i, B4_i}];
    assign A3B5_o = mul_ROM[{A3_i, B5_i}];
    assign A3B6_o = mul_ROM[{A3_i, B6_i}];
    assign A3B7_o = mul_ROM[{A3_i, B7_i}];
    assign A4B4_o = mul_ROM[{A4_i, B4_i}];
    assign A4B5_o = mul_ROM[{A4_i, B5_i}];
    assign A4B6_o = mul_ROM[{A4_i, B6_i}];
    assign A4B7_o = mul_ROM[{A4_i, B7_i}];
    assign A5B4_o = mul_ROM[{A5_i, B4_i}];
    assign A5B5_o = mul_ROM[{A5_i, B5_i}];
    assign A5B6_o = mul_ROM[{A5_i, B6_i}];
    assign A5B7_o = mul_ROM[{A5_i, B7_i}];
    assign A6B4_o = mul_ROM[{A6_i, B4_i}];
    assign A6B5_o = mul_ROM[{A6_i, B5_i}];
    assign A6B6_o = mul_ROM[{A6_i, B6_i}];
    assign A6B7_o = mul_ROM[{A6_i, B7_i}];
    assign A7B4_o = mul_ROM[{A7_i, B4_i}];
    assign A7B5_o = mul_ROM[{A7_i, B5_i}];
    assign A7B6_o = mul_ROM[{A7_i, B6_i}];
    assign A7B7_o = mul_ROM[{A7_i, B7_i}];

    assign A4B0_o = mul_ROM[{A4_i, B0_i}];
    assign A4B1_o = mul_ROM[{A4_i, B1_i}];
    assign A4B2_o = mul_ROM[{A4_i, B2_i}];
    assign A4B3_o = mul_ROM[{A4_i, B3_i}];
    assign A5B0_o = mul_ROM[{A5_i, B0_i}];
    assign A5B1_o = mul_ROM[{A5_i, B1_i}];
    assign A5B2_o = mul_ROM[{A5_i, B2_i}];
    assign A5B3_o = mul_ROM[{A5_i, B3_i}];
    assign A6B0_o = mul_ROM[{A6_i, B0_i}];
    assign A6B1_o = mul_ROM[{A6_i, B1_i}];
    assign A6B2_o = mul_ROM[{A6_i, B2_i}];
    assign A6B3_o = mul_ROM[{A6_i, B3_i}];
    assign A7B0_o = mul_ROM[{A7_i, B0_i}];
    assign A7B1_o = mul_ROM[{A7_i, B1_i}];
    assign A7B2_o = mul_ROM[{A7_i, B2_i}];
    assign A7B3_o = mul_ROM[{A7_i, B3_i}];

endmodule
