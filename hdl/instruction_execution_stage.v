`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/18/2024 05:29:57 PM
// Design Name: 
// Module Name: instruction_execution_stage
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


module instruction_execution_stage(
        input        clk_i,
        input        rst_i,
        input        busywait,
        
        //Inputs and Outputs for the Pipeline Register
        input        reg_wb_en_ex_mem_i,
        input [4:0 ] rd_ex_mem_i,
        input [31:0] pc_ex_mem_i,
        input [1:0 ] wb_sel_ex_mem_i,
        input [31:0] imm_ex_mem_i,
        input [4:0 ] rs1_label_ex_mem_i,
        input [4:0 ] rs2_label_ex_mem_i,
        input [3:0 ] read_write_sel_ex_mem_i,
//        input [31:0] rs2_ex_mem_i, locally
        input        is_memory_instruction_ex_mem_i,
        input [2:0] funct3_ex_mem_i,
        input [6:0] funct7_ex_mem_i,
        input is_load_instr_ex_mem_i, 
        input is_store_instr_ex_mem_i,    
        output reg reg_wb_en_ex_mem_o,
        output reg [4:0] rd_ex_mem_o,
        output reg [31:0] pc_ex_mem_o,
        output reg [1:0] wb_sel_ex_mem_o,
        output reg [31:0] imm_ex_mem_o,
        output reg [4:0] rs1_label_ex_mem_o,
        output reg [4:0] rs2_label_ex_mem_o,
        output reg [3:0] read_write_sel_ex_mem_o,
        output reg       is_memory_instruction_ex_mem_o,
        output reg [2:0] funct3_ex_mem_o,
        output reg [6:0] funct7_ex_mem_o,
        output reg is_load_instr_ex_mem_o,
        output reg is_store_instr_ex_mem_o,
        
        //outputs that are generted localy
        output reg [31:0] rs2_ex_mem_o,
        output reg [31:0] alu_out_ex_mem_o,
        output reg PC_sel_w_ex_mem_o,
        
        //inputs required from prev stage to ex stage
        input is_branch_instr_i,
        input is_jump_instr_i,
        input [4:0] rd_mem_wb_o,
        input reg_wb_en_mem_wb_o,
        input is_memory_instruction_mem_wb_o,
        
        //Inputs for Forwarding Unit
        input [31:0] rs1_value_ex_mem_i,
        input [31:0] rs2_value_ex_mem_i,
        input [31:0] alu_out_mem_wb_o,
        input [31:0] rd_data_mem_wb_o,
        input alu_op1_sel_ex_mem_i,
        input alu_op2_sel_ex_mem_i,
        input [4:0] funct5_ex_mem_i,
        input [2:0] EX_op_ex_mem_i,
        output wire mul_stall_o
        );
    
    //sw
    //lw
    
    //tmp Values
        wire [31:0] alu_in1_w;
        wire [31:0] alu_in2_w;
        wire PC_sel_w;
        wire [31:0] alu_out_ex_mem_i;
        wire [1:0]  forwardA;
        wire [1:0]  forwardB;
        wire [31:0] rs1_tmp;
        wire [31:0] shifted_rs1;
            //EX_Decoder sinyalleri, Sonra yukariya EX Stage sinyallerin altina Aynen tasinsin
        wire [1:0] chip_select;
        wire [3:0] ALU_op;
        wire [4:0] BMU_op;
        wire [2:0] MDU_op;
        wire [31:0] ALU_res, MDU_res, BMU_res;
        wire rs1_shift_sel, rs2_negate_sel;
        
        
        wire [31:0] alu_in1_forwarded_input;
        wire [31:0] alu_in2_forwarded_input;
        
        
        localparam [2:0]    MUL_FUNCT3    = 3'b000,
                            MULH_FUNCT3   = 3'b001,
                            MULHSU_FUNCT3 = 3'b010,
                            MULHU_FUNCT3  = 3'b011,
                            DIV_FUNCT3    = 3'b100,
                            DIVU_FUNCT3   = 3'b101,
                            REM_FUNCT3    = 3'b110,
                            REMU_FUNCT3   = 3'b111;
        
            //Dallanma birimi (umutuun raporuna bakilmali)
    branch_jump u_branch_jump(
        .in1_i(alu_in1_w),          //alu output yap
        .in2_i(alu_in2_w),
        .is_branch_instr(is_branch_instr_i),
        .is_jump_instr(is_jump_instr_i),
        .funct3_i(funct3_ex_mem_i),
        .PC_sel_o(PC_sel_w)            //sinyal
    );
    
    
    
     forwarding_unit forwarding_unit(
        .rd_label_ex_mem_o(rd_ex_mem_o),
        .rd_label_mem_wb_o(rd_mem_wb_o),
        .rs1_label_id_ex_o(rs1_label_ex_mem_i),
        .rs2_label_id_ex_o(rs2_label_ex_mem_i),
        .reg_wb_en_ex_mem_o(reg_wb_en_ex_mem_o),
        .reg_wb_en_mem_wb_o(reg_wb_en_mem_wb_o),
        .is_memory_instruction_mem_wb_o(is_memory_instruction_mem_wb_o),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );
    
    
    
    
    mux_4x1 #(
    .DATA_WIDTH(32)
    ) rs1_latest_value_selector (
    .in0(rs1_value_ex_mem_i),    // X0
    .in1(alu_out_mem_wb_o),     // X1
    .in2(alu_out_ex_mem_o),     // X2
    .in3(rd_data_mem_wb_o),     // X3
    .select(forwardA),
    .out(alu_in1_w)
    );


    
    mux_2x1 #(
    .DATA_WIDTH(32)
    ) pc_or_rs1_selector (
    .in0(alu_in1_w),             // X0: Most recent rs1 value
    .in1(pc_ex_mem_i),            // X1: PC value
    .select(alu_op1_sel_ex_mem_i),
    .out(rs1_tmp)
    );
    
    barrel_shifter_32bit u_barrel_shifter (
        .data_i(rs1_tmp),
        .ctrl_i(funct3_ex_mem_i[2:1]),// upper 2 bits of funct3 tells us the amount of shift
        .data_o(shifted_rs1)
    );
    
    //mux for Shifting RS1
    mux_2x1 #(
        .DATA_WIDTH(32)
    ) u_rs1_shift_sel_mux(
        .in0(rs1_tmp),
        .in1(shifted_rs1),
        .select(rs1_shift_sel), 
        .out(alu_in1_forwarded_input)
    );

      
    mux_4x1 #(
    .DATA_WIDTH(32)
    ) rs2_latest_value_selector (
    .in0(rs2_value_ex_mem_i),    // X0
    .in1(alu_out_mem_wb_o),     // X1
    .in2(alu_out_ex_mem_o),     // X2
    .in3(rd_data_mem_wb_o),     // X3
    .select(forwardB),
    .out(alu_in2_w)
    );

    wire [31:0] rs2_tmp;
    mux_2x1 #(
    .DATA_WIDTH(32)
    ) imm_or_rs2_selector (
    .in0(alu_in2_w),                 // X0: Most recent rs2 value
    .in1(imm_ex_mem_i),         // X1: Immediate value
    .select(alu_op2_sel_ex_mem_i),
    .out(rs2_tmp)
    );

    mux_2x1 #(
        .DATA_WIDTH(32)
    ) u_rs2_negate_sel_mux(
        .in0(rs2_tmp),
        .in1(~rs2_tmp),
        .select(rs2_negate_sel),
        .out(alu_in2_forwarded_input)
    );

    
    EX_Decoder u_EX_Decoder(
                   .EX_op (EX_op_ex_mem_i), 
                   .funct3(funct3_ex_mem_i),
                   .funct5(funct5_ex_mem_i),
                   .funct7(funct7_ex_mem_i),
                   .ALU_op(ALU_op),
                   .BMU_op(BMU_op),
                   .MDU_op(MDU_op),
                   .chip_select(chip_select),
                   .rs1_shift_sel(rs1_shift_sel),
                   .rs2_negate_sel(rs2_negate_sel)
    );
    
    
    alu u_alu(
        .alu1_i(alu_in1_forwarded_input),  //bunlar anlik cikis oldugu icin pipeline'a girmelerine gerek yok.
        .alu2_i(alu_in2_forwarded_input),
        .chip_select(chip_select),
        .alu_op_i(ALU_op),
        .result_o(ALU_res)
    );
    wire mul_en;
    assign mul_en = (MDU_op == MUL_FUNCT3 || MDU_op == MULH_FUNCT3 || MDU_op == MULHSU_FUNCT3 || MDU_op == MULHU_FUNCT3) ? 1 : 0;
    MDU u_MDU(
        .clk_i(clk_i),//clock for pipelined mul/div operations
        .rst_i(rst_i),
        .mul_en(mul_en),
        .alu1_i(alu_in1_forwarded_input),
        .alu2_i(alu_in2_forwarded_input),
        .chip_select(chip_select),
        .MDU_op(MDU_op),
        .result_o(MDU_res),
        .mul_stall(mul_stall_o)
    );
    
   
                                   

    
    BMU u_BMU(
        .rs1_value_i(alu_in1_forwarded_input),
        .rs2_value_i(alu_in2_forwarded_input),
        .BMU_opcode_i(BMU_op),
        .BMU_result_o(BMU_res)
    );


    mux_4x1 #(
    .DATA_WIDTH(32)
    ) u_EX_res_select_mux (
       .in0(ALU_res),        // X0
       .in1(MDU_res),        // X1
       .in2(BMU_res),   // X2
       .in3(32'hdeadbeef),   // X3
       .select(chip_select),
       .out(alu_out_ex_mem_i)
    );

    always @(posedge clk_i) begin
        if(rst_i) begin
            alu_out_ex_mem_o <= 32'd0;
            reg_wb_en_ex_mem_o <= 0;
            rd_ex_mem_o <= 5'd0;
            pc_ex_mem_o <= 32'd0;
            wb_sel_ex_mem_o <= 2'd0;
            imm_ex_mem_o <= 32'd0;
            rs1_label_ex_mem_o <= 5'd0;
            rs2_label_ex_mem_o <= 5'd0;
            read_write_sel_ex_mem_o <= 4'd0;
            rs2_ex_mem_o <= 32'd0;
            is_memory_instruction_ex_mem_o <= 0;
            PC_sel_w_ex_mem_o <= 0;
            funct3_ex_mem_o <= 3'b0;
            funct7_ex_mem_o <= 7'b0;
            is_load_instr_ex_mem_o <= 1'b0;
            is_store_instr_ex_mem_o <= 1'b0;
        end else if(!busywait && !mul_stall_o) begin
            PC_sel_w_ex_mem_o <= PC_sel_w;     
            alu_out_ex_mem_o <= alu_out_ex_mem_i;
            reg_wb_en_ex_mem_o <= reg_wb_en_ex_mem_i;
            rd_ex_mem_o <= rd_ex_mem_i;
            pc_ex_mem_o <= pc_ex_mem_i;
            wb_sel_ex_mem_o <= wb_sel_ex_mem_i;
            imm_ex_mem_o <= imm_ex_mem_i;
            rs1_label_ex_mem_o <= rs1_label_ex_mem_i;
            rs2_label_ex_mem_o <= rs2_label_ex_mem_i;
            read_write_sel_ex_mem_o <= read_write_sel_ex_mem_i;
            rs2_ex_mem_o <= alu_in2_w;
            is_memory_instruction_ex_mem_o <= is_memory_instruction_ex_mem_i;
            funct3_ex_mem_o <= funct3_ex_mem_i;
            funct7_ex_mem_o <= funct7_ex_mem_i;
            is_load_instr_ex_mem_o <= is_load_instr_ex_mem_i;
            is_store_instr_ex_mem_o <= is_store_instr_ex_mem_i;
        end 
   end
    
endmodule
