module instr_rom_new (
   input clk_i,

   input [30:2] addr_i, //İşlemcinin okuduğu adres
   output reg [31:0] instr_o //İşlemciye giden buyruk
);

reg [31:0] rom [0:1023];

always @(posedge clk_i) begin
   instr_o <= rom[addr_i[11:2]];
end
   
endmodule