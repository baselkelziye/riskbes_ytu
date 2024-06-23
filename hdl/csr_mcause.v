module csr_mcause(
   input clk_i,
   input rst_i,
   input en_i,

   input has_exception_i,
   input [2:0] exception_i,
   
   input [11:0] addr_i,
   input [31:0] set_i,
   input [31:0] clear_i,
   
   output ack_o, //Acknowledge sinyali

   output [31:0] value_o
);

   localparam [11:0] ADDRESS = 12'h342;
   
   wire ack = en_i && (addr_i == ADDRESS);
   assign ack_o = ack;

   localparam [2:0] NO_EXCEPTION                = 3'b000,
                    ILLEGAL_EXCEPTION           = 3'b001,
                    ECALL_EXCEPTION             = 3'b010,
                    EBREAK_EXCEPTION            = 3'b011,
                    INSTR_MISALIGNED_EXCEPTION  = 3'b100,
                    INSTR_ACCESS_EXCEPTION      = 3'b101;
   
   localparam [3:0] ILLEGAL_EXCODE           = 4'd2,
                    ECALL_EXCODE             = 4'd11,
                    EBREAK_EXCODE            = 4'd3,
                    INSTR_MISALIGNED_EXCODE  = 4'd0,
                    INSTR_ACCESS_EXCODE      = 4'd1;
   reg [3:0] excode_gen;

   always @(*) begin
      case (exception_i)
         ILLEGAL_EXCEPTION:            excode_gen = ILLEGAL_EXCODE;
         ECALL_EXCEPTION:              excode_gen = ECALL_EXCODE;
         EBREAK_EXCEPTION:             excode_gen = EBREAK_EXCODE;
         INSTR_MISALIGNED_EXCEPTION:   excode_gen = INSTR_MISALIGNED_EXCODE;
         INSTR_ACCESS_EXCEPTION:       excode_gen = INSTR_ACCESS_EXCODE;
         default:                      excode_gen = 4'bXXXX;
      endcase
   end

   wire en = has_exception_i || ack;

   wire [3:0] v_excode;
   
   wire [3:0] excode_set = has_exception_i ? excode_gen : set_i[3:0];
   wire [3:0] excode_clear = has_exception_i ? ~excode_gen : clear_i[3:0];
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
   
   wire int_set = set_i[31] && !has_exception_i;
   wire int_clear = clear_i[31] || has_exception_i;
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
