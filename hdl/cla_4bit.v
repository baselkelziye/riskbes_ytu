module cla_4bit
(
 input  [3:0] term1_i,
 input  [3:0] term2_i,
 input        carry_i,
 output [3:0] result_o,
 output       carry_o
);

   wire[3:0] g,p;
   wire[13:0] z;
   
   // Propagate and Generate Value Generator Block
   xor(p[0], term1_i[0], term2_i[0]);
   and(g[0], term1_i[0], term2_i[0]);
   xor(p[1], term1_i[1], term2_i[1]);
   and(g[1], term1_i[1], term2_i[1]);
   xor(p[2], term1_i[2], term2_i[2]);
   and(g[2], term1_i[2], term2_i[2]);
   xor(p[3], term1_i[3], term2_i[3]);
   and(g[3], term1_i[3], term2_i[3]);
   
   // Carry Lookahead Block
   and(z[0], carry_i, p[0]);
   or(z[1], z[0], g[0]);
   and(z[2], carry_i, p[0], p[1]);
   and(z[3], g[0], p[1]);
   or(z[4], z[2], z[3], g[1]);
   and(z[5], carry_i, p[0], p[1], p[2]);
   and(z[6], g[0], p[1], p[2]);
   and(z[7], g[1], p[2]);
   or(z[8], z[5], z[6], z[7], g[2]);
   and(z[9], carry_i, p[0], p[1], p[2]);
   and(z[10], g[0], p[1], p[2]);
   and(z[11], g[1], p[2]);
   or(z[12], z[9], z[10], z[11], g[2]);
   and(z[13], z[12], p[3]);
   or(carry_o, z[13], g[3]);

   // Adder Block
   xor(result_o[0], carry_i, p[0]);
   xor(result_o[1], z[1], p[1]);
   xor(result_o[2], z[4], p[2]);
   xor(result_o[3], z[8], p[3]);

endmodule