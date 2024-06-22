module csr_misa (
   input clk_i,
   input rst_i,
   input en_i,
   
   input [11:0] addr_i,
   input [31:0] set_i,
   input [31:0] clear_i,

   output ack_o, //Acknowledge sinyali

   output [31:0] value_o,

   //Uzantı destek bitleri (Forwarded)
   output is_a_supported_o,
   output is_b_supported_o,
   output is_f_supported_o,
   output is_m_supported_o
);
   localparam [11:0] ADDRESS = 12'h301;
   
   wire ack = en_i && (addr_i == ADDRESS);
   assign ack_o = ack;

   wire v_ext_a, vn_ext_a;
   csrfield #(
      .RESET_VALUE(1)
   ) u_ext_a (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(ack),
      .set_i(set_i[0]),
      .clear_i(clear_i[0]),
      .value_o(v_ext_a),
      .value_next_o(vn_ext_a)
   );

   wire v_ext_b, vn_ext_b;
   csrfield #(
      .RESET_VALUE(1)
   ) u_ext_b (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(ack),
      .set_i(set_i[1]),
      .clear_i(clear_i[1]),
      .value_o(v_ext_b),
      .value_next_o(vn_ext_b)
   );

   wire v_ext_f, vn_ext_f;
   csrfield #(
      .RESET_VALUE(1)
   ) u_ext_f (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(ack),
      .set_i(set_i[5]),
      .clear_i(clear_i[5]),
      .value_o(v_ext_f),
      .value_next_o(vn_ext_f)
   );

   wire v_ext_m, vn_ext_m;
   csrfield #(
      .RESET_VALUE(1)
   ) u_ext_m (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(ack),
      .set_i(set_i[12]),
      .clear_i(clear_i[12]),
      .value_o(v_ext_m),
      .value_next_o(vn_ext_m)
   );
   
   assign value_o = {
      2'b01, //MXL
      {4{1'b0}}, //Read-only zero
      {13{1'b0}}, //Unsupported extensions
      v_ext_m, //M extension
      {6{1'b0}}, //Unsupported extensions
      v_ext_f,
      {3{1'b0}}, //Unsupported extensions
      v_ext_b,
      v_ext_a
   };

   assign is_a_supported_o = vn_ext_a;
   assign is_b_supported_o = vn_ext_b;
   assign is_f_supported_o = vn_ext_f;
   assign is_m_supported_o = vn_ext_m;


endmodule