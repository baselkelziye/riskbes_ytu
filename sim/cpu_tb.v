`timescale 1ns / 1ps

module cpu_tb();

reg CLK; 
reg RST;

my_wrapper wrapper(CLK, RST);

initial begin

   //UMUT TEST

//   wrapper.ram.data[0] = 128'h0010118300100103001000a300a00093;
//   wrapper.ram.data[1] = 128'h024283330ff00f93401202b300310233;
//   wrapper.ram.data[2] = 128'h028354b341e1843300100f13025313b3;
//   wrapper.ram.data[3] = 128'hf0100d9303d35e3300844eb302837533;  
//   wrapper.ram.data[4] = 128'h00100c3300001617000015b703b34d33;
//   wrapper.ram.data[5] = 128'h4020dc1300309c9300c0006f00100cb3;
//   wrapper.ram.data[6] = 128'h00e6e7b3019c2733018ca6b3ff9c0ce3;  
//   wrapper.ram.data[7] = 128'ha0010ff77813;

   //BASEL BUBBLESORT
   
   wrapper.ram.data[0] = 128'h0090021300a001931000011300000093;
   wrapper.ram.data[1] = 128'h006100a3001003130061002300200313;
   wrapper.ram.data[2] = 128'h006101a3005003130061012300300313;
   wrapper.ram.data[3] = 128'h006102a3007003130061022300400313;  
   wrapper.ram.data[4] = 128'h006103a300b003130061032300600313;
   wrapper.ram.data[5] = 128'h006104a3008003130061042300900313;
   wrapper.ram.data[6] = 128'h002083b302408c630000009304328463;  
   wrapper.ram.data[7] = 128'h00945863000704830013871300038403;
   wrapper.ram.data[8] = 128'h00900533000008630097002300838023;
   wrapper.ram.data[9] = 128'hfc0006e30010809300a3802300870023;
   wrapper.ram.data[10] = 128'ha001fa000ee300128293;
   wrapper.ram.data[11] = 128'hABCDEF;
   wrapper.ram.data[12] = 128'hABCDEF;
   wrapper.ram.data[13] = 128'hABCDEF;
   wrapper.ram.data[14] = 128'hABCDEF;
   wrapper.ram.data[15] = 128'hDEADC0DE;

    CLK = 1'b0;
    RST = 1'b1;

    #10 RST = 1'b0;
    #10000 RST = 1'b1;
    
   //ZAHİT ÇARPMA
    
   wrapper.ram.data[0] = 128'hc989450182aacd01a001201145b5452d;
   wrapper.ram.data[1] = 128'hf9ed028681859516000303630015f313;
   wrapper.ram.data[2] = 128'h00008082;
   
   #10 RST = 1'b0;
end

always begin
    #1 CLK = ~CLK;
end


endmodule