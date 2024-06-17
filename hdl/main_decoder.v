module main_decoder(
    input [6:2] opcode_i,
    output wire reg_wr_en,
    output wire [1:0] wb_sel,
    output wire op1_sel,
    output wire op2_sel,
    output wire is_load_instr,
    output wire is_store_instr,
    output wire is_branch_instr,
    output wire is_jump_instr,
    output wire [2:0] imm_src,
    output wire [2:0] EX_op
);


reg [14:0] control_signals;


localparam [6:2] R_TYPE  = 5'b01100,
                 I_TYPE  = 5'b00100,
                 STORE   = 5'b01000,
                 LOAD    = 5'b00000,
                 BRANCH  = 5'b11000,
                 JALR    = 5'b11001,
                 JAL     = 5'b11011,
                 AUIPC   = 5'b00101,
                 LUI     = 5'b01101,
                 SYSTEM  = 5'b11100;


always @(opcode_i) begin 
//control_signals = reg_wr_en, wb_sel[1:0], op1_sel, op2_sel, is_load_instr, is_store_instr, is_jump_instr, is_branch_instr, imm_src[2:0], EX_op[2:0];
    case(opcode_i)
        LOAD   :  control_signals = 15'b1_01_0_1_1_0_0_0_100_000;
        STORE  :  control_signals = 15'b0_XX_0_1_0_1_0_0_010_000;
        R_TYPE :  control_signals = 15'b1_00_0_0_0_0_0_0_XXX_010;
        I_TYPE :  control_signals = 15'b1_00_0_1_0_0_0_0_101_001;
        BRANCH :  control_signals = 15'b0_XX_1_1_0_0_0_1_011_000;
        JAL    :  control_signals = 15'b1_11_1_1_0_0_1_0_001_000;
        JALR   :  control_signals = 15'b1_11_0_1_0_0_1_0_100_000;
        LUI    :  control_signals = 15'b1_00_X_1_0_0_0_0_000_011;
        AUIPC  :  control_signals = 15'b1_00_1_1_0_0_0_0_000_000;
        SYSTEM :  control_signals = 15'b1_00_X_X_0_0_0_0_101_100;
        default:  control_signals = 15'bX_XX_X_X_X_X_X_X_XXX_XXX;
    endcase
end

assign {reg_wr_en, wb_sel, op1_sel, op2_sel, is_load_instr, is_store_instr, is_jump_instr, is_branch_instr, imm_src, EX_op} = control_signals;

endmodule