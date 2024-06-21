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
   
 // MSCRATCH TEST

//   wrapper.ram.data[0] = 128'h340fe0f3340f90730def8f930badcfb7;
//   wrapper.ram.data[1] = 128'h0000006f340021f3340ff173;

 //  MEM TEST

//   wrapper.ram.data[0] = 128'hfff141930800a103800015b7800000b7;
//   wrapper.ram.data[1] = 128'h02c1826302c104630805a6030830a023;
//   wrapper.ram.data[2] = 128'h00321a630800a20308d5a023fff64693;
//   wrapper.ram.data[3] = 128'h0000006f00100f9300d716630805a703;
//   wrapper.ram.data[4] = 128'h0000006ffff00f93;
   
//   wrapper.ram.data[8] = 128'h01010101;
//   wrapper.ram.data[264] = 128'hABABABAB;

   //BASEL BUBBLESORT
   
//   wrapper.ram.data[0] = 128'h00900213_00a00193_10000113_00000093;
//   wrapper.ram.data[1] = 128'h006100a3_00100313_00610023_00200313;
//   wrapper.ram.data[2] = 128'h006101a3_00500313_00610123_00300313;
//   wrapper.ram.data[3] = 128'h006102a3_00700313_00610223_00400313;  
//   wrapper.ram.data[4] = 128'h006103a3_00b00313_00610323_00600313;
//   wrapper.ram.data[5] = 128'h006104a3_00800313_00610423_00900313;
//   wrapper.ram.data[6] = 128'h002083b3_02408c63_00000093_04328463;  
//   wrapper.ram.data[7] = 128'h00945863_00070483_00138713_00038403;
//   wrapper.ram.data[8] = 128'h00900533_00000863_00970023_00838023;
//   wrapper.ram.data[9] = 128'hfc0006e3_00108093_00a38023_00870023;
//   wrapper.ram.data[10] = 128'h0000006f_fa000ee_300128293;



//    //BMU TEST
//    wrapper.ram.data[0] = 128'hdeadc2b7_0010c3b3_0010c333_0010c2b3;  // xori x6, x0, 0x ; lui x5, 0xdeadc ; xor x7, x1, x1 ; xor x6, x1, x1
//    wrapper.ram.data[1] = 128'h00200113_000aa0b7_006283b3_eef04313;  // addi x2, x0, 2 ; lui x1, 0x000AA ; addi x0, x0, 0 ; add x7, x5, x6
//    wrapper.ram.data[2] = 128'h00000013_fffff2b7_01f00213_06400193;  // addi x0, x0, 0 ; lui x5, 0xFFFFF ; addi x4, x0, 0x1 ; addi x3, x0, 0x6
//    wrapper.ram.data[3] = 128'h60209e93_60109f13_60009f93_00000013;  // cpop x29, x1 ; ctz x30, x1 ; clz x31, x1 ; addi x0, x0, 0
//    wrapper.ram.data[4] = 128'h60509c93_0803cd33_6983dd93_2870de13;  // sext.h x25, x1 ; zext.h x26, x7 ; rev8 x27, x7 ; orc.b x28, x1
//    wrapper.ram.data[5] = 128'h6021da93_6021db33_60219bb3_60439c13;  // rori x21, x3, 2 ; ror x22, x3, x2 ; rol x23, x3, x2 ; sext.b x24, x7
//    wrapper.ram.data[6] = 128'h49f29993_48429a33_49f2d893_4842d933;  // bclri x19, x5, 31 ; bclr x20, x5, x4 ; bexti x17, x5, 31 ; bext x18, x5, x4
//    wrapper.ram.data[7] = 128'h29f29693_28429733_69f29793_68429833;  // bseti x13, x5, 31 ; bset x14, x5, x4 ; binvi x15, x5, 31 ; binv x16, x5, x4
//    wrapper.ram.data[8] = 128'h40e3f4b3_20316533_203145b3_20312633;  // andn x9, x7, x14 ; sh3add x10, x3, x2 ; sh2add x11, x3, x2 ; sh1add x12, x3, x2
//    wrapper.ram.data[9] = 128'h00000013_0000006f_40f840b3_40e3e433;  // NOP ; jal x0, . ; xnor x1, x16, x15 ; orn x8, x7, x14
    


//  MDU icin Carpma ornegi
//    wrapper.ram.data[0] = 128'h021081b3_402000b3_00100113_00000093;  // mul x3, x1, x1  ; sub x1, x0, x2 ; addi x2,x0, 1    ;addi x1,x0,0
//    wrapper.ram.data[1] = 128'h0292a333_00800493_abcde2b7_0210b233;  // mulhsu x6 x5 x9 ; addi x9 x0 8   ; lui x5, 0xABCDE ;mulhu x4,x1,x1
//    wrapper.ram.data[2] = 128'h0233c5b3_0233d533_02734433_029293b3;  // div x11 x7 x3   ; divu x10 x7 x3 ; div x8 x6 x7    ;mulh x7 x5 x9

// Exception Test

    wrapper.ram.data[0] = 128'h00000000_00100073_00000073_305a5073;  
    wrapper.ram.data[1] = 128'h342021f3_00018113_00010093_0000006f;  
    wrapper.ram.data[2] = 128'h30200073_341f9073_004f8f93_34102ff3; 

end

always begin
    #1 CLK = ~CLK;
end


endmodule