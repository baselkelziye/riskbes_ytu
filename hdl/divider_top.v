module divider_top (
      input clk_i,
      input rst_i,
      input [2:0] MDU_op_i, // Adjusted to accommodate muldiv_funct3_t type
      input start_i,
      input [31:0] numerator_i,
      input [31:0] denominator_i,
      output reg [31:0] quotient_o,
      output reg [31:0] remainder_o,
      output wire done_o
);

//--Signal Definitions----------------------------------------------------------------------------------------
reg [31:0] N, D;
wire [31:0] Q,R;
wire neg_q, neg_r;
assign neg_q = numerator_i[31] ^ denominator_i[31];
assign neg_r = numerator_i[31];
//------------------------------------------------------------------------------------------

//--Unsigned Module Instantiation--------------------------------------------------------------
divider_unsigned d
(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .start_i(start_i),
      .numerator_i(N),
      .denominator_i(D),
      .quotient_o(Q),
      .remainder_o(R),
      .done_o(done_o)
);
//------------------------------------------------------------------------------------------


//--Pre-Process the input's Sign-------------------------------------------------------
always @(*) begin
      case (MDU_op_i)
            3'b100: begin // div
                  N = numerator_i[31] ? (~numerator_i) + 32'd1 : numerator_i;
                  D = denominator_i[31] ? (~denominator_i) + 32'd1 : denominator_i;
            end

            3'b101: begin // divu
                  N = numerator_i;
                  D = denominator_i;
            end

            3'b110: begin // rem
                  N = numerator_i[31] ? (~numerator_i) + 32'd1 : numerator_i;
                  D = denominator_i[31] ? (~denominator_i) + 32'd1 : denominator_i;
            end

            3'b111: begin // remu
                  N = numerator_i;
                  D = denominator_i;
            end

            default: begin
                  N = numerator_i[31] ? (~numerator_i) + 32'd1 : numerator_i;
                  D = denominator_i[31] ? (~denominator_i) + 32'd1 : denominator_i;
            end
      endcase
end
//------------------------------------------------------------------------------------------

//-- Process The Output's Sign------------------------------------------------------
always @* begin
    case(MDU_op_i) 
         3'b100: begin // div
                  quotient_o = neg_q ? (~Q) + 32'd1 : Q;
                  remainder_o = neg_r ? (~R) + 32'd1 : R;
            end
            3'b101: begin // divu
                  quotient_o = Q;
                  remainder_o = R;
            end
            3'b110: begin // rem
                  quotient_o = neg_q ? (~Q) + 32'd1 : Q;
                  remainder_o = neg_r ? (~R) + 32'd1 : R;
            end
            3'b111: begin // remu
                  quotient_o = Q;
                  remainder_o = R;
            end
            default: begin
                  quotient_o = neg_q ? (~Q) + 32'd1 : Q;
                  remainder_o = neg_r ? (~R) + 32'd1 : R;
            end
    endcase
end
//------------------------------------------------------------------------------------------
endmodule
