`timescale 1ns / 1ps

module instr_cache #(
   parameter INDEX_WIDTH = 4,
   parameter OFFSET_WIDTH = 6,
   parameter BUS_ADDRESS_WIDTH = 20
)(
   input clk_i,
   input rst_i,

   input [BUS_ADDRESS_WIDTH - 1 : 2] address_i, //İşlemcinin okuduğu adres
   output [31:0] data_o, //İşlemciye giden buyruk
   
   output [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] bus_addr_o,
   input [BUS_DATA_WIDTH - 1 : 0] bus_data_i,
   input bus_valid_i,
   
   output flushing_n_o
);
   assign flushing_n_o = flushing_n;
   
   // FLUSHING MECHANISM
   
   localparam FLUSH_COUNTER_WIDTH = OFFSET_WIDTH - 2;
   
   reg flushing_n; //active low (0 = flushing, 1 = not flushing)
   reg [TAG_WIDTH - 1 : 0] flush_tag;
   reg [INDEX_WIDTH - 1 : 0] flush_index;
   reg [FLUSH_COUNTER_WIDTH - 1 : 0] flush_counter;
   
   wire [FLUSH_COUNTER_WIDTH - 1 : 0] flush_counter_next;
   wire flush_finish;
   
   increment #(
      .DATA_WIDTH(FLUSH_COUNTER_WIDTH)
   ) flush_counter_inc (
      .value_i(flush_counter),
      .value_o(flush_counter_next),
      .carry_o(flush_finish)
   );
   
   assign bus_addr_o = {flush_tag, flush_index, flush_counter};
   
   always @(posedge clk_i) begin
      if(rst_i) begin
         //DEBUG
         
         flushing_n = 0;
         flush_tag = 0;
         flush_index = 0;
         flush_counter = 0;
      end else begin
         if (bus_valid_i) begin
            flush_counter <= flush_counter_next;
         end
         
         flushing_n <= flushing_n | flush_finish;
      end
   end
   
   //FETCHING MECHANISM

   localparam BUS_DATA_WIDTH_SHIFT = 4;
   localparam BUS_DATA_WIDTH = (2 ** BUS_DATA_WIDTH_SHIFT) * 8;

   localparam OFFSET_MSB = OFFSET_WIDTH + 1;
   localparam INDEX_LSB = OFFSET_MSB + 1;
   localparam INDEX_MSB = INDEX_LSB + INDEX_WIDTH - 1;
   localparam TAG_LSB = INDEX_MSB + 1;
   localparam TAG_WIDTH = BUS_ADDRESS_WIDTH - TAG_LSB;

   wire [TAG_WIDTH - 1 : 0] tag = address_i[BUS_ADDRESS_WIDTH - 1 : TAG_LSB];
   wire [INDEX_WIDTH - 1 : 0] index = address_i[INDEX_MSB : INDEX_LSB];
   wire [OFFSET_WIDTH - 1 : 0] offset = address_i[OFFSET_MSB : 2];
    
   localparam BLOCK_COUNT = 2 ** INDEX_WIDTH;
    
   wire [31:0] block_data [0 : BLOCK_COUNT - 1];
    
   genvar I;
   
   generate
      for (I = 0; I < BLOCK_COUNT; I = I + 1) begin
         instr_cache_qword_block #(
            .ADDR_WIDTH(OFFSET_WIDTH)
         ) block (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .addr_i(offset),
            .data_o(block_data[I]),
            .flushing_n_i(flushing_n),
            .flush_data_i(bus_data_i),
            .flush_counter_i(flush_counter)
         );
      end
   endgenerate
   
   assign data_o = block_data[index];
    
endmodule