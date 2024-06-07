module MDU(
            input clk_i,
            input rst_i,
//            input mul_en,
            input [31:0]alu1_i,
            input [31:0]alu2_i,
            input [2:0] MDU_op,
            input [1:0] chip_select,
            output [31:0]result_o,
            output reg mul_stall,
            output reg div_stall
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
      

wire mul_done, div_done;
wire [63:0] product;


wire mul_en;
assign mul_en = (MDU_op == MUL_FUNCT3 || MDU_op == MULH_FUNCT3 || MDU_op == MULHSU_FUNCT3 || MDU_op == MULHU_FUNCT3) ? 1 : 0;

wire div_en;
assign div_en = (MDU_op == DIV_FUNCT3 || MDU_op == DIVU_FUNCT3 || MDU_op == REM_FUNCT3 || MDU_op == REMU_FUNCT3) ? 1 : 0;

 multiplier_top u_multiplier_top(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .a(alu1_i),
        .b(alu2_i),
        .start(mul_en),
        .MDU_op(MDU_op),
        .product(product),
        .done(mul_done)
);

wire [31:0] quo_res;
wire [31:0] rem_res;

divider_pipelined u_divider_pipelined(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .dividend_i(alu1_i),
        .divisor_i(alu2_i),
        .en_i(div_en),
        .quo_o(quo_res),
        .rem_o(rem_res),
        .ack_o(div_done)
);



always @(*) begin
    if(rst_i) begin
        mul_stall   = 1'b0;
        div_stall   = 1'b0;
    end else if(mul_en & !mul_done) begin
        mul_stall = 1'b1;
    end else if(div_en & !div_done) begin
        div_stall = 1'b1;
    end else begin
        mul_stall = 1'b0;
        div_stall = 1'b0;
    end
end

always @(*) begin
    if(chip_select == 2'b01) begin
        case(MDU_op)
            MUL_FUNCT3   :  result_r =  product[31:0 ];           
            MULH_FUNCT3  :  result_r =  product[63:32];          
            MULHSU_FUNCT3:  result_r =  product[63:32];
            MULHU_FUNCT3 :  result_r =  product[63:32];                   
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



// always @* begin
//     if(chip_select == 2'b01) begin
//     case(MDU_op)
        
//         DIV_FUNCT3    : begin
//                             if(alu2_i == 32'h0) begin
//                             result_r = -32'h1; 
//                             end else if(alu1_i[31] == 1'b1 && alu2_i == -32'h1) begin 
//                             result_r = alu1_i;
//                             end else begin 
//                             result_r = $signed(alu1_i) / $signed(alu2_i);
//                             end
//                         end
        
//         DIVU_FUNCT3   : begin
//                             if(alu2_i == 32'h0) begin
//                             result_r = (2**32)-1;
//                             end else begin 
//                             result_r = $unsigned(alu1_i) / $unsigned(alu2_i);
//                             end
//                         end
        
//         REM_FUNCT3    : begin
//                             if(alu2_i == 32'h0) begin
//                                 result_r = alu1_i; 
//                                 end else if(alu1_i[31] == 1'b1 && alu2_i == -32'h1) begin 
//                                 result_r = 32'h0;
//                                 end else begin 
//                                 result_r = $signed(alu1_i) % $signed(alu2_i);
//                             end
//                         end
        
//         REMU_FUNCT3   : begin
//                             if(alu2_i == 32'h0) begin
//                                 result_r = alu1_i;
//                                 end else begin 
//                                 result_r = $unsigned(alu1_i) % $unsigned(alu2_i);
//                             end
//                         end
//     endcase
//     end else begin
//         result_r = result_o;
//     end
//     end
        assign result_o = result_r;

endmodule