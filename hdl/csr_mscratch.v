module csr_mscratch(
   input clk_i,
   input rst_i,
   input en_i,
   
   input [11:0] addr_i,
   input [31:0] set_i,
   input [31:0] clear_i,

   output ack_o, //Acknowledge sinyali

   output [31:0] value_o
);
   localparam ADDRESS = 12'h340;
   
   wire ack = en_i && (addr_i == ADDRESS);
   assign ack_o = ack;
   
   csrfield #(
      .WIDTH(32)
   ) field (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(ack),
      .set_i(set_i),
      .clear_i(clear_i),
      .value_o(value_o)
   );
   
endmodule