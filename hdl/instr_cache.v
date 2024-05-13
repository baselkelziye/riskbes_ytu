`timescale 1ns / 1ps

module instr_cache #(
   parameter INDEX_WIDTH = 4,
   parameter OFFSET_WIDTH = 5,
   parameter BUS_ADDRESS_WIDTH = 20
)(
   input clk_i,
   input rst_i,

   input [BUS_ADDRESS_WIDTH - 1 : 2] address_i, //İşlemcinin okuduğu adres
   output [31:0] data_o, //İşlemciye giden buyruk
   
   output [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] bus_addr_o,
   input [BUS_DATA_WIDTH - 1 : 0] bus_data_i,
   input bus_valid_i,
   
   output reg bus_valid_o,
   
   output blocking_n_o
);
   genvar I;   
   
   localparam BUS_DATA_WIDTH_SHIFT = 4;
   localparam BUS_DATA_WIDTH = (2 ** BUS_DATA_WIDTH_SHIFT) * 8;

   localparam OFFSET_MSB = OFFSET_WIDTH + 1;
   localparam INDEX_LSB = OFFSET_MSB + 1;
   localparam INDEX_MSB = INDEX_LSB + INDEX_WIDTH - 1;
   localparam TAG_LSB = INDEX_MSB + 1;
   localparam TAG_WIDTH = BUS_ADDRESS_WIDTH - TAG_LSB;
   
   wire access_valid;
   
   wire [TAG_WIDTH - 1 : 0] tag = address_i[BUS_ADDRESS_WIDTH - 1 : TAG_LSB];
   wire [INDEX_WIDTH - 1 : 0] index = address_i[INDEX_MSB : INDEX_LSB];
   wire [OFFSET_WIDTH - 1 : 0] offset = address_i[OFFSET_MSB : 2];
   
   localparam FLUSH_COUNTER_WIDTH = OFFSET_WIDTH - 2;
   
   reg flushing_n; //active low (0 = flushing, 1 = not flushing)
   wire [TAG_WIDTH - 1 : 0] flush_tag;
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
         //Flush başlat (Başlamak için kod yükle)   
         flushing_n <= 0;
         flush_index <= 0;
         block_tag[0] <= 0;
         block_valid[0] <= 1;
         flush_counter <= 0;
         bus_valid_o <= 1;
      end else begin
         if (flushing_n) begin
            //Flush yok
         
            if (!access_valid) begin
               //Flush başlat
               flushing_n <= 0;
               block_tag[index] <= tag;
               block_valid[index] <= 1;
               flush_index <= index;
               flush_counter <= 0;
               bus_valid_o <= 1;
            end
         end else begin
            // Flush var
            
            if (bus_valid_i) begin
               bus_valid_o <= 0;
            end else if (!bus_valid_o) begin
               flush_counter <= flush_counter_next;
               flushing_n <= flush_finish;
               bus_valid_o <= !flush_finish;
            end
         end
      end
   end
    
   localparam QWORD_PER_BLOCK_COUNT = 2 ** FLUSH_COUNTER_WIDTH;
    
   wire [QWORD_PER_BLOCK_COUNT - 1 : 0] qword_flushing_n;
   
   generate
      for (I = 0; I < QWORD_PER_BLOCK_COUNT; I = I + 1) begin
         assign qword_flushing_n[I] = flushing_n || flush_counter > I;
      end
   endgenerate
    
   localparam BLOCK_COUNT = 2 ** INDEX_WIDTH;
    
   wire [31:0] block_data [0 : BLOCK_COUNT - 1];
   
   reg [TAG_WIDTH - 1 : 0] block_tag [0 : BLOCK_COUNT - 1];
   assign flush_tag = block_tag[flush_index];
   
   reg block_valid [0 : BLOCK_COUNT - 1]; 
   assign access_valid = (tag == block_tag[index]) & block_valid[index];
   
   generate
      for (I = 0; I < BLOCK_COUNT; I = I + 1) begin
         wire [QWORD_PER_BLOCK_COUNT - 1 : 0] fn = flush_index == I ? qword_flushing_n : {QWORD_PER_BLOCK_COUNT{1'b1}};
      
         instr_cache_qword_block #(
            .ADDR_WIDTH(OFFSET_WIDTH)
         ) block (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .addr_i(offset),
            .data_o(block_data[I]),
            .flushing_n_i(fn),
            .flush_data_i(bus_data_i)
         );
         
         if (I != 0) begin
            always @(posedge clk_i) begin
               if (rst_i) begin
                  block_valid[I] <= 1'b0;
               end
            end
         end
      end
   endgenerate
   
   assign blocking_n_o = qword_flushing_n[offset[OFFSET_WIDTH - 1 : 2]] 
      | ((index != flush_index) & access_valid);
   assign data_o = block_data[index];
    
endmodule