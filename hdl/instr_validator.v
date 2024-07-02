module instr_validator(
   input [31:0] data_i,
   output [31:2] instr_o
);

   localparam INSTR_ILLEGAL = {{25{1'bX}}, {5{1'b1}}};

   wire [31:2] instr = data_i[31:2];
   wire [1:0] quadrant = data_i[1:0];
   wire [2:0] opcode_mid = data_i[4:2];

   assign instr_o = (opcode_mid != 3'b111 && quadrant == 2'b11) ? instr : INSTR_ILLEGAL;

endmodule