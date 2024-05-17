`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 08:49:01 PM
// Design Name: 
// Module Name: internal_rom
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


module internal_rom(
   input [31:2] address_i,
   output reg [31:0] data_o
);

reg [31:0] rom [0:4096];

always @(*) begin
   data_o = rom[address_i];
end

initial begin //BUBBLESORT
   rom[0] = 32'h80000437;
   rom[1] = 32'h832242d1;
   rom[2] = 32'h00532023;
   rom[3] = 32'h031112fd;
   
   rom[4] = 32'hfe029ce3;
   rom[5] = 32'h45d18522;
   rom[6] = 32'h42d1200d;
   rom[7] = 32'h43858322;
   
   rom[8] = 32'h00032e03;
   rom[9] = 32'h007e1963;
   rom[10] = 32'h031112fd;
   rom[11] = 32'h99e30385;
   
   rom[12] = 32'h4f85fe02;
   rom[13] = 32'h5ffda001;
   rom[14] = 32'h4281a001;
   rom[15] = 32'h8613832a;
   
   rom[16] = 32'h2383fff5;
   rom[17] = 32'h26830003;
   rom[18] = 32'hd7630043;
   rom[19] = 32'h22230076;
   
   rom[20] = 32'h20230073;
   rom[21] = 32'h428500d3;
   rom[22] = 32'h167d0311;
   rom[23] = 32'h9ee3f27d;
   
   rom[24] = 32'h8082fc02;
//   rom[25] = 32'h80000437;
//   rom[26] = 32'h80000437;
//   rom[27] = 32'h80000437;
end

endmodule
