`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2024 04:45:10 PM
// Design Name: 
// Module Name: instruction_fetch_stage
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


module instruction_fetch_stage(
   input clk_i,
   input rst_i,
   
   input [31:2] cache_data_i,
   output [31:2] cache_address_o,
   input cache_blocking_n_i,

   input stall_i,
   
   input branching_i,
   input [31:2] branch_target_i,
   
   output reg [31:2] instr_o,
   output reg [31:2] pc_o,

   output reg [1:0] branch_jump_op_o,
   output reg [2:0] imm_src_o
);
   localparam [31:2] INSTR_NOP = 30'b000000000000000000000000000100;
   localparam [1:0] BRANCH_JUMP_NOP = 2'b00;
   localparam [2:0] IMM_SRC_NOP = 3'bXXX;
   
   reg [31:2] pc_reg;
   wire [31:2] pc = branching_i ? branch_target_i : pc_reg;

   assign cache_address_o = pc;

   wire [31:2] pc_increment;
   wire pc_carry;
   
   increment #(.DATA_WIDTH(30)) u_pc_increment
   (
       .value_i(pc),
       .value_o(pc_increment),
       .carry_o(pc_carry)
   );

   wire [6:2] opcode = cache_data_i[6:2];
   wire [2:0] funct3a = cache_data_i[31:29];
   wire [1:0] funct2a = cache_data_i[28:27];
   wire [4:0] rd_label = cache_data_i[11:7];
   wire [4:0] rs1_label = cache_data_i[19:15];
   wire [4:0] rs2_label = cache_data_i[24:20];

   wire is_opcode_amo;
   wire [1:0] branch_jump_op;
   wire [2:0] imm_src;

   quick_decoder u_quick_decoder(
      .opcode_i(opcode),
      .branch_jump_op_o(branch_jump_op),
      .imm_src_o(imm_src),
      .is_opcode_amo_o(is_opcode_amo)
   );

   wire [31:2] amo_instr;
   wire amo_sel;

   amo_expander u_amo_expander(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .branching_i(branching_i),
      .stall_i(stall_i),

      .instr_rd_i(rd_label),
      .instr_rs1_i(rs1_label),
      .instr_rs2_i(rs2_label),
      .instr_funct2a_i(funct2a),
      .instr_funct3a_i(funct3a),
      .instr_is_opcode_amo_i(is_opcode_amo),

      .instr_replaced_o(amo_instr),
      .instr_sel_o(amo_sel)
   );

   wire iterate_pc = !amo_sel && cache_blocking_n_i;
   wire [31:2] wait_instr = (amo_sel && !branching_i) ? amo_instr : INSTR_NOP;

   always @(posedge clk_i) begin
      if(!rst_i) begin
         if(!stall_i) begin
            pc_o <= pc;

            if(iterate_pc) begin
               pc_reg <= pc_increment;

               instr_o <= cache_data_i;
               branch_jump_op_o <= branch_jump_op;
               imm_src_o <= imm_src;
            end else begin
               pc_reg <= pc;

               instr_o <= wait_instr;
               branch_jump_op_o <= BRANCH_JUMP_NOP;
               imm_src_o <= IMM_SRC_NOP;
            end
         end
      end else begin
         pc_reg <= 30'b10000_00000_00000_00000_00000_00000;

         instr_o <= INSTR_NOP;
         branch_jump_op_o <= BRANCH_JUMP_NOP;
         imm_src_o <= IMM_SRC_NOP;
      end
   end

endmodule