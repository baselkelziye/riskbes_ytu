`timescale 1ns / 1ps
module alu (
   input [31:0]alu1_i,
   input [31:0]alu2_i,
   input [4:0] alu_op_i,
   output [31:0]result_o
);

   reg [63:0]mul_r;
   reg [31:0]result_r;
   
   assign result_o = result_r;
            
   always @(alu1_i or alu2_i or alu_op_i) begin
        
      case (alu_op_i)
         5'b00000: result_r = alu1_i + alu2_i; //ADD
         5'b00010: result_r = alu1_i - alu2_i; //SUB     
         5'b00100: result_r = alu1_i << alu2_i; //SLL      
         5'b01000: result_r = $signed(alu1_i) < $signed(alu2_i) ? 1 : 0; //SLT
         5'b01100: result_r = alu1_i < alu2_i ? 1 : 0; //SLTU
         5'b10000: result_r = alu1_i ^ alu2_i; //XOR
         5'b10100: result_r = alu1_i >> alu2_i; //SRL
         5'b10110: result_r = $signed(alu1_i) >>> alu2_i; //SRA    
         5'b11000: result_r = alu1_i | alu2_i; //OR
         5'b11100: result_r = alu1_i & alu2_i; //AND 
         5'b00001: result_r = alu1_i * alu2_i; //MUL
         5'b00101: begin  //MULH 
            mul_r = $signed(alu1_i) * $signed(alu2_i);
            result_r = mul_r[63:32];
         end
         5'b01001: begin //MULHU
            mul_r = $unsigned(alu1_i) * $unsigned(alu2_i);
            result_r = mul_r[63:32];
         end
         5'b01101: begin //MULHSU    
            mul_r = $signed(alu1_i) * $unsigned(alu2_i);
            result_r = mul_r[63:32];
         end
         5'b10001: begin //DIV
            if(alu2_i == 32'h0) begin
               result_r = -32'h1; 
            end else if(alu1_i[31] == 1'b1 && alu2_i == -32'h1) begin 
               result_r = alu1_i;
            end else begin 
               result_r = $signed(alu1_i) / $signed(alu2_i);
            end
         end
         5'b10101: begin //DIVU
            if(alu2_i == 32'h0) begin
               result_r = (2**32)-1;
            end else begin 
               result_r = $unsigned(alu1_i) / $unsigned(alu2_i);
            end
         end
         5'b11001: begin //REM       
            if(alu2_i == 32'h0) begin
               result_r = alu1_i; 
            end else if(alu1_i[31] == 1'b1 && alu2_i == -32'h1) begin 
               result_r = 32'h0;
            end else begin 
               result_r = $signed(alu1_i) % $signed(alu2_i);
            end
         end
         5'b11101: begin //REMU       
            if(alu2_i == 32'h0) begin
               result_r = alu1_i;
            end else begin 
               result_r = $unsigned(alu1_i) % $unsigned(alu2_i);
            end
         end
      endcase
   end         

endmodule
