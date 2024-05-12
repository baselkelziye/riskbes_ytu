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
   
   //Yazmayı bir çevrim geciktir
   reg [INDEX_WIDTH - 1 : 0] index_last;
   reg [OFFSET_WIDTH - 1 : 0] offset_last;
   reg [31:0] data_w_last;
   reg [3:0] write_en_last;
   
   localparam BLOCK_COUNT = 2 ** INDEX_WIDTH;
   
   wire [31:0] block_data [0 : BLOCK_COUNT - 1];
   
   genvar I;
   
   generate
      for (I = 0; I < BLOCK_COUNT; I = I + 1) begin
         wire [3:0] wen = index_last == I ? write_en_last : 4'b0;
         
         data_cache_qword_block #(
            .ADDR_WIDTH(OFFSET_WIDTH)
         ) block (
            .clk_i(clk_i),
            .addr_r_i(offset),
            .addr_w_i(offset_last),
            .data_i(data_w_last),
            .write_en_i(wen),
            .data_o(block_data[I])
         );
      end
   endgenerate 
   
   //Positive edge geciktirilmiş yazma (data_cache_byte_block.v)
   always @(posedge clk_i) begin
      index_last <= index;
      offset_last <= offset;
      write_en_last <= write_en_i;
      data_w_last <= data_i;
   end
   
   wire [31:0] data_r = block_data[index];
   
   //Negative edge okuma
   always @(negedge clk_i) begin
      if(index == index_last && offset == offset_last) begin //Eğer bunlar eşitse geciktirilmiş yazmayı aktar
         data_o[7:0] <= write_en_last[0] ? data_w_last[7:0] : data_r[7:0];
         data_o[15:8] <= write_en_last[1] ? data_w_last[15:8] : data_r[15:8];
         data_o[23:16] <= write_en_last[2] ? data_w_last[23:16] : data_r[23:16];
         data_o[31:24] <= write_en_last[3] ? data_w_last[31:24] : data_r[31:24];
      end else begin
         data_o <= data_r;
      end
   end
    
endmodule
