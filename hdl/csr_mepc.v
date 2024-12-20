`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/16/2024 04:34:20 AM
// Design Name: 
// Module Name: csr_mepc
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


module csr_mepc(
   input clk_i,
   input rst_i,
   input en_i,

   input exception_detected_i,
   input [31:2] pc_last_i,
   
   input [11:0] addr_i,
   input [31:0] set_i,
   input [31:0] clear_i,
   
   output ack_o, //Acknowledge sinyali

   output [31:0] value_o
);

   localparam [11:0] ADDRESS = 12'h341;
   
   wire ack = en_i && (addr_i == ADDRESS);
   assign ack_o = ack;
   
   wire [31:2] value;
   assign value_o = {value, {2{1'b0}}};

   wire en = exception_detected_i || ack;
   wire [31:2] set = exception_detected_i ? pc_last_i : set_i[31:2];
   wire [31:2] clear = exception_detected_i ? ~pc_last_i : clear_i[31:2];
   
   csrfield #(
      .WIDTH(30)
   ) field (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(en),
      .set_i(set),
      .clear_i(clear),
      .value_o(value),
      .value_next_o()
   );
endmodule
