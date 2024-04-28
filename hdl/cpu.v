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
    
   wire [31:2] icache_address;
   wire [31:0] icache_data;
    
   core core(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .instr_cache_data_i(icache_data),
      .instr_cache_address_o(icache_address)
   );
   
   instr_cache icache(
      .address_i(icache_address),
      .read_data_o(icache_data)
   );
     
endmodule
