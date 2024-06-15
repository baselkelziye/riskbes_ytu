module cla_32bit
(
 input  [31:0] term1_i,
 input  [31:0] term2_i,
 input         carry_i,
 output [31:0] result_o,
 output        carry_o
);

   // Carry Bits (dummy bits - unused)
   wire c0,c1,c2,c3,c4,c5,c6;

   cla_4bit claa0 (
    .term1_i  (term1_i [3:0]),
    .term2_i  (term2_i [3:0]),
    .carry_i  (carry_i),
    .result_o (result_o[3:0]),
    .carry_o  (c0)
   );
      
   cla_4bit claa1 (
    .term1_i  (term1_i [7:4]),
    .term2_i  (term2_i [7:4]),
    .carry_i  (c0),
    .result_o (result_o[7:4]),
    .carry_o  (c1)
   );

   cla_4bit claa2 (
    .term1_i  (term1_i [11:8]),
    .term2_i  (term2_i [11:8]),
    .carry_i  (c1),
    .result_o (result_o[11:8]),
    .carry_o  (c2)
   );

   cla_4bit claa3 (
    .term1_i  (term1_i [15:12]),
    .term2_i  (term2_i [15:12]),
    .carry_i  (c2),
    .result_o (result_o[15:12]),
    .carry_o  (c3)
   );

   cla_4bit claa4 (
    .term1_i  (term1_i [19:16]),
    .term2_i  (term2_i [19:16]),
    .carry_i  (c3),
    .result_o (result_o[19:16]),
    .carry_o  (c4)
   );

   cla_4bit claa5 (
    .term1_i  (term1_i [23:20]),
    .term2_i  (term2_i [23:20]),
    .carry_i  (c4),
    .result_o (result_o[23:20]),
    .carry_o  (c5)
   );

   cla_4bit claa6 (
    .term1_i  (term1_i [27:24]),
    .term2_i  (term2_i [27:24]),
    .carry_i  (c5),
    .result_o (result_o[27:24]),
    .carry_o  (c6)
   );

   cla_4bit claa7 (
    .term1_i  (term1_i [31:28]),
    .term2_i  (term2_i [31:28]),
    .carry_i  (c6),
    .result_o (result_o[31:28]),
    .carry_o  (carry_o)
   );

endmodule