`timescale 1ns / 1ps

module imm_gen(
    input [24:0]instr_i,
    input [2:0] imm_src,
    output [31:0]imm_o
    );
    
    reg [31:0]imm_r; 
    wire [2:0] funct3_w = instr_i[7:5];
   

    always @* begin

        case (imm_src)
            3'b000: imm_r = {instr_i[24:5],12'h0}; // LUI-AUIPC
            3'b001: imm_r = {{32{instr_i[24]}}, {instr_i[12:5]}, {instr_i[13]}, {instr_i[23:14]}, {1'b0} }; // JAL
            3'b010: imm_r = { {32{instr_i[24]}}, {instr_i[23:18]}, {instr_i[4:0]}};  // STORE
            3'b011: imm_r = { {32{instr_i[24]}}, {instr_i[0]}, {instr_i[23:18]},{instr_i[4:1]}, {1'b0} }; //Branch
            3'b100: imm_r = { {32{instr_i[24]}}, {instr_i[24:13]} }; // Signed I-Type. (For Load, And JALR), The remaining ALU will be decided in switch case 
            3'b101: if(funct3_w == 3'b001 || funct3_w == 3'b101) //SRAI,SLLI vb komutlar icin. BMU da da eklenebilir biseyler
                    begin
                    imm_r = { {32{instr_i[24]}}, {instr_i[17:13]} };
                    end else begin
                    imm_r = { {32{instr_i[24]}}, {instr_i[24:13]} };    
                    end
        endcase
    end
    
    assign imm_o = imm_r;
    
endmodule
