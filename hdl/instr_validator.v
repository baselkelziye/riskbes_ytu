module instr_validator(
   input [31:0] data_i,
   output [31:2] instr_o
);

   localparam INSTR_ILLEGAL = {30{1'b1}};

   wire [31:2] instr = data_i[31:2];
   wire [1:0] quadrant = data_i[1:0];

   assign instr_o = (quadrant == 2'b11) ? instr : INSTR_ILLEGAL;

endmodule