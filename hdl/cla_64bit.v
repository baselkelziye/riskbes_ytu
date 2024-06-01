module cla_64bit
(
 input  [63:0] term1_i,
 input  [63:0] term2_i,
 input         carry_i,
 output [63:0] result_o,
 output        carry_o
);

   // Carry Bits (dummy bits - unused)
   wire c0;

   cla_32bit claa0 (
    .term1_i  (term1_i [31:0]),
    .term2_i  (term2_i [31:0]),
    .carry_i  (carry_i),
    .result_o (result_o[31:0]),
    .carry_o  (c0)
   );
      
   cla_32bit claa1 (
    .term1_i  (term1_i [63:32]),
    .term2_i  (term2_i [63:32]),
    .carry_i  (c0),
    .result_o (result_o[63:32]),
    .carry_o  (carry_o)
   );

endmodule