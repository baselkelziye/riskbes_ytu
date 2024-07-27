module instr_rom_new (
   input clk_i,

   input [30:2] addr_i, //İşlemcinin okuduğu adres
   output reg [31:0] instr_o //İşlemciye giden buyruk
);

reg [31:0] rom [0:1023];

always @(posedge clk_i) begin
   instr_o <= rom[addr_i[11:2]];
end

initial begin
   rom[0] = 32'h80000537;
   rom[1] = 32'h10050513;
   rom[2] = 32'h00000293;
   rom[3] = 32'h00550023;
   
   rom[4] = 32'h00100293;
   rom[5] = 32'h005500a3;
   rom[6] = 32'h00250513;
   rom[7] = 32'h00c00593;
   
   rom[8] = 32'hffe50283;
   rom[9] = 32'hfff50303;
   rom[10] = 32'h006282b3;
   rom[11] = 32'h00550023;
   
   rom[12] = 32'h00150513;
   rom[13] = 32'hfff58593;
   rom[14] = 32'hfe0594e3;
   rom[15] = 32'h0000006f;
end
   
endmodule