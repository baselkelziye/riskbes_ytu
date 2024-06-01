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
// 
//////////////////////////////////////////////////////////////////////////////////
module multiplier_top (
      input  clk,
      input  rst,
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

always @(*) begin
       case(MDU_op)
      MUL_FUNCT3 : begin
            neg_result = a[31] ^ b[31];
            A = a[31] ? (~a) + 1 : a;
            B = b[31] ? (~b) + 1 : b;
//            product = neg_result ? (~P) + 1 : P;
      end

      MULH_FUNCT3 : begin
            neg_result = a[31] ^ b[31];
            A = a[31] ? (~a) + 1 : a;
            B = b[31] ? (~b) + 1 : b;
//            product = neg_result ? (~P) + 1 : P;
      end

      MULHSU_FUNCT3: begin
            neg_result = a[31];
            A = a[31] ? (~a) + 1 : a;
            B = b;
//            product = neg_result ? (~P) + 1 : P;
      end

      MULHU_FUNCT3: begin
            neg_result = 1'b0;
            A = a;
            B = b;
//            product = P;
      end

      default: begin
            neg_result = a[31] ^ b[31];
            A = a[31] ? (~a) + 1 : a;
            B = b[31] ? (~b) + 1 : b;
//            product = neg_result ? (~P) + 1 : P;
      end

      endcase
end

always @(*) begin

if(done == 1'b1) begin

       case(MDU_op)
      MUL_FUNCT3 : begin
            product = neg_result ? (~P) + 1 : P;
      end

      MULH_FUNCT3 : begin

            product = neg_result ? (~P) + 1 : P;
      end

      MULHSU_FUNCT3: begin
            product = neg_result ? (~P) + 1 : P;
      end

      MULHU_FUNCT3: begin
            product = P;
      end

      default: begin
            product = neg_result ? (~P) + 1 : P;
      end

      endcase

end else begin
            product = 64'hAABBCCDDAABBCCDD;
end

end

multiplier_unsigned multiu
(
      .clk(clk),
      .rst(rst),
      .a(A),
      .b(B),
      .start(start),
      .product(P),
      .done(done)
);

endmodule