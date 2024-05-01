`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/01/2024 01:26:20 AM
// Design Name: 
// Module Name: cache_access_unit
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


module cache_access_unit(
   input clk_i, rst_i,
   input [1:0] addr_align_i,
   input [31:0] core_raw_data_i,
   input [31:0] cache_raw_data_i,
   input [3:0] op_type_i,
   output reg [3:0] write_en_o,
   output reg [31:0] core_normalized_data_o,
   output reg [31:0] cache_normalized_data_o,
   output reg busy_o
);

always @(posedge clk_i) begin
   if(rst_i) begin
      busy_o <= 1'b0;
   end else begin
      busy_o <= op_type_i[3] & !busy_o;
   end
end

always @(*) begin
   case(op_type_i)
      4'b1011: core_normalized_data_o = {4{core_raw_data_i[7:0]}};
      4'b1110: core_normalized_data_o = {2{core_raw_data_i[15:0]}};
      4'b1111: core_normalized_data_o = core_raw_data_i;
   endcase
end

always @(*) begin
   case(op_type_i)
      4'b1011: write_en_o = 4'b0001 << addr_align_i;
      4'b1110: write_en_o = addr_align_i[1] ? 4'b1100 : 4'b0011;
      4'b1111: write_en_o = 4'b1111;
      default: write_en_o = 4'b0000;
   endcase
end

wire [7:0] byte_a = cache_raw_data_i[7:0];
wire [7:0] byte_b = cache_raw_data_i[15:8];
wire [7:0] byte_c = cache_raw_data_i[23:16];
wire [7:0] byte_d = cache_raw_data_i[31:24];

wire [7:0] value_byte_tmp0 = addr_align_i[0] ? byte_b : byte_a;
wire [7:0] value_byte_tmp1 = addr_align_i[0] ? byte_d : byte_c;
wire [7:0] value_byte = addr_align_i[1] ? value_byte_tmp1 : value_byte_tmp0;

wire [31:0] value_byte_unsigned = {24'b0, value_byte};
wire [31:0] value_byte_signed = {{24{value_byte[7]}}, value_byte};

wire [15:0] half_ba = cache_raw_data_i[15:0];
wire [15:0] half_dc = cache_raw_data_i[31:16];

wire [15:0] value_half = addr_align_i[1] ? half_dc : half_ba;

wire [31:0] value_half_unsigned = {16'b0, value_half};
wire [31:0] value_half_signed = {{16{value_half[15]}}, value_half};

wire [31:0] value_word = cache_raw_data_i;

always @(*) begin
   case(op_type_i)
      4'b1000: cache_normalized_data_o = value_byte_signed;
      4'b1001: cache_normalized_data_o = value_half_signed;
      4'b1010: cache_normalized_data_o = value_word;
      4'b1100: cache_normalized_data_o = value_byte_unsigned;
      4'b1101: cache_normalized_data_o = value_half_unsigned;
   endcase
end

endmodule
