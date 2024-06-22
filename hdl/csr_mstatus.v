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

    output ack_o, //Acknowledge sinyali

    output [31:0] value_o
);

   localparam [11:0] ADDRESS = 12'h300;
   
   wire ack = en_i && (addr_i == ADDRESS);
   assign ack_o = ack;

   wire v_mie;
   csrfield u_mie(
      .clk_i(clk_i),
      .rst_i(rst_i),

      .en_i(ack),
      .set_i(set_i[3]),
      .clear_i(clear_i[3]),
      .value_o(v_mie),
      .value_next_o()
   );
   
   wire v_mpie;
   csrfield u_mpie(
      .clk_i(clk_i),
      .rst_i(rst_i),

      .en_i(ack),
      .set_i(set_i[7]),
      .clear_i(clear_i[7]),
      .value_o(v_mpie),
      .value_next_o()
   );
   
   wire v_sd = 0;
   wire [1:0] v_xs = 0;
   wire [1:0] v_fs = 0;

   assign value_o = {
      v_sd,
      {14{1'b0}},
      v_xs,
      v_fs,
      {2{1'b1}},
      {3{1'b0}},
      v_mpie,
      {3{1'b0}},
      v_mie,
      {3{1'b0}} 
   };

endmodule
