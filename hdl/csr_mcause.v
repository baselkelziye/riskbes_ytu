module csr_mcause(
   input clk_i,
   input rst_i,
   input en_i,

   input [1:0] exception_i,
   
   input [11:0] addr_i,
   input [31:0] set_i,
   input [31:0] clear_i,
   
   output ack_o, //Acknowledge sinyali

   output [31:0] value_o
);

   localparam [11:0] ADDRESS = 12'h342;
   
   wire ack = en_i && (addr_i == ADDRESS);
   assign ack_o = ack;

   localparam [1:0] NO_EXCEPTION      = 2'b00,
                    ILLEGAL_EXCEPTION = 2'b01,
                    ECALL_EXCEPTION   = 2'b10,
                    EBREAK_EXCEPTION  = 2'b11;
   
   localparam [3:0] ILLEGAL_EXCODE = 4'd2,
                    ECALL_EXCODE   = 4'd11,
                    EBREAK_EXCODE  = 4'd3;

   wire has_exception = |exception_i;
   reg [3:0] excode_gen;

   always @(*) begin
      case (exception_i)
         ILLEGAL_EXCEPTION: excode_gen = ILLEGAL_EXCODE;
         ECALL_EXCEPTION:   excode_gen = ECALL_EXCODE;
         EBREAK_EXCEPTION:  excode_gen = EBREAK_EXCODE;
         default:           excode_gen = 4'bXXXX;
      endcase
   end

   wire en = has_exception || ack;

   wire [3:0] v_excode;
   
   wire [3:0] excode_set = has_exception ? excode_gen : set_i[3:0];
   wire [3:0] excode_clear = has_exception ? ~excode_gen : clear_i[3:0];
   csrfield #(
      .WIDTH(4)
   ) u_excode (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(en),
      .set_i(excode_set),
      .clear_i(excode_clear),
      .value_o(v_excode),
      .value_next_o()
   );

   wire v_int;
   
   wire int_set = set_i[31] && !has_exception;
   wire int_clear = clear_i[31] || has_exception;
   csrfield u_int (
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .en_i(en),
      .set_i(int_set),
      .clear_i(int_clear),
      .value_o(v_int),
      .value_next_o()
   );

   assign value_o = {v_int, {27{1'b0}}, v_excode};
endmodule
