`timescale 1ns / 1ps

module data_cache #(
   parameter INDEX_WIDTH = 4,
   parameter OFFSET_WIDTH = 5
)(
   input clk_i,
   input [31:2] addr_i,
   input [31:0] data_i,
   input [3:0] write_en_i,
   output reg [31:0] data_o
);
   
   localparam OFFSET_MSB = OFFSET_WIDTH + 1;
   localparam INDEX_LSB = OFFSET_MSB + 1;
   localparam INDEX_MSB = INDEX_LSB + INDEX_WIDTH - 1;
   localparam TAG_LSB = INDEX_MSB + 1;
   localparam TAG_WIDTH = 31 - TAG_LSB;
   
   wire [TAG_WIDTH - 1 : 0] tag = addr_i[30 : TAG_LSB];
   wire [INDEX_WIDTH - 1 : 0] index = addr_i[INDEX_MSB : INDEX_LSB];
   wire [OFFSET_WIDTH - 1 : 0] offset = addr_i[OFFSET_MSB : 2];
   
   localparam BLOCK_COUNT = 2 ** INDEX_WIDTH;
   
   wire [31:0] block_data [0 : BLOCK_COUNT - 1];
   
   genvar I;
   
   generate
      for (I = 0; I < BLOCK_COUNT; I = I + 1) begin
         wire [3:0] wen = index == I ? write_en_i : 4'b0;
         
         data_cache_qword_block #(
            .ADDR_WIDTH(OFFSET_WIDTH)
         ) block (
            .clk_i(clk_i),
            .addr_i(offset),
            .data_i(data_i),
            .write_en_i(wen),
            .data_o(block_data[I])
         );
      end
   endgenerate
   
   always @(*) begin
      data_o = block_data[index];
   end
    
endmodule
