`timescale 1ns / 1ps
//TODO

//6.01.2023


//TEKNOFEST ICIN YAPILACAKLAR
//otomatik bi sekilde OBJ KODLARI OKUYUP INSTURCTION CACHE'e YERLESTIR
//memory erisiminde adres alignment bakilacak mi?
//resetleri aktif 0 yap
//Hazard detection yapinca aradaki komutu NOP yapmamiz gerekir mi?

module cpu(
   input clk_i,
   input rst_i
);
    
   reg instr_sel = 1'b1; //0 = I$, 1 = ROM 
    
   wire [31:2] icache_address;
   wire [31:0] icache_data;
   wire [31:0] rom_data;
   
   wire [31:0] icache_rom_data = instr_sel ? rom_data : icache_data;
   
   wire [31:2] dcache_address;
   wire [31:0] dcache_rdata, dcache_wdata;
   wire [3:0] dcache_write_en;
    
   core core(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .instr_cache_data_i(icache_rom_data),
      .instr_cache_address_o(icache_address),
      
      .data_cache_data_i(dcache_rdata),
      .data_cache_data_o(dcache_wdata),
      .data_cache_address_o(dcache_address),
      .data_cache_write_en_o(dcache_write_en)
   );
   
   instr_cache icache(
      .address_i(icache_address),
      .read_data_o(icache_data)
   );
   
   internal_rom rom(
      .address_i(icache_address),
      .data_o(rom_data)
   );
   
   data_cache dcache(
      .clk_i(clk_i),
      .addr_i(dcache_address),
      .data_i(dcache_wdata),
      .write_en_i(dcache_write_en),
      .data_o(dcache_rdata)
   );
     
endmodule
