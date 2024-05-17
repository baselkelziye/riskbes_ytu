module MDU(
            input [31:0]alu1_i,
            input [31:0]alu2_i,
            input [2:0] MDU_op,
            input [1:0] chip_select,
            output [31:0]result_o
);



reg [63:0]mul_r;
reg [31:0]result_r;

localparam [2:0]    MUL_FUNCT3    = 3'b000,
                    MULH_FUNCT3   = 3'b001,
                    MULHSU_FUNCT3 = 3'b010,
                    MULHU_FUNCT3  = 3'b011,
                    DIV_FUNCT3    = 3'b100,
                    DIVU_FUNCT3   = 3'b101,
                    REM_FUNCT3    = 3'b110,
                    REMU_FUNCT3   = 3'b111;

always @* begin
    if(chip_select == 2'b01) begin
    case(MDU_op)
        MUL_FUNCT3    : begin
                        result_r = alu1_i * alu2_i;
                        end

        MULH_FUNCT3   : begin
                        mul_r = $signed(alu1_i) * $signed(alu2_i);
                        result_r = mul_r[63:32];
                        end

        MULHSU_FUNCT3 : begin
                        mul_r = $signed(alu1_i) * $unsigned(alu2_i);
                        result_r = mul_r[63:32];
                        end

        MULHU_FUNCT3  : begin
                        mul_r = $unsigned(alu1_i) * $unsigned(alu2_i);
                        result_r = mul_r[63:32];
                        end
        
        DIV_FUNCT3    : begin
                            if(alu2_i == 32'h0) begin
                            result_r = -32'h1; 
                            end else if(alu1_i[31] == 1'b1 && alu2_i == -32'h1) begin 
                            result_r = alu1_i;
                            end else begin 
                            result_r = $signed(alu1_i) / $signed(alu2_i);
                            end
                        end
        
        DIVU_FUNCT3   : begin
                            if(alu2_i == 32'h0) begin
                            result_r = (2**32)-1;
                            end else begin 
                            result_r = $unsigned(alu1_i) / $unsigned(alu2_i);
                            end
                        end
        
        REM_FUNCT3    : begin
                            if(alu2_i == 32'h0) begin
                                result_r = alu1_i; 
                                end else if(alu1_i[31] == 1'b1 && alu2_i == -32'h1) begin 
                                result_r = 32'h0;
                                end else begin 
                                result_r = $signed(alu1_i) % $signed(alu2_i);
                            end
                        end
        
        REMU_FUNCT3   : begin
                            if(alu2_i == 32'h0) begin
                                result_r = alu1_i;
                                end else begin 
                                result_r = $unsigned(alu1_i) % $unsigned(alu2_i);
                            end
                        end
    endcase
    end else begin
        result_r = result_o;
    end
    end
        assign result_o = result_r;

endmodule