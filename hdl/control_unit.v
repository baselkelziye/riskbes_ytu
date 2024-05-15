`timescale 1ns / 1ps
module control_unit(
input [6:0]opcode_i,
input [2:0]funct3_i,
input [6:0]funct7_i,
output [3:0]read_write_o,
output is_memory_instruction_o,
output is_load_instruction

);

wire lui_w;
assign lui_w = (!opcode_i[6] & opcode_i[5] & opcode_i[4] & !opcode_i[3] & opcode_i[2]);

wire auipc_w;
assign auipc_w = (!opcode_i[6] & !opcode_i[5] & opcode_i[4] & !opcode_i[3] & opcode_i[2]);

wire jal_w;
assign jal_w = (opcode_i[6] & opcode_i[5] & !opcode_i[4] & opcode_i[3] & opcode_i[2]);

wire jalr_w;
assign jalr_w = (opcode_i[6] & opcode_i[5] & !opcode_i[4] & !opcode_i[3] & opcode_i[2]);

wire B_type_w;
assign B_type_w = (opcode_i[6] & opcode_i[5] & !opcode_i[4] & !opcode_i[3] & !opcode_i[2]);

wire load_w;
assign load_w = (!opcode_i[6] & !opcode_i[5] & !opcode_i[4] & !opcode_i[3] & !opcode_i[2]);

wire store_w;
assign store_w = (!opcode_i[6] & opcode_i[5] & !opcode_i[4] & !opcode_i[3] & !opcode_i[2]);

wire I_type_w;
assign I_type_w = (!opcode_i[6] & !opcode_i[5] & opcode_i[4] & !opcode_i[3] & !opcode_i[2]);

wire R_type_w;
assign R_type_w = (!opcode_i[6] & opcode_i[5] & opcode_i[4] & !opcode_i[3] & !opcode_i[2]);

wire alu_op_type_w;
assign alu_op_type_w = (I_type_w | R_type_w);
wire bl_w;
assign bl_w = (jal_w | jalr_w | B_type_w);
or (read_write_o[3], store_w, load_w);
wire w_9, w_10, w_12, w_13, w_16, w_17, w_18;

and(w_9, !store_w, load_w, !funct3_i[2], !funct3_i[1], funct3_i[0]);
and(w_10, !store_w, load_w, !funct3_i[2], funct3_i[1], !funct3_i[0]);
and(w_12, !store_w, load_w, funct3_i[2], !funct3_i[1], !funct3_i[0]);
and(w_13, !store_w, load_w, funct3_i[2], !funct3_i[1], funct3_i[0]);
and(w_16, store_w, !load_w, !funct3_i[2], !funct3_i[1], !funct3_i[0]);
and(w_17, store_w, !load_w, !funct3_i[2], !funct3_i[1], funct3_i[0]);
and(w_18, store_w, !load_w, !funct3_i[2], funct3_i[1], !funct3_i[0]);

or(read_write_o[2], w_12, w_13, w_17, w_18);
or(read_write_o[1], w_10, w_16, w_17, w_18);
or(read_write_o[0], w_9, w_13, w_16, w_18);

wire is_mem1;
and (is_mem1, opcode_i[0],opcode_i[1]);//last 2 should be 11
wire is_mem2;
nor (is_mem2, opcode_i[2],opcode_i[3], opcode_i[4] ,opcode_i[6]); // opcode 3,4,5 should be 0
and (is_memory_instruction_o,is_mem1,is_mem2);

wire is_load_1;
nor(is_load_1, opcode_i[6],opcode_i[5],opcode_i[4],opcode_i[3],opcode_i[2]);
and(is_load_instruction,is_load_1,opcode_i[1],opcode_i[0]);

endmodule