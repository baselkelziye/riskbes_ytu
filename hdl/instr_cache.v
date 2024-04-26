`timescale 1ns / 1ps

module instr_cache(
   input [31:2]address_i, //Okunacak adresi
   output reg [31:0]read_data_o //okudugumuz veri
);
   wire [20:0] tag = address_i[31:11];
   wire [3:0] index = address_i[10:7];
   wire [4:0] offset = address_i[6:2];
    
   wire [31:0] block_data[0:15];
   wire block_valid[0:15];
    
   genvar I;
   
   generate
      for (I = 0; I < 16; I = I + 1) begin
         instr_cache_block cblock(
            .tag_i(tag),
            .offset_i(offset),
            .data_o(block_data[I]),
            .valid_o(block_valid[I])
         );
      end
   endgenerate
    
   always @(*) begin
      read_data_o = block_data[index];
   end
    
endmodule