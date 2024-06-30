module MDU(
            input clk_i,
            input rst_i,
            input en_i,
            input [31:0]alu1_i,
            input [31:0]alu2_i,
            input [2:0] MDU_op,
            output [31:0]result_o,
            output reg mul_stall,
            output reg div_stall
);


//--Tmp Signals For this File-------------------------------------------
reg [63:0]mul_r;
reg [31:0]result_r;
wire [31:0] quo_res;
wire [31:0] rem_res;
wire mul_done, div_done;
wire [63:0] product;
//-----------------------------------------------------------------------


//--Later this should be imported
localparam [2:0]    MUL_FUNCT3    = 3'b000,
                    MULH_FUNCT3   = 3'b001,
                    MULHSU_FUNCT3 = 3'b010,
                    MULHU_FUNCT3  = 3'b011,
                    DIV_FUNCT3    = 3'b100,
                    DIVU_FUNCT3   = 3'b101,
                    REM_FUNCT3    = 3'b110,
                    REMU_FUNCT3   = 3'b111;
      




//--Multiplier and Divider Start Signals------------------------------
wire mul_en;
assign mul_en = en_i && (MDU_op == MUL_FUNCT3 || MDU_op == MULH_FUNCT3 || MDU_op == MULHSU_FUNCT3 || MDU_op == MULHU_FUNCT3) ? 1 : 0;

wire div_en;
assign div_en = en_i && (MDU_op == DIV_FUNCT3 || MDU_op == DIVU_FUNCT3 || MDU_op == REM_FUNCT3 || MDU_op == REMU_FUNCT3) ? 1 : 0;
//--------------------------------------------------------------------

//---------------Modules Instantiations-------------------------------
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

    divider_top u_divider_top(
          .clk_i(clk_i),
          .rst_i(rst_i),
          .MDU_op_i(MDU_op), // Adjusted to accommodate muldiv_funct3_t type
          .start_i(div_en),
          .numerator_i(alu1_i),
          .denominator_i(alu2_i),
          .quotient_o(quo_res),
          .remainder_o(rem_res),
          .done_o(div_done)
    );
//--------------------------------------------------------------------

//--- Multiplier And Divider Stall Signal Generation------------------
    always @* begin
        if(rst_i) begin
            mul_stall = 1'b0;
            div_stall = 1'b0;
        end else begin
            if(mul_en & !mul_done) begin
                mul_stall = 1'b1;
                div_stall = 1'b0;
            end else if ( div_en & !div_done) begin
                mul_stall = 1'b0;
                div_stall = 1'b1;
            end else begin
                mul_stall = 1'b0;
                div_stall = 1'b0;
            end
        
        end
    end
//-------------------------------------------------------------------------

//---Process The Outputs---------------------------------------------------
    always @(*) begin
        if(en_i) begin
            case(MDU_op)
                MUL_FUNCT3   :  result_r =  product[31:0 ];           
                MULH_FUNCT3  :  result_r =  product[63:32];          
                MULHSU_FUNCT3:  result_r =  product[63:32];
                MULHU_FUNCT3 :  result_r =  product[63:32];      
                DIV_FUNCT3   :  result_r =  quo_res;
                DIVU_FUNCT3  :  result_r =  quo_res;
                REM_FUNCT3   :  result_r =  rem_res;
                REMU_FUNCT3  :  result_r =  rem_res;                 
            endcase
        end else begin
            result_r = result_o;
        end
    end
//--------------------------------------------------------------------------

   assign result_o = result_r;

endmodule