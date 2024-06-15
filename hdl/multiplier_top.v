`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/30/2024 12:59:45 PM
// Design Name: 
// Module Name: multiplier_top
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
// asdasdasdasdadsad
//////////////////////////////////////////////////////////////////////////////////
module multiplier_top (
      input  clk_i,
      input  rst_i,
      input  [31:0] a,
      input  [31:0] b,
      input start,
      input  [2:0] MDU_op,
      output reg [63:0] product,
      output wire done
);

localparam [2:0]    MUL_FUNCT3    = 3'b000,
                    MULH_FUNCT3   = 3'b001,
                    MULHSU_FUNCT3 = 3'b010,
                    MULHU_FUNCT3  = 3'b011,
                    DIV_FUNCT3    = 3'b100,
                    DIVU_FUNCT3   = 3'b101,
                    REM_FUNCT3    = 3'b110,
                    REMU_FUNCT3   = 3'b111;

reg neg_result;

reg [31:0] A;
reg [31:0] B;
wire [63:0] P;

wire a31bit, b31bit;

//Pre process the inputs
always @(*) begin
       case(MDU_op)
      MUL_FUNCT3 : begin
            A = a[31] ? (~a) + 1 : a;
            B = b[31] ? (~b) + 1 : b;
      end

      MULH_FUNCT3 : begin
            A = a[31] ? (~a) + 1 : a;
            B = b[31] ? (~b) + 1 : b;
      end

      MULHSU_FUNCT3: begin
            A = a[31] ? (~a) + 1 : a;
            B = b;
      end

      MULHU_FUNCT3: begin
            A = a;
            B = b;
      end

      default: begin

            A = a[31] ? (~a) + 1 : a;
            B = b[31] ? (~b) + 1 : b;
      end

      endcase
end

//process the outputs
always @(*) begin

if(done == 1'b1) begin

       case(MDU_op)
      MUL_FUNCT3 : begin
            neg_result = a31bit ^ b31bit; 
            product = neg_result ? (~P) + 1 : P;
      end

      MULH_FUNCT3 : begin
            neg_result = a31bit ^ b31bit; 
            product = neg_result ? (~P) + 1 : P;
      end

      MULHSU_FUNCT3: begin
            neg_result = a31bit;
            product = neg_result ? (~P) + 1 : P;
      end

      MULHU_FUNCT3: begin
            neg_result = 1'b0;
            product = P;
      end

      default: begin
            neg_result = a31bit ^ b31bit; 
            product = neg_result ? (~P) + 1 : P;
      end

      endcase

end else begin
            product = 64'hAABBCCDDAABBCCDD;
end

end

//multiplies 2 numbers, we have to pre-process input's sign according to the instruction
multiplier_unsigned multiu
(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .a(A),
      .b(B),
      .start(start),
      .product(P),
      .done(done),
      .a31_bit_i(a[31]), // latch sign bits, otherwise forwarding unit distrupts them.
      .b31_bit_i(b[31]),
      .a31_bit_o(a31bit),
      .b31_bit_o(b31bit)
);

endmodule