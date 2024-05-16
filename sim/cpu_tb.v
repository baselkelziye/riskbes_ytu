`timescale 1ns / 1ps

module cpu_tb();

reg CLK; 
reg RST;

my_wrapper wrapper(CLK, RST);

initial begin

   #1
   CLK = 0;
   RST = 1;
   
   #10 RST = 0;

 //  MEM TEST

   wrapper.ram.data[0] = 128'hfff141930800a103800015b7800000b7;
   wrapper.ram.data[1] = 128'h02c1826302c104630805a6030830a023;
   wrapper.ram.data[2] = 128'h00321a630800a20308d5a023fff64693;
   wrapper.ram.data[3] = 128'h0000006f00100f9300d716630805a703;
   wrapper.ram.data[4] = 128'h0000006ffff00f93;
   
   wrapper.ram.data[8] = 128'h01010101;
   wrapper.ram.data[264] = 128'hABABABAB;
  
   
//   #5000 RST = 1;

   //BASEL BUBBLESORT
   
//   wrapper.ram.data[0] = 128'h0090021300a001931000011300000093;
//   wrapper.ram.data[1] = 128'h006100a3001003130061002300200313;
//   wrapper.ram.data[2] = 128'h006101a3005003130061012300300313;
//   wrapper.ram.data[3] = 128'h006102a3007003130061022300400313;  
//   wrapper.ram.data[4] = 128'h006103a300b003130061032300600313;
//   wrapper.ram.data[5] = 128'h006104a3008003130061042300900313;
//   wrapper.ram.data[6] = 128'h002083b302408c630000009304328463;  
//   wrapper.ram.data[7] = 128'h00945863000704830013871300038403;
//   wrapper.ram.data[8] = 128'h00900533000008630097002300838023;
//   wrapper.ram.data[9] = 128'hfc0006e30010809300a3802300870023;
//   wrapper.ram.data[10] = 128'hfa000ee300128293;
//   wrapper.ram.data[11] = 128'hABCDEF;
//   wrapper.ram.data[12] = 128'hABCDEF;
//   wrapper.ram.data[13] = 128'hABCDEF;
//   wrapper.ram.data[14] = 128'hABCDEF;
//   wrapper.ram.data[15] = 128'hDEADC0DE;


//   CLK = 0;
//   RST = 1;
//   #10 RST = 0;
end

always begin
    #1 CLK = ~CLK;
end


endmodule