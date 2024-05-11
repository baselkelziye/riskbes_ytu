`timescale 1ns / 1ps

module cpu_tb();

reg CLK; 
reg RST;

localparam BUS_ADDRESS_WIDTH = 20;
localparam BUS_DATA_WIDTH_SHIFT = 4;

localparam BUS_DATA_WIDTH = (2 ** BUS_DATA_WIDTH_SHIFT) * 8;

wire [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] bus_addr;
wire [BUS_DATA_WIDTH - 1 : 0] bus_data_r, bus_data_w;
wire bus_we, bus_valid;

cpu #(
   .BUS_ADDRESS_WIDTH(BUS_ADDRESS_WIDTH),
   .BUS_DATA_WIDTH_SHIFT(BUS_DATA_WIDTH_SHIFT)
) u_cpu (
   .clk_i(CLK),
   .rst_i(RST),
   
   .bus_addr_o(bus_addr),
   
   .bus_data_i(bus_data_w),
   .bus_data_o(bus_data_r),
   
   .bus_we_o(bus_we),
   .bus_valid_i(bus_valid)
);

slow_ram #(
   .ADDRESS_WIDTH(BUS_ADDRESS_WIDTH),
   .DATA_WIDTH_SHIFT(BUS_DATA_WIDTH_SHIFT),
   .LATENCY(5)
) ram (
   .clk_i(CLK),
   .rst_i(RST),
   .addr_i(bus_addr),
   .data_i(bus_data_r),
   .data_o(bus_data_w),
   .we_i(bus_we),
   .valid_o(bus_valid)
);

initial begin

   //BUBBLESORT (BASEL)
   
   ram.data[0] = 128'h0090021300a001931000011300000093;
   ram.data[1] = 128'h006100a3001003130061002300200313;
   ram.data[2] = 128'h006101a3005003130061012300300313;
   ram.data[3] = 128'h006102a3007003130061022300400313;  
   ram.data[4] = 128'h006103a300b003130061032300600313;
   ram.data[5] = 128'h006104a3008003130061042300900313;
   ram.data[6] = 128'h002083b302408c630000009304328463;  
   ram.data[7] = 128'h00945863000704830013871300038403;
   ram.data[8] = 128'h00900533000008630097002300838023;
   ram.data[9] = 128'hfc0006e30010809300a3802300870023;
   ram.data[10] = 128'ha001fa000ee300128293;
   ram.data[11] = 128'hABCDEF;
   ram.data[12] = 128'hABCDEF;
   ram.data[13] = 128'hABCDEF;
   ram.data[14] = 128'hABCDEF;
   ram.data[15] = 128'hDEADC0DE;

    CLK = 1'b0;
    RST = 1'b1;
//    #5 RST = 1'b1;
    #10 RST = 1'b0;

end

always begin
    #1 CLK = ~CLK;
end


endmodule