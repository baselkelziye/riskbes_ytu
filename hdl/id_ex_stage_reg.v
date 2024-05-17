`timescale 1ns / 1ps

module id_ex_stage_reg(
    input clk_i,
    input rst_i,
    input busywait,
    input flush,
    input stall,
    
    input [31:2] pc_id_ex_i,
    
    input [31:0] rs1_value_id_ex_i,
    input [31:0] rs2_value_id_ex_i,
    
    input [31:0] imm_value_id_ex_i,
    
    input alu_op1_sel_id_ex_i,
    input alu_op2_sel_id_ex_i,
    input [4:0] alu_op_id_ex_i,   
    input [3:0] read_write_sel_id_ex_i,
    input [1:0] wb_sel_id_ex_i,
    input reg_wb_en_id_ex_i,
    input [4:0] rd_id_ex_i,
    input [4:0] rs1_label_id_ex_i,
    input [4:0] rs2_label_id_ex_i,
//    input [6:0] opcode_id_ex_i,
    input is_memory_instruction_id_ex_i,
    input is_load_instruction_id_ex_i,
    
    input [2:0] funct3_id_ex_i,
    input [6:0] funct7_id_ex_i,

    input is_load_instr_id_ex_i,
    input is_store_instr_id_ex_i,
    input is_branch_instr_id_ex_i,
    input [1:0] EX_op_id_ex_i,

    output reg [31:2] pc_id_ex_o,
    
    output reg [31:0] rs1_value_id_ex_o,
    output reg [31:0] rs2_value_id_ex_o,  
    
    output reg [31:0] imm_value_id_ex_o,  
    
    output reg alu_op1_sel_id_ex_o,
    output reg alu_op2_sel_id_ex_o,
    output reg [3:0] read_write_sel_id_ex_o,
    output reg [1:0] wb_sel_id_ex_o,
    output reg reg_wb_en_id_ex_o,
    output reg [4:0] rd_id_ex_o,
    output reg [4:0] rs1_label_id_ex_o,
    output reg [4:0] rs2_label_id_ex_o,   
//    output reg [6:0] opcode_id_ex_o,  
    output reg is_memory_instruction_id_ex_o,
    output reg is_load_instruction_id_ex_o,
    output reg [2:0] funct3_id_ex_o,
    output reg [6:0] funct7_id_ex_o,
    
    output reg is_load_instr_id_ex_o,
    output reg is_store_instr_id_ex_o,
    output reg is_branch_instr_id_ex_o,
    output reg [1:0] EX_op_id_ex_o
    );
    
    always @(*) begin
        if(rst_i || flush) begin
            #0.1;
            pc_id_ex_o                     <= 31'd0;
            rs1_value_id_ex_o              <= 32'd0;
            rs2_value_id_ex_o              <= 32'd0;
            imm_value_id_ex_o              <= 32'd0;
            alu_op1_sel_id_ex_o            <= 0;
            alu_op2_sel_id_ex_o            <= 0;
            read_write_sel_id_ex_o         <= 4'd0;
            wb_sel_id_ex_o                 <= 2'd0;
            reg_wb_en_id_ex_o              <= 0;
            rd_id_ex_o                     <= 5'd0;
            rs1_label_id_ex_o              <= 5'd0;
            is_memory_instruction_id_ex_o  <= 1'b0;
            is_load_instruction_id_ex_o    <= 1'b0;
            funct3_id_ex_o                 <= 3'b0;
            funct7_id_ex_o                 <= 7'b0;
            is_load_instr_id_ex_o          <= 1'b0; 
            is_store_instr_id_ex_o         <= 1'b0;
            is_branch_instr_id_ex_o        <= 1'b0;
            EX_op_id_ex_o                  <= 2'b0;
        end
    
    end
    
    always @(posedge clk_i)begin
      if(!rst_i && !busywait) begin
         if(!stall)begin
            pc_id_ex_o  <= pc_id_ex_i;
            rs1_value_id_ex_o <= rs1_value_id_ex_i;
            rs2_value_id_ex_o <= rs2_value_id_ex_i;
            imm_value_id_ex_o <= imm_value_id_ex_i; 
            alu_op1_sel_id_ex_o <= alu_op1_sel_id_ex_i;
            alu_op2_sel_id_ex_o <= alu_op2_sel_id_ex_i;
            read_write_sel_id_ex_o <= read_write_sel_id_ex_i;
            wb_sel_id_ex_o <= wb_sel_id_ex_i;
            reg_wb_en_id_ex_o <= reg_wb_en_id_ex_i;  
            rd_id_ex_o <= rd_id_ex_i;
            rs1_label_id_ex_o <= rs1_label_id_ex_i;
            rs2_label_id_ex_o <= rs2_label_id_ex_i;
            is_memory_instruction_id_ex_o <= is_memory_instruction_id_ex_i;
            is_load_instruction_id_ex_o <= is_load_instruction_id_ex_i;
            funct3_id_ex_o <= funct3_id_ex_i;
            funct7_id_ex_o <= funct7_id_ex_i;
            is_load_instr_id_ex_o <= is_load_instr_id_ex_i;
            is_store_instr_id_ex_o <= is_store_instr_id_ex_i;
            is_branch_instr_id_ex_o <= is_branch_instr_id_ex_i;
            EX_op_id_ex_o           <= EX_op_id_ex_i;
         end else begin
            pc_id_ex_o                     <= 31'd0;
            rs1_value_id_ex_o              <= 32'd0;
            rs2_value_id_ex_o              <= 32'd0;
            imm_value_id_ex_o              <= 32'd0;
            alu_op1_sel_id_ex_o            <= 0;
            alu_op2_sel_id_ex_o            <= 0;
            read_write_sel_id_ex_o         <= 4'd0;
            wb_sel_id_ex_o                 <= 2'd0;
            reg_wb_en_id_ex_o              <= 0;
            rd_id_ex_o                     <= 5'd0;
            rs1_label_id_ex_o              <= 5'd0;
            is_memory_instruction_id_ex_o  <= 1'b0;
            is_load_instruction_id_ex_o    <= 1'b0;
            funct3_id_ex_o                 <= 3'b0;
            funct7_id_ex_o                 <= 7'b0;
            is_load_instr_id_ex_o          <= 1'b0; 
            is_store_instr_id_ex_o         <= 1'b0;
            is_branch_instr_id_ex_o        <= 1'b0;
            EX_op_id_ex_o                  <= 2'b0;
         end
       end
    end
endmodule