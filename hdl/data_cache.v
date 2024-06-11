`timescale 1ns / 1ps

module data_cache #(
   parameter INDEX_WIDTH = 4,
   parameter OFFSET_WIDTH = 5,
   parameter BUS_ADDRESS_WIDTH = 20
)(
   input clk_i,
   input rst_i,
   input [31:2] addr_i,
   input [31:0] data_i,
   input en_i, //Hafıza işlemi yapılmıyor
   input [3:0] write_en_i,
   output reg [31:0] data_o,
   
   output blocking_n_o,
   output flushing_n_o,
   
   output [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] bus_addr_o,
   input [BUS_DATA_WIDTH - 1 : 0] bus_data_i,
   input bus_valid_i, 
   output reg bus_valid_o,
   
   output bus_we_o,
   output reg [BUS_DATA_WIDTH - 1 : 0] bus_data_o
);
   genvar I;

   localparam BUS_DATA_WIDTH_SHIFT = 4;
   localparam BUS_DATA_WIDTH = (2 ** BUS_DATA_WIDTH_SHIFT) * 8;

   localparam OFFSET_MSB = OFFSET_WIDTH + 1;
   localparam INDEX_LSB = OFFSET_MSB + 1;
   localparam INDEX_MSB = INDEX_LSB + INDEX_WIDTH - 1;
   localparam TAG_LSB = INDEX_MSB + 1;
   localparam TAG_WIDTH = BUS_ADDRESS_WIDTH - TAG_LSB;
   
   localparam FLUSH_COUNTER_WIDTH = OFFSET_WIDTH - 2;
   
   wire blocking_n;
   
   wire access_valid = ((tag == block_tag[index]) && block_valid[index]) || !en_i; //Erişeceğimiz hücre önbellekte yüklü veya erişim yapılmıyor

   wire [TAG_WIDTH - 1 : 0] tag = addr_i[30 : TAG_LSB];
   wire [INDEX_WIDTH - 1 : 0] index = addr_i[INDEX_MSB : INDEX_LSB];
   wire [OFFSET_WIDTH - 1 : 0] offset = addr_i[OFFSET_MSB : 2];  
   
   localparam BLOCK_COUNT = 2 ** INDEX_WIDTH;
   
   wire [127:0] block_qword [0 : BLOCK_COUNT - 1];
   wire [31:0] block_data [0 : BLOCK_COUNT - 1];
   
   reg [TAG_WIDTH - 1 : 0] block_tag [0 : BLOCK_COUNT - 1];
   reg block_valid [0 : BLOCK_COUNT - 1];
   
   generate
      for(I = 0; I < BLOCK_COUNT; I = I + 1) begin
         always @(posedge clk_i) begin
            if(rst_i) begin
               block_valid[I] <= 0;
            end
         end
      end
   endgenerate
   
   //Yazmayı bir çevrim geciktir
   reg [TAG_WIDTH - 1 : 0] tag_last;
   reg [INDEX_WIDTH - 1 : 0] index_last;
   reg [OFFSET_WIDTH - 1 : 0] offset_last;
   reg [31:0] data_w_last;
   reg [3:0] write_en_last;
   reg en_last;
   wire delayed_access_valid = ((tag_last == block_tag[index_last]) && block_valid[index_last]) || !en_last;
   
   reg flushing_n; //active low (0 = flushing, 1 = not flushing)
   assign flushing_n_o = flushing_n;
   
   reg [TAG_WIDTH - 1 : 0] flush_tag_old;
   wire [TAG_WIDTH - 1 : 0] flush_tag = block_tag[flush_index];
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
    
   localparam QWORD_PER_BLOCK_COUNT = 2 ** FLUSH_COUNTER_WIDTH;
   
   wire [QWORD_PER_BLOCK_COUNT - 1 : 0] block_qword_dirty [0 : BLOCK_COUNT - 1];
    
   wire [QWORD_PER_BLOCK_COUNT - 1 : 0] qword_flushing_n;
   
   wire qword_dirty_first = block_qword_dirty[index][0];
   wire qword_dirty_next = block_qword_dirty[flush_index][flush_counter + 1];
   reg dirty, cleaned_n;
   
   generate
      for (I = 0; I < QWORD_PER_BLOCK_COUNT; I = I + 1) begin
         assign qword_flushing_n[I] = flushing_n || flush_counter > I;
      end
   endgenerate
    
   wire [TAG_WIDTH - 1 : 0] bus_tag = dirty ? flush_tag_old : flush_tag;
   assign bus_addr_o = {bus_tag, flush_index, flush_counter};
   assign bus_we_o = dirty;
   
   reg start_flushing;
   reg blocking_n_last;
    
   always @(posedge clk_i) begin
      blocking_n_last <= blocking_n;

      if (rst_i) begin
         //Tazeleme yapma
         start_flushing <= 0;
         flushing_n <= 1;
         bus_valid_o <= 0;
         en_last <= 0; //"Bir önceki çevrimde önbellek kullanılmıyordu" olarak ayarlanacak
         flush_index <= 0;
      end else begin
         if (flushing_n) begin
            //Flush yok
            
            //Buyruk önbelleğinden farklı olarak
            //tazeleme başlatmadan önce
            //bir çevrim kadar beklememiz gerekiyor
            
            //Bunun iki sebebi var:
            // 1) Geciktirilmiş yazmanın bitmesini beklemeliyiz.
            // 2) Çekirdek hafıza okuma işlemlerini negedge'de yapıyor.
            //    Buradaki okuma da negedge'de yapıldığı için
            //    arada bir çevrimlik gecikme oluşuyor
            //    Hafıza okuma işleminin bitmesini beklemeliy
            if (start_flushing) begin      
               // Yeni tazeleme başlat
               
               flushing_n <= 0;
               start_flushing <= 0;
               flush_index <= index;
               flush_counter <= 0;
               bus_data_o <= block_qword[index];   
               bus_valid_o <= 1;
               flush_tag_old <= block_tag[index];
               block_tag[index] <= tag;
               block_valid[index] <= 1;
               dirty <= qword_dirty_first;
               cleaned_n <= qword_dirty_first;   
            end else if (!access_valid) begin
               // Tazelemeye başlamaya hazırlan
               
               start_flushing <= 1;
            end
         end else begin
            //Flush var
            
            if (bus_valid_i) begin
               bus_valid_o <= 0;
               cleaned_n <= 0;
            end else if (!bus_valid_o) begin
               if(!dirty) begin
                  flushing_n <= flush_finish;
                  flush_counter <= flush_counter_next;
                  bus_data_o <= block_qword[flush_index];       
                  bus_valid_o <= ~flush_finish;        
                  dirty <= qword_dirty_next;
                  cleaned_n <= qword_dirty_next;
               end else begin
                  dirty <= 0;
                  bus_valid_o <= 1;
               end
            end
         end
         
         //Positive edge geciktirilmiş yazma (data_cache_byte_block.v)
         if (blocking_n_last) begin
            tag_last <= tag;
            index_last <= index;
            offset_last <= offset;
            write_en_last <= write_en_i;
            data_w_last <= data_i;
            en_last <= en_i & blocking_n;
         end
      end
   end
   
   generate   
      for (I = 0; I < BLOCK_COUNT; I = I + 1) begin
         localparam SUB_COUNT = 4;
      
         wire [QWORD_PER_BLOCK_COUNT - 1 : 0] fn = flush_index == I ? qword_flushing_n : {QWORD_PER_BLOCK_COUNT{1'b1}};
         wire [3:0] wen = ((index_last == I) && delayed_access_valid && en_last) ? write_en_last : 4'b0;
         
         wire [31:0] data [0 : SUB_COUNT - 1];
         
         wire [OFFSET_WIDTH - 3 : 0] addr_r = 
            clk_i ? 
            flush_counter : //Posedge okuma -> Tazeleme
            blocking_n ? //Negedge okuma -> Veri okuma
               offset[OFFSET_WIDTH - 1 : 2] : 
               offset_last[OFFSET_WIDTH - 1 : 2];
         
         data_cache_qword_block #(
            .ADDR_WIDTH(OFFSET_WIDTH)
         ) block (
            .clk_i(clk_i),
            .rst_i(rst_i),
            .addr_r_i(addr_r),
            .addr_w_i(offset_last),
            .data_i(data_w_last),
            .write_en_i(wen),
            .flush_data_i(bus_data_i),
            .flushing_n_i(fn),
            .data0_o(data[0]),
            .data1_o(data[1]),
            .data2_o(data[2]),
            .data3_o(data[3]),
            .dirty_o(block_qword_dirty[I]),
            .cleaned_n_i(cleaned_n)
         );
         
         assign block_qword[I] = {data[3], data[2], data[1], data[0]};
         assign block_data[I] = data[offset[1:0]]; 
      end
   endgenerate 
   
   wire [INDEX_WIDTH - 1 : 0] index_r = blocking_n ? index : index_last;
   wire [31:0] data_r = block_data[index_r];
   wire forward = index == index_last && offset == offset_last;
   
   //Okuma
   always @(negedge clk_i) begin
      data_o[7:0] <= (write_en_last[0] && forward) ? data_w_last[7:0] : data_r[7:0];
      data_o[15:8] <= (write_en_last[1] && forward) ? data_w_last[15:8] : data_r[15:8];
      data_o[23:16] <= (write_en_last[2] && forward) ? data_w_last[23:16] : data_r[23:16];
      data_o[31:24] <= (write_en_last[3] && forward) ? data_w_last[31:24] : data_r[31:24];
   end
    
   assign blocking_n = 
      !start_flushing //Tazeleme başlamak üzere değil
      & (qword_flushing_n[offset[OFFSET_WIDTH - 1 : 2]] | (index != flush_index))  //Erişeceğimiz hücre taze
      & access_valid //Erişeceğimiz hücre geçerli
      & delayed_access_valid; //Bir önceki hücrenin erişimi tamamlanmaya hazır. 
   
   assign blocking_n_o = blocking_n;
    
endmodule
