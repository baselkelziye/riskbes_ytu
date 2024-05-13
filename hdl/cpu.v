`timescale 1ns / 1ps
//TODO

//6.01.2023


//TEKNOFEST ICIN YAPILACAKLAR
//otomatik bi sekilde OBJ KODLARI OKUYUP INSTURCTION CACHE'e YERLESTIR
//memory erisiminde adres alignment bakilacak mi?
//resetleri aktif 0 yap
//Hazard detection yapinca aradaki komutu NOP yapmamiz gerekir mi?

module cpu #(
   parameter BUS_ADDRESS_WIDTH = 20,
   parameter BUS_DATA_WIDTH_SHIFT = 4
)(
   input clk_i,
   input rst_i,
   
   output [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] bus_addr_o,
   output [BUS_DATA_WIDTH - 1 : 0] bus_data_o,
   output bus_we_o,
   output bus_valid_o,
   
   input [BUS_DATA_WIDTH - 1 : 0] bus_data_i,
   input bus_valid_i
);

   localparam BUS_DATA_WIDTH = (2 ** BUS_DATA_WIDTH_SHIFT) * 8;

   reg instr_sel = 1'b0; //0 = I$, 1 = ROM 
    
   wire [31:2] icache_address;
   wire [31:0] icache_data;
   wire icache_blocking_n;
   wire [31:0] rom_data;
   
   wire [31:0] core_instr_data = instr_sel ? rom_data : icache_data;
   
   wire [31:2] dcache_address;
   wire [31:0] dcache_data_r, dcache_data_w;
   wire dcache_blocking_n;
   wire [3:0] dcache_write_en;
   wire dcache_en;
    
   core core(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .instr_cache_data_i(core_instr_data),
      .instr_cache_address_o(icache_address),
      .instr_cache_blocking_n_i(icache_blocking_n),
      
      .data_cache_data_i(dcache_data_r),
      .data_cache_data_o(dcache_data_w),
      .data_cache_address_o(dcache_address),
      .data_cache_write_en_o(dcache_write_en),
      .data_cache_blocking_n_i(dcache_blocking_n),
      .data_cache_enabled_o(dcache_en)
   );
   
   wire icache_flushing_n, dcache_flushing_n;
   
   wire [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] icache_bus_addr_o;
   wire [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] dcache_bus_addr_o;
  
   wire icache_bus_valid_i;
   wire dcache_bus_valid_i;
   
   wire icache_bus_valid_o, dcache_bus_valid_o;
   
   wire dcache_bus_we;
   
   cache_arbiter arbiter(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .icache_blocking_n_i(icache_blocking_n),
      .icache_flushing_n_i(icache_flushing_n),
      .dcache_flushing_n_i(dcache_flushing_n),
      
      .icache_bus_addr_i(icache_bus_addr_o),
      .dcache_bus_addr_i(dcache_bus_addr_o),
      .bus_addr_o(bus_addr_o),
      
      .dcache_bus_we_i(dcache_bus_we),
      .bus_we_o(bus_we_o),
      
      .icache_bus_valid_i(icache_bus_valid_o),
      .dcache_bus_valid_i(dcache_bus_valid_o),
      .bus_valid_o(bus_valid_o),
      
      .icache_bus_valid_o(icache_bus_valid_i),
      .dcache_bus_valid_o(dcache_bus_valid_i),
      .bus_valid_i(bus_valid_i)
   );
   
   instr_cache icache(
      .clk_i(clk_i),
      .rst_i(rst_i),
   
      .address_i(icache_address[BUS_ADDRESS_WIDTH - 1 : 2]),
      .data_o(icache_data),
      
      .bus_addr_o(icache_bus_addr_o),
      .bus_data_i(bus_data_i),     
      .bus_valid_i(icache_bus_valid_i),
      .bus_valid_o(icache_bus_valid_o),
      
      .blocking_n_o(icache_blocking_n),
      .flushing_n_o(icache_flushing_n)
   );
   
   internal_rom rom(
      .address_i(icache_address),
      .data_o(rom_data)
   );
   
   data_cache dcache(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .addr_i(dcache_address),
      .data_i(dcache_data_w),
      .write_en_i(dcache_write_en),
      .data_o(dcache_data_r),
      
      .blocking_n_o(dcache_blocking_n),
      .flushing_n_o(dcache_flushing_n),
      
      .bus_addr_o(dcache_bus_addr_o),
      .bus_data_i(bus_data_i),     
      .bus_valid_i(dcache_bus_valid_i),
      .bus_valid_o(dcache_bus_valid_o),
      
      .bus_data_o(bus_data_o),
      .bus_we_o(dcache_bus_we),
      
      .en_n_i(!dcache_en)
   );
   
   initial begin
      if (BUS_DATA_WIDTH != 128) begin
         $display("ONLY 128-BIT BUS SUPPORTED");
      end
   end
     
endmodule
