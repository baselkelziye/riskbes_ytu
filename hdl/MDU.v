module MDU(
            input clk_i,
            input rst_i,
            input mul_en,
            input [31:0]alu1_i,
            input [31:0]alu2_i,
            input [2:0] MDU_op,
            input [1:0] chip_select,
            output [31:0]result_o,
            output  mul_stall
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
      

wire mul_done;
//wire [31:0] product_high, product_low;
wire [63:0] product_i;
wire [63:0] product;
//wire mul_en;
//assign mul_en = (MDU_op == MUL_FUNCT3 || MDU_op == MULH_FUNCT3 || MDU_op == MULHSU_FUNCT3 || MDU_op == MULHU_FUNCT3) ? 1 : 0;


wire [63:0] product_neg = ~product + 1;
reg neg_result;
wire [31:0] alu1_i_neg = ~alu1_i + 1;
wire [31:0] alu2_i_neg = ~alu2_i + 1;

reg [31:0] MDU1_i, MDU2_i;
assign product = MDU1_i *MDU2_i;
always @(*) begin
    if(chip_select == 2'b01) begin
        case(MDU_op)
            MUL_FUNCT3   : begin
                                neg_result = alu1_i[31] ^ alu2_i[31];
                                MDU1_i = alu1_i[31] ? alu1_i_neg : alu1_i;
                                MDU2_i = alu2_i[31] ? alu2_i_neg : alu2_i;
                                result_r = neg_result ? product_neg[31:0] : product[31:0];
            end
            
            MULH_FUNCT3  :  begin
                                neg_result = alu1_i[31] ^ alu2_i[31];
                                MDU1_i = alu1_i[31] ? alu1_i_neg : alu1_i;
                                MDU2_i = alu2_i[31] ? alu2_i_neg : alu2_i;
                                result_r = neg_result ? product_neg[63:32] : product[63:32];
            end 
            MULHSU_FUNCT3:  begin
                                neg_result = alu1_i[31];
                                MDU1_i = alu1_i[31] ? alu1_i_neg : alu1_i;
                                MDU2_i = alu2_i;
                                result_r = neg_result ? product_neg[63:32] : product[63:32];
            end
    
            MULHU_FUNCT3 : begin
                                neg_result = 1'b0;
                                MDU1_i = alu1_i;
                                MDU2_i = alu2_i;
                                result_r = product[63:32];
            end
            
        
        endcase
    end else begin
        result_r = result_o;
    end
end
assign mul_stall = 1'b0;
//always @(*) begin
//    if(rst_i) begin
//        mul_stall = 1'b0;
//    end else if(mul_en & !mul_done) begin
//        mul_stall = 1'b1;
//    end else begin
//        mul_stall = 1'b0;
//    end
//end

//assign mul_stall = 1'b0;
//    multiplier_pipelined u_multiplier_pipelined(
//     .clk_i(clk_i),
//     .rst_i(rst_i || !mul_en),
//     .en_i(mul_en),
//     .muler_i(MDU1_i),
//     .mulcand_i(MDU2_i),
//     .product_o(product_i),
//     .ack_o(mul_done)
////     .running(mul_stall) // mul oldugu surece pipeline i stall et
//    );
    
//    assign mul_stall = (mul_en == 1'b1 && mul_done == 1'b0) ? 1 : 0;
//      assign mul_stall = 0;
//    d_reg_en REG_HIGH
//    (
//        .clk_i    (clk_i),
//        .rst_i    (rst_i),
//        .en_i   (mul_done),
//        .data_i        (product[63:32]),
//        .data_o        (product_high)
//    );
    
    
//    d_reg_en REG_LOW 
//    (
//        .clk_i    (clk_i),
//        .rst_i    (rst_i),
//        .en_i   (mul_done),
//        .data_i        (product[31:0]),
//        .data_o        (product_low)
//    );
    
//     d_reg_en REG_PRODUCT(
//        .clk_i(clk_i),
//        .rst_i(rst_i),
//        .en_i(mul_done),
//        .data_i(product_i),
//        .data_o(product)
//     );

//assign product = (mul_done == 1) ? product_i : 64'hAABBCCDDEEFFAA;

// always @* begin
//     if(chip_select == 2'b01) begin
//     case(MDU_op)
//         MUL_FUNCT3    : begin
//                         neg_result = MDU_in1[31] ^ MDU_in2[31];
// //                        MDU_in1[
//                         result_r = MDU_in1 * MDU_in2;
//                         end

//         MULH_FUNCT3   : begin
//                         mul_r = MDU_in1 * MDU_in2;
//                         result_r = mul_r[63:32];
//                         end

//         MULHSU_FUNCT3 : begin
//                         mul_r = MDU_in1 * MDU_in2;
//                         result_r = mul_r[63:32];
//                         end

//         MULHU_FUNCT3  : begin
//                         mul_r = MDU_in1 * MDU_in2;
//                         result_r = mul_r[63:32];
//                         end
        
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