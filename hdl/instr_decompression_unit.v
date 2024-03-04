`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/27/2024 07:56:20 PM
// Design Name: 
// Module Name: instr_decompression_unit
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


module instr_decompression_unit (
    output reg [31:2] instr_out,
    input [15:0] instr_in
);

wire [1:0] op = instr_in[1:0];
wire [2:0] funct = instr_in[15:13];
wire sign = instr_in[12]; //part of funct4 in CR only
wire [1:0] misc = instr_in[11:10]; //used as funct for MISC-ALU operations 
wire [1:0] misc2 = instr_in[6:5]; //used as funct for some MISC-ALU operations

wire [4:0] rd = instr_in[11:7]; //CR~CI
wire [4:0] rs = instr_in[6:2]; //CR~CSS

wire [2:0] rdx = instr_in[4:2]; //CIW~CL, rs2x in CS only
wire [4:0] rdi = {2'b01, rdx};

wire [2:0] rsx = instr_in[9:7]; //CL~CS~CB
wire [4:0] rsi = {2'b01, rsx};

wire [9:2] imm1 = {instr_in[10:7], instr_in[12:11], instr_in[6:5]}; //xxx54987623xxxxx (imm1)
wire [6:2] imm2 = {instr_in[5], instr_in[12:10], instr_in[6]}; //xxx543xxx26xxxxx (imm2)
wire [5:0] imm3 = {instr_in[12], instr_in[6:2]}; //xxx5xxxxx43210xx (imm3) 
wire [17:12] imm4 = imm3; //xxHxxxxxGFEDCxx (imm4) 
wire [7:2] imm5 = {instr_in[3:2], instr_in[12], instr_in[6:4]}; //xxx5xxxxx43276xx (imm5)
wire [11:1] imm6 = {instr_in[12], instr_in[8], instr_in[10:9], instr_in[6], instr_in[7], instr_in[2], instr_in[11], instr_in[5:3]}; //xxxB498A673215xx (imm6)
wire [9:4] imm7 = {instr_in[12], instr_in[4:3], instr_in[5], instr_in[2], instr_in[6]}; //xxx9xxxxx46875xx (imm7)
wire [8:1] imm8 = {instr_in[12], instr_in[6:5], instr_in[2], instr_in[11:10], instr_in[4:3]}; //xxx843xxx76215xx (imm8)
wire [7:2] imm9 = {instr_in[8:7], instr_in[12:9]}; //xxx543276xxxxxxx (imm9)

always @(instr_in) begin
    case (op)
        0: case (funct)
            0: //ADDI4SPN -> addi rdx, x2, nzuimm[9:2]
            //xxx54987623xxxxx (imm1)
            instr_out = {{2{sign}}, imm1, 2'b0, 5'b10, 3'b0, rdi, 5'b00100};

            2: //LW -> lw rdx, offset[6:2](rsx)
            //xxx543xxx26xxxxx (imm2)
            instr_out = {{5{sign}}, imm2, 2'b0, rsi, 3'b010, rdi, 5'b00000};

            6: //SW -> sw rdx, offset[6:2](rsx)
            //xxx543xxx26xxxxx (imm2)
            instr_out = {{5{sign}}, imm2[6:5], rdi, rsi, 3'b010, imm2[4:2], 2'b0, 5'b01000};
        endcase
        1: case (funct)
            0: //ADDI -> addi rd, rd, nzimm[5:0]
            //xxx5xxxxx43210xx (imm3)
            instr_out = {{6{sign}}, imm3, rd, 3'b0, rd, 5'b00100};

            1: //JAL -> jal x1, offset[11:1]
            //xxxB498A673215xx (imm6)
            instr_out = {sign, imm6[10:1], imm6[11], {8{sign}}, 5'b1, 5'b11011};

            2: //LI -> addi rd, x0, imm[5:0]
            //xxx5xxxxx43210xx (imm3)
            instr_out = {{6{sign}}, imm3, 5'b0, 3'b0, rd, 5'b00100};

            3: case (rd)
                2: //ADDI16SP -> addi x2, x2, nzimm[9:4]
                //xxx9xxxxx46875xx (imm7)
                instr_out = {{2{sign}}, imm7, 4'b0, 5'b10, 3'b0, 5'b10, 5'b00100};

                default: //LUI -> lui rd, nzuimm[17:12]
                //xxHxxxxxGFEDCxx (imm4)
                instr_out = {{14{sign}}, imm4, rd, 5'b01101};
            endcase
            4: case (misc)
                0: //SRLI -> srli rsx, rsx, shamt[4:0]
                //xxx5xxxxx43210xx (imm3)
                instr_out = {7'b0, imm3[4:0], rsi, 3'b101, rsi, 5'b00100};

                1: //SRAI -> srai rsx, rsx, shamt[4:0]
                //xxx5xxxxx43210xx (imm3)
                instr_out = {7'b0100000, imm3[4:0], rsi, 3'b101, rsi, 5'b00100};

                2: //ANDI -> andi rsx, rsx, imm[5:0]
                //xxx5xxxxx43210xx (imm3)
                instr_out = {{6{sign}}, imm3, rsi, 3'b111, rsi, 5'b00100};

                3: case (misc2) //Ignoring sign bit, which must be 0 (otherwise reserved)
                    //All no imm
                    
                    0: //SUB -> sub rsx, rsx, rdx
                    instr_out = {7'b0100000, rdi, rsi, 3'b000, rsi, 5'b01100};

                    1: //XOR -> xor rsx, rsx, rdx
                    instr_out = {7'b0000000, rdi, rsi, 3'b100, rsi, 5'b01100};

                    2: //OR -> or rsx, rsx, rdx
                    instr_out = {7'b0000000, rdi, rsi, 3'b110, rsi, 5'b01100};

                    3: //AND -> and rsx, rsx, rdx
                    instr_out = {7'b0000000, rdi, rsi, 3'b111, rsi, 5'b01100};
                endcase
            endcase
            5: //J -> jal x0, offset[11:1]
            //xxxB498A673215xx (imm6)
            instr_out = {sign, imm6[10:1], imm6[11], {8{sign}}, 5'b0, 5'b11011};

            6: //BEQZ -> beq rsx, x0, offset[8:1]
            //xxx843xxx76215xx (imm8)
            instr_out = {{3{sign}}, imm8[8:5], 5'b0, rsi, 3'b000, imm8[4:1], sign, 5'b11000};

            7: //BNEZ -> bne rsx, x0, offset[8:1]
            //xxx843xxx76215xx (imm8)
            instr_out = {{3{sign}}, imm8[8:5], 5'b0, rsi, 3'b001, imm8[4:1], sign, 5'b11000};

        endcase
        2: case (funct)
            0: //SLLI -> slli rd, rd, shamt[5:0]
            //xxx5xxxxx43210xx (imm3)
            instr_out = {7'b0, imm3[4:0], rd, 3'b001, rd, 5'b00100};

            2: //LWSP -> lw rd, offset[7:2](x2)
            //xxx5xxxxx43276xx (imm5)
            instr_out = {{4{sign}}, imm5, 2'b0, 5'b10, 3'b010, rd, 5'b00000};

            4: case (sign)
                0: case (rs)
                    0: //JR -> jalr x0, rd, 0
                    //No imm
                    instr_out = {12'b0, rd, 3'b0, 5'b0, 5'b11001};

                    default: //MV -> add rd, x0, rs
                    //No imm
                    instr_out = {7'b0, rs, 5'b0, 3'b0, rd, 5'b01100};
                endcase
                1: case (rs)
                    0: case (rd) 
                        0: //EBREAK
                        instr_out = 30'b000000000001000000000000011100;

                        default: //JALR -> jalr x1, rd, 0
                        //No imm
                        instr_out = {12'b0, rd, 3'b0, 5'b1, 5'b11001};
                    endcase

                    default: //ADD -> add rd, rd, rs
                    //No imm
                    instr_out = {7'b0, rs, rd, 3'b0, rd, 5'b01100};
                endcase 
            endcase

            6: //SWSP -> sw rs, offset[7:2](x2)
            //xxx543276xxxxxxx (imm9)
            instr_out = {{4{sign}}, imm9[7:5], rs, 5'b10, 3'b010, imm9[4:2], 2'b0, 5'b01000};
        endcase
    endcase
end
    
endmodule