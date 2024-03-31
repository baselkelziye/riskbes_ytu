`timescale 1ns / 1ps

module cpu_tb();

reg CLK; 
reg RST;

cpu u_cpu(  .clk_i(CLK),
            .rst_i(RST));


initial begin

    CLK = 1'b0;
    RST = 1'b1;
//    #5 RST = 1'b1;
    #10 RST = 1'b0;

   #10000 $finish;

end

always begin
    #1 CLK = ~CLK;
end


endmodule