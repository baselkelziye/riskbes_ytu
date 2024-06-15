`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/11/2024 08:45:11 PM
// Design Name: 
// Module Name: wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module my_wrapper #(
   parameter RAM_LATENCY = 3
)(
   input clk_i,
   input rst_i
);

   localparam BUS_ADDRESS_WIDTH = 20;
   localparam BUS_DATA_WIDTH_SHIFT = 4;
   
   localparam BUS_DATA_WIDTH = (2 ** BUS_DATA_WIDTH_SHIFT) * 8;
   
   wire [BUS_ADDRESS_WIDTH - 1 : BUS_DATA_WIDTH_SHIFT] bus_addr;
   wire [BUS_DATA_WIDTH - 1 : 0] bus_data_r, bus_data_w;
   wire bus_we, bus_valid_r, bus_valid_w;
   
   cpu #(
      .BUS_ADDRESS_WIDTH(BUS_ADDRESS_WIDTH),
      .BUS_DATA_WIDTH_SHIFT(BUS_DATA_WIDTH_SHIFT)
   ) cpu (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .bus_addr_o(bus_addr),
      
      .bus_data_i(bus_data_w),
      .bus_data_o(bus_data_r),
      
      .bus_we_o(bus_we),
      
      .bus_valid_i(bus_valid_w),
      .bus_valid_o(bus_valid_r)
   );
   
   slow_ram #(
      .ADDRESS_WIDTH(BUS_ADDRESS_WIDTH),
      .DATA_WIDTH_SHIFT(BUS_DATA_WIDTH_SHIFT),
      .LATENCY(RAM_LATENCY)
   ) ram (
      .clk_i(clk_i),
      .rst_i(rst_i),
      .addr_i(bus_addr),
      .data_i(bus_data_r),
      .data_o(bus_data_w),
      .we_i(bus_we),
      .valid_i(bus_valid_r),
      .valid_o(bus_valid_w)
   );
   
   `ifdef COCOTB_SIM
initial begin
  $dumpfile ("dump.vcd");
  $dumpvars (0, my_wrapper);
  #1;
end
`endif

endmodule
