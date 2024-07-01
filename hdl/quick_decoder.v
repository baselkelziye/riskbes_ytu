module quick_decoder(
    input [6:2] opcode_i,

    output [1:0] branch_jump_op_o,
    output [2:0] imm_src_o
);

//branch_jump_op_o
//00 -> else
//01 -> JAL/JALR
//10 -> BRANCH
//11 -> reserved

reg [4:0] control_signals;

localparam [6:2] R_TYPE  = 5'b01100,
                 I_TYPE  = 5'b00100,
                 STORE   = 5'b01000,
                 LOAD    = 5'b00000,
                 BRANCH  = 5'b11000,
                 JALR    = 5'b11001,
                 JAL     = 5'b11011,
                 AUIPC   = 5'b00101,
                 LUI     = 5'b01101,
                 SYSTEM  = 5'b11100,
                 AMO     = 5'b01011;


always @(opcode_i) begin 
//control_signals = branch_jump_op_o[1:0], imm_src_o[2:0]
    case(opcode_i)
        LOAD   :  control_signals = 5'b00_100;
        STORE  :  control_signals = 5'b00_010;
        R_TYPE :  control_signals = 5'b00_XXX;
        I_TYPE :  control_signals = 5'b00_101;
        BRANCH :  control_signals = 5'b10_011;
        JAL    :  control_signals = 5'b01_001;
        JALR   :  control_signals = 5'b01_100;
        LUI    :  control_signals = 5'b00_000;
        AUIPC  :  control_signals = 5'b00_000;
        SYSTEM :  control_signals = 5'b00_101;
        AMO    :  control_signals = 5'b00_XXX;
        default:  control_signals = 5'bXX_XXX;
    endcase
end

assign {branch_jump_op_o, imm_src_o} = control_signals;

endmodule