`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2024 02:40:18 AM
// Design Name: 
// Module Name: csr_mstatus
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


module csr_mstatus(
    input clk_i,
    input rst_i,
    input en_i,

    input [11:0] addr_i,
    input [31:0] set_i,
    input [31:0] clear_i,

    output [31:0] read_o,
    output ack_o //Acknowledge sinyali
);

   localparam ADDRESS = 12'h300;
   
   wire ack = en_i && (addr_i == ADDRESS);
   assign ack_o = ack;
   
   wire ZERO = 0;
   wire ONE = ack;
   
   wire w_mie;
   csrfield u_mie(
      .clk_i(clk_i),
      .rst_i(rst_i),

      .en_i(ack),
      .set_i(set_i[3]),
      .clear_i(clear_i[3]),
      .read_o(w_mie),
      .value_o()
   );
   
   wire w_mpie;
   csrfield u_mpie(
      .clk_i(clk_i),
      .rst_i(rst_i),

      .en_i(ack),
      .set_i(set_i[7]),
      .clear_i(clear_i[7]),
      .read_o(w_mpie),
      .value_o()
   );
   
   wire w_sd = 0;
   wire [1:0] w_xs = 0;
   wire [1:0] w_fs = 0;

   assign read_o = {
      w_sd,
      {14{ZERO}},
      w_xs,
      w_fs,
      {2{ONE}},
      {3{ZERO}},
      w_mpie,
      {3{ZERO}},
      w_mie,
      {3{ZERO}} 
   };

endmodule
