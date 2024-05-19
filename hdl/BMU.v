module BMU(
    input [31:0] rs1_value_i,
    input [31:0] rs2_value_i,
    input [4:0] BMU_opcode_i,
    output reg [31:0] BMU_result_o
    );


    //Zbb Instruction variables
    wire [31:0] orcb_res  ;
    wire [5:0] clz_ctz_res; //need sign extends
    wire [31:0] sexth_zexth_res;
    reg  [31:0] rs1_ters;
    wire [31:0] rs1_selected;
    wire [31:0] rev8_res;
    wire [31:0] ror_res   ; // can be used for RORI also?
    wire [31:0] rol_res   ; // can be used for ROLI also?
    wire [31:0] sext_b_res;
    wire [5:0 ] cpop_res;
    wire sign_bit;

    wire signed [31:0] signed_rs1_value_i = rs1_value_i;
    wire signed [31:0] signed_rs2_value_i = rs2_value_i;

    wire [31:0] max_res;
    wire [31:0] maxu_res;
    wire [31:0] min_res;
    wire [31:0] minu_res;


    //Zbs Instruction variables
    wire [31:0] bit_mask  ;
    wire [31:0] bclr_res  ; // can be used for BCLRI also?
    wire [31:0] bext_res  ; // can be used for BEXTI also?
    wire [31:0] binv_res  ; // can be used for BINVI also?
    wire [31:0] bset_res  ; // can be used for BSETI also?



    //Utility values and functions
    assign rs1_selected = BMU_opcode_i[0] ? rs1_ters : rs1_value_i; //CTZ ve CLZ icin RS1 i sec.
    assign sign_bit = BMU_opcode_i[1] ? rs1_value_i[15] : 1'b0; //ZEXT ve SEXT icin sign bit sec.

    //RS1 in tersini al
    integer i;
    always @(*) begin
        for(i = 0; i < 32; i = i+1) begin
            rs1_ters[i] = rs1_value_i[31-i];
        end
    end

    //REV8 instruction
    assign rev8_res = {rs1_value_i[7:0], rs1_value_i[15:8], rs1_value_i[23:16], rs1_value_i[31:24]};


    //Rotate instructions
    assign ror_res = (rs1_value_i >> rs2_value_i) | (rs1_value_i << (32 - rs2_value_i));
    assign rol_res = (rs1_value_i << rs2_value_i) | (rs1_value_i >> (32 - rs2_value_i));
    //Zbb Instructions


    clz clz_instance(
        .rs1(rs1_selected),
        .rd(clz_ctz_res));



    cpop cpop_instance(
        .rs1_value_i(rs1_value_i),
        .ones_count_o(cpop_res)
    );

    assign sexth_zexth_res = {{16{sign_bit}}, rs1_value_i[15:0]};
    assign sext_b_res = {{24{rs1_value_i[7]}}, rs1_value_i[7:0]};
    assign orcb_res = {{8{|rs1_value_i[31:24]}}, {8{|rs1_value_i[23:16]}}, {8{|rs1_value_i[15:8]}}, {8{|rs1_value_i[7:0]}}};

    assign max_res = (signed_rs1_value_i > signed_rs2_value_i) ? rs1_value_i : rs2_value_i;
    assign maxu_res = (rs1_value_i > rs2_value_i) ? rs1_value_i : rs2_value_i;
    assign min_res = (signed_rs1_value_i < signed_rs2_value_i) ? rs1_value_i : rs2_value_i;
    assign minu_res = (rs1_value_i < rs2_value_i) ? rs1_value_i : rs2_value_i;


    //Zbs Instructions
    assign bit_mask = 32'b1 << rs2_value_i; //Index haric hepsi 0.   
    assign bclr_res = rs1_value_i & ~bit_mask; // index = 0, digerleri 1
    assign bext_res = (rs1_value_i >> rs2_value_i) & 1; 
    assign binv_res = rs1_value_i ^ bit_mask;
    assign bset_res = rs1_value_i | bit_mask;


 /*
    clz	    00000
    ctz	    00001
    cpop	00010
    orc.b	00011
    rev8	00100
    zext.h	00101
    sext.b	00110
    sext.h	00111
    rol	    01000
    ror	    01001
    bclr	01011
    bclri	01011
    bext	01100
    bexti	01100
    binv	01101
    binvi	01101
    bset	01110
    besti	01110
    max     01010
    maxu    01111
    min     10000
    minu    10001



 */

 /*
Yapilan optimizasyonlar:
1- CTZ ve CLZ ayni donanimi kullanilyor, BMU_opcode_i[0]'a eger CTZ gelmisse RS1 in tersini alip yollar.
2- Zext.h ve Sext.h ayni donanimi kullanir, sadece extend edecekleri deger belli degil, yine BMU_opcode_i ye gore
ya sext.h icin rs1[15] zext.h icin 0 secilir.

 */

    always @(*) begin
        case(BMU_opcode_i)
        5'b00000: BMU_result_o = {26'b0,clz_ctz_res}; // CLZ
        5'b00001: BMU_result_o = {26'b0,clz_ctz_res}; // CTZ
        5'b00010: BMU_result_o = {26'b0,cpop_res}; //CPOP
        5'b00011: BMU_result_o = orcb_res;        
        5'b00100: BMU_result_o = rev8_res;
        5'b00101: BMU_result_o = sexth_zexth_res;
        5'b00110: BMU_result_o = sext_b_res;
        5'b00111: BMU_result_o = sexth_zexth_res;
        5'b01000: BMU_result_o = rol_res;
        5'b01001: BMU_result_o = ror_res;
        5'b01011: BMU_result_o = bclr_res; // BMU_OPCODE Bunlara uygun uretilmeli
        5'b01100: BMU_result_o = bext_res; //
        5'b01101: BMU_result_o = binv_res;
        5'b01110: BMU_result_o = bset_res;
        5'b01010: BMU_result_o = max_res; //MAX
        5'b01111: BMU_result_o = maxu_res; //MAXU
        5'b10000: BMU_result_o = min_res; //MIN
        5'b10001: BMU_result_o = minu_res; //MINU
        default: BMU_result_o = 32'b0;
    endcase

    end


endmodule 