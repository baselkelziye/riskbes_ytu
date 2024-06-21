module csr_mcause(
   input clk_i,
   input rst_i,
   input en_i,
   
   input [11:0] addr_i,
   input [31:0] set_i,
   input [31:0] clear_i,
   
   output ack_o, //Acknowledge sinyali

   output [31:0] value_o
);

   localparam ADDRESS = 12'h342;
   
   wire ack = en_i && (addr_i == ADDRESS);
   assign ack_o = ack;
   
   wire [3:0] v_excode;
   
   csrfield #(
      .WIDTH(4)
   ) u_excode (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(ack),
      .set_i(set_i[3:0]),
      .clear_i(clear_i[3:0]),
      .value_o(v_excode)
   );

   wire v_int;
   
   csrfield u_int (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(ack),
      .set_i(set_i[31]),
      .clear_i(clear_i[31]),
      .value_o(v_int)
   );

   assign value_o = {v_int, {27{1'b0}}, v_excode};
endmodule
