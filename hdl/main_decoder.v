module main_decoder(
    input [6:0] opcode_i,
    output wire reg_wr_en,
    output wire [1:0] wb_sel,
    output wire op1_sel,
    output wire op2_sel,
    output wire is_load_instr,
    output wire is_store_instr,
    output wire is_branch_instr,
    output wire is_jump_instr,
    output wire [2:0] imm_src,
    output wire [1:0] EX_op
);


reg [13:0] control_signals;


localparam [6:0] R_TYPE  = 7'b0110011,
                 I_TYPE  = 7'b0010011,
                 STORE   = 7'b0100011,
                 LOAD    = 7'b0000011,
                 BRANCH  = 7'b1100011,
                 JALR    = 7'b1100111,
                 JAL     = 7'b1101111,
                 AUIPC   = 7'b0010111,
                 LUI     = 7'b0110111;


always @(opcode_i) begin 
//control_signals = reg_wr_en, wb_sel[1:0], op1_sel, op2_sel, is_load_instr, is_store_instr, is_jump_instr, is_branch_instr, imm_src[2:0], EX_op[1:0];
    case(opcode_i)
        LOAD   :  control_signals = 14'b1_01_0_1_1_0_0_0_100_00;
        STORE  :  control_signals = 14'b0_XX_0_1_0_1_0_0_010_00;
        R_TYPE :  control_signals = 14'b1_00_0_0_0_0_0_0_XXX_10;
        I_TYPE :  control_signals = 14'b1_00_0_1_0_0_0_0_101_01;
        BRANCH :  control_signals = 14'b0_XX_1_1_0_0_0_1_011_00;
        JAL    :  control_signals = 14'b1_11_1_1_0_0_1_0_001_00;
        JALR   :  control_signals = 14'b1_11_0_1_0_0_1_0_100_00;
        LUI    :  control_signals = 14'b1_10_X_X_0_0_0_0_000_XX;
        AUIPC  :  control_signals = 14'b1_00_1_1_0_0_0_0_000_00;
        default:  control_signals = 14'bX_XX_X_X_X_X_X_X_XXX_XX;
    endcase;
end

assign {reg_wr_en, wb_sel, op1_sel, op2_sel, is_load_instr, is_store_instr, is_jump_instr, is_branch_instr, imm_src, EX_op} = control_signals;

endmodule