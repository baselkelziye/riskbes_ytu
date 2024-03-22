`timescale 1ns / 1ps
module control_unit(
   input [6:2] opcode_i,
   input [2:0] funct3_i,
   input [6:0] funct7_i
);
   wire uses_rd;
   
   wire uses_rd_tmp1 = opcode_i[3] | opcode_i[4] | !opcode_i[5];
   wire uses_rd_tmp2 = opcode_i[2] & opcode_i[6];
   assign uses_rd = uses_rd_tmp1 | uses_rd_tmp2;
   
   
   wire uses_rs1, uses_rs2, uses_rs3;
   
   wire [1:0] rs_count;
   
   wire rs_count0_tmp1 = !opcode_i[4] & !opcode_i[5];
   wire rs_count0_tmp2 = !opcode_i[2] & opcode_i[4] & !opcode_i[5] & !opcode_i[6];
   wire rs_count0_tmp3 = opcode_i[2] & !opcode_i[3] & opcode_i[5] & opcode_i[6];
   wire rs_count0_tmp4 = opcode_i[4] & opcode_i[5] & opcode_i[6] & !funct3_i[2];
   assign rs_count[0] = rs_count0_tmp1 | rs_count0_tmp2 | rs_count0_tmp3 | rs_count0_tmp4;
   
   wire rs_count1_tmp1 = opcode_i[5] ^ opcode_i[6];
   wire rs_count1_tmp2 = !opcode_i[2] | !opcode_i[4];
   wire rs_count1_tmp3 = rs_count1_tmp1 & rs_count1_tmp2;
   wire rs_count1_tmp4 = !opcode_i[2] & !opcode_i[3] & !opcode_i[4] & opcode_i[5] & opcode_i[6];
   assign rs_count[1] = rs_count1_tmp3 | rs_count1_tmp4;
   
   assign uses_rs1 = rs_count[0] | rs_count[1];
   assign uses_rs2 = rs_count[1];
   assign uses_rs3 = rs_count[0] & rs_count[1];
   
   //imm_sel[2] -> shuffle bit
   //000 -> I imm (except SYSTEM)
   //001 -> U imm + SYSTEM
   //010 -> S imm
   //101 -> J imm (U imm + shuffle)
   //110 -> B imm (S imm + shuffle)
   //CSRI komutlarının uygulaması için SYSTEM komutları I yerine U olarak alındı
   wire [2:0] imm_sel;
   
   wire imm_sel0_tmp1 = opcode_i[2] & opcode_i[4];
   wire imm_sel0_tmp2 = opcode_i[2] & opcode_i[3];
   wire imm_sel0_tmp3 = imm_sel0_tmp2 | opcode_i[4];
   wire imm_sel0_tmp4 = opcode_i[5] & opcode_i[6] & imm_sel0_tmp3;
   assign imm_sel[0] = imm_sel0_tmp1 | imm_sel0_tmp4;
   
   wire imm_sel1_tmp1 = !opcode_i[3] & !opcode_i[4] & opcode_i[5];
   wire imm_sel1_tmp2 = !opcode_i[2] | !opcode_i[6];
   assign imm_sel[1] = imm_sel1_tmp1 & imm_sel1_tmp2;
   
   assign imm_sel[2] = !opcode_i[4] & opcode_i[5] & opcode_i[6];

//   wire [2:0] opcode_low = opcode_i[4:2];
//   wire [7:0] opcode_low_decoded;
//   decoder #(
//      .InputSize(3)
//   ) decoder_low (
//      .in_i(opcode_low),
//      .out_o(opcode_low_decoded)
//   );
   
//   wire [1:0] opcode_high = opcode_i[6:5];
//   wire [3:0] opcode_high_decoded;
//   decoder #(
//      .InputSize(2)
//   ) decoder_high (
//      .in_i(opcode_high),
//      .out_o(opcode_high_decoded)
//   );
   
//   wire opcode_load;
//   and(opcode_load, opcode_low_decoded[0], opcode_high_decoded[0]);
   
//   wire opcode_store;
//   and(opcode_store, opcode_low_decoded[0], opcode_high_decoded[1]);
   
//   wire opcode_madd;
//   and(opcode_madd, opcode_low_decoded[0], opcode_high_decoded[2]);
   
//   wire opcode_branch;
//   and(opcode_branch, opcode_low_decoded[0], opcode_high_decoded[3]);
   
//   wire opcode_load_fp;
//   and(opcode_load_fp, opcode_low_decoded[1], opcode_high_decoded[0]);
   
//   wire opcode_store_fp;
//   and(opcode_store_fp, opcode_low_decoded[1], opcode_high_decoded[1]);
   
//   wire opcode_msub;
//   and(opcode_msub, opcode_low_decoded[1], opcode_high_decoded[2]);
   
//   wire opcode_jalr;
//   and(opcode_jalr, opcode_low_decoded[1], opcode_high_decoded[3]);
   
//   wire opcode_nmsub = opcode_low_decoded[2];
   
//   wire opcode_misc_mem;
//   and(opcode_misc_mem, opcode_low_decoded[3], opcode_high_decoded[0]);
   
//   wire opcode_amo;
//   and(opcode_amo, opcode_low_decoded[3], opcode_high_decoded[1]);
   
//   wire opcode_nmadd;
//   and(opcode_nmadd, opcode_low_decoded[3], opcode_high_decoded[2]);
   
//   wire opcode_jal;
//   and(opcode_jal, opcode_low_decoded[3], opcode_high_decoded[3]);
   
//   wire opcode_op_imm;
//   and(opcode_op_imm, opcode_low_decoded[4], opcode_high_decoded[0]);
   
//   wire opcode_op;
//   and(opcode_op, opcode_low_decoded[4], opcode_high_decoded[1]);
   
//   wire opcode_op_fp;
//   and(opcode_op_fp, opcode_low_decoded[4], opcode_high_decoded[2]);
   
//   wire opcode_system;
//   and(opcode_system, opcode_low_decoded[4], opcode_high_decoded[3]);
   
//   wire opcode_auipc;
//   and(opcode_auipc, opcode_low_decoded[5], ~opcode_i[5]);
   
//   wire opcode_lui;
//   and(opcode_lui, opcode_low_decoded[5], opcode_i[5]);
endmodule
