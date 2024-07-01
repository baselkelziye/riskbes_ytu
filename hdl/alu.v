module alu (input [31:0]alu1_i,
            input [31:0]alu2_i,
            input [3:0] alu_op_i,
            input [1:0] chip_select,
            output [31:0]result_o);

            
            reg [31:0]result_r;
            
            
          wire sum_cOut;
          wire [31:0] sum_result;        
          cla_32bit u_cla32(
             .term1_i(alu1_i),
             .term2_i(alu2_i),
             .carry_i(alu_op_i[0]),
             .result_o(sum_result),
             .carry_o(sum_cOut)
          );
        /*
        0000 ADD
        0001 SUB
        0011 SLL
        0100 SLT
        0101 SLTU
        0110 XOR
        0111 SRL
        1000 SRA
        1001 OR
        1010 AND
        1011 XNOR
        1100 LUI
        */

          wire [31:0] xor_result;
          assign xor_result = alu1_i ^ alu2_i;
            
            always @ (*) begin
              if(chip_select == 2'b00) begin
                case (alu_op_i)
                4'b0000:   //ADD 
                result_r = sum_result;
                4'b0001:   //SUB
                result_r = sum_result;
                4'b0011:   //SLL
                result_r = alu1_i << alu2_i[4:0];
                4'b0100:   //SLT
                result_r = alu1_i < $signed(alu2_i) ? 1 : 0;
                4'b0101:   //SLTU
                result_r = alu1_i < alu2_i ? 1 : 0;
                4'b0110:   //XOR
                result_r = xor_result;
                4'b0111:   //SRL
                result_r = alu1_i >> alu2_i[4:0];
                4'b1000:   //SRA
                result_r = $signed(alu1_i) >>> alu2_i[4:0];
                4'b1001:   //OR
                result_r = alu1_i | alu2_i;
                4'b1010:   //AND
                result_r = alu1_i & alu2_i;
                4'b1011:  //XNOR
                result_r = ~xor_result;
                4'b1100: // LUI
                result_r = alu2_i;
                4'b1101: // LR/SC
                result_r = alu1_i;
                endcase
              end else begin
                result_r = result_o;
              end 

            end
            
            assign result_o = result_r;


endmodule
