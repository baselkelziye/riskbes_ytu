`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/14/2023 10:10:54 PM
// Design Name: 
// Module Name: branch_jump
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


module branch_jump(
    input [31:0]in1_i,
    input [31:0]in2_i,
    input [1:0] branch_jump_op_i,
    input [2:0] funct3_i,
    output PC_sel_o
    );
    
    wire beq_reg; // BNE bunun degili

    wire blt_reg;// signed Less Than comparison.

    wire bltu_reg; // unsigned

    assign beq_reg =  (in1_i == in2_i ) ? 1 : 0;
    
    assign blt_reg =  ($signed(in1_i  ) < $signed(in2_i  ) ? 1 : 0);
    assign bltu_reg = ($unsigned(in1_i) < $unsigned(in2_i) ? 1 : 0);


    reg out_sel_r;

    wire is_branch_instr = branch_jump_op_i[1];
    wire is_jump_instr = branch_jump_op_i[0];
    
    always @* begin
      if(is_branch_instr) begin
          case(funct3_i)
              3'b000:
                  out_sel_r = beq_reg;
              3'b001:
                  out_sel_r = ~beq_reg;
              3'b100:
                  out_sel_r = blt_reg;
              3'b101: //BGE. EQUAL | !BLT
                  out_sel_r = beq_reg | ~blt_reg;
              3'b110:
                  out_sel_r = bltu_reg;
              3'b111:
                  out_sel_r = beq_reg | ~bltu_reg;
              default:
                  out_sel_r = 0;
           endcase
      end else begin
          out_sel_r = is_jump_instr;
      end
    end   
    assign PC_sel_o = out_sel_r;
    
endmodule