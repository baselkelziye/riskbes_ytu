`timescale 1ns / 1ps

module instr_cache #(
   parameter INDEX_WIDTH = 4,
   parameter OFFSET_WIDTH = 5
)(
   input [30:2]address_i, //Okunacak adresi
   output reg [31:0]read_data_o //okudugumuz veri
);
   localparam OFFSET_MSB = OFFSET_WIDTH + 1;
   localparam INDEX_LSB = OFFSET_MSB + 1;
   localparam INDEX_MSB = INDEX_LSB + INDEX_WIDTH - 1;
   localparam TAG_LSB = INDEX_MSB + 1;
   localparam TAG_WIDTH = 31 - TAG_LSB;

   wire [TAG_WIDTH - 1 : 0] tag = address_i[30 : TAG_LSB];
   wire [INDEX_WIDTH - 1 : 0] index = address_i[INDEX_MSB : INDEX_LSB];
   wire [OFFSET_WIDTH - 1 : 0] offset = address_i[OFFSET_MSB : 2];
    
   localparam BLOCK_COUNT = 2 ** INDEX_WIDTH;
    
   wire [31:0] block_data[0 : BLOCK_COUNT - 1];
    
   genvar I;
   
   generate
      for (I = 0; I < BLOCK_COUNT; I = I + 1) begin
         instr_cache_qword_block #(
            .ADDR_WIDTH(OFFSET_WIDTH)
         ) block (
            .addr_i(offset),
            .data_o(block_data[I])
         );
      end
   endgenerate
    
   always @(*) begin
      read_data_o = block_data[index];
   end
    
endmodule