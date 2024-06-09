module EX_Decoder(input  wire [1:0]  EX_op ,
                  input  wire [2:0] funct3 ,
                  input  wire [4:0] funct5 ,
                  input  wire [6:0] funct7 ,
                  output wire [3:0] ALU_op ,
                  output wire [4:0] BMU_op ,
                  output wire [2:0] MDU_op ,
                  output wire [1:0] chip_select,
                  output wire rs1_shift_sel,
                  output wire rs2_negate_sel);


//ALU_op = 4'b0000 = ADD

//EX_op = 00 various
//EX_op = 01 I-TYPE
//EX_OP = 10 R-TYPE


//CHIP SELECT
// 00 ALU
// 01 MDU
// 10 BMU
// 11 FPU

reg [1:0] chip_select_reg;

localparam [2:0]    ADDI_FUNCT3  = 3'b000,
                    SLTI_FUNCT3  = 3'b010,
                    SLTIU_FUNCT3 = 3'b011,
                    XORI_FUNCT3  = 3'b100,
                    ORI_FUNCT3   = 3'b110,
                    ANDI_FUNCT3  = 3'b111;      
//I-TYPE FUNCT7
localparam [6:0]    SLLI_FUNCT7  = 7'b0000000,
                    SRLI_FUNCT7  = 7'b0000000,
                    SRAI_FUNCT7  = 7'b0100000;



//R-TYPE RV32I FUNCT7
localparam [6:0]    ADD_FUNCT7   = 7'b0000000,
                    SUB_FUNCT7   = 7'b0100000,
                    SLL_FUNCT7   = 7'b0000000,
                    SLT_FUNCT7   = 7'b0000000,
                    SLTU_FUNCT7  = 7'b0000000,
                    XOR_FUNCT7   = 7'b0000000,
                    SRL_FUNCT7   = 7'b0000000,
                    SRA_FUNCT7   = 7'b0100000,
                    OR_FUNCT7    = 7'b0000000,
                    AND_FUNCT7   = 7'b0000000;

localparam [2:0]    ADD_FUNCT3   = 3'b000,
                    SUB_FUNCT3   = 3'b000,
                    SLL_FUNCT3   = 3'b001,
                    SLT_FUNCT3   = 3'b010,
                    SLTU_FUNCT3  = 3'b011,
                    XOR_FUNCT3   = 3'b100,
                    SRL_FUNCT3   = 3'b101,
                    SRA_FUNCT3   = 3'b101,
                    OR_FUNCT3    = 3'b110,
                    AND_FUNCT3   = 3'b111;     

localparam [2:0]    MUL_FUNCT3    = 3'b000,
                    MULH_FUNCT3   = 3'b001,
                    MULHSU_FUNCT3 = 3'b010,
                    MULHU_FUNCT3  = 3'b011,
                    DIV_FUNCT3    = 3'b100,
                    DIVU_FUNCT3   = 3'b101,
                    REM_FUNCT3    = 3'b110,
                    REMU_FUNCT3   = 3'b111;

localparam [6:0]    CLZ_FUNCT7    = 7'b0110000,
                    CTZ_FUNCT7    = 7'b0110000,
                    CPOP_FUNCT7   = 7'b0110000,
                    ORC_B_FUNCT7  = 7'b0010100,
                    REV8_FUNCT7   = 7'b0110100,
                    SEXT_B_FUNCT7 = 7'b0110000,
                    SEXT_H_FUNCT7 = 7'b0110000,
                    RORI_FUNCT7   = 7'b0110000,
                    BCLRI_FUNCT7  = 7'b0100100,
                    BEXTI_FUNCT7  = 7'b0100100,
                    BINVI_FUNCT7  = 7'b0110100,
                    BESTI_FUNCT7  = 7'b0010100,
                    ANDN_FUNCT7   = 7'b0100000,
                    ORN_FUNCT7    = 7'b0100000,
                    XNOR_FUNCT7   = 7'b0100000;

localparam [2:0]    CLZ_FUNCT3    = 3'b001,
                    CTZ_FUNCT3    = 3'b001,
                    CPOP_FUNCT3   = 3'b001,
                    ORC_B_FUNCT3  = 3'b101,
                    REV8_FUNCT3   = 3'b101,
                    SEXT_B_FUNCT3 = 3'b001,
                    SEXT_H_FUNCT3 = 3'b001,
                    RORI_FUNCT3   = 3'b101,
                    BCLRI_FUNCT3  = 3'b001,
                    BEXTI_FUNCT3  = 3'b101,
                    BINVI_FUNCT3  = 3'b001,
                    BESTI_FUNCT3  = 3'b001;

localparam [4:0]    CLZ_FUNCT5    = 5'b00000,
                    CTZ_FUNCT5    = 5'b00001,
                    CPOP_FUNCT5   = 5'b00010,
                    ORC_B_FUNCT5  = 5'b00111,
                    REV8_FUNCT5   = 5'b11000,
                    SEXT_B_FUNCT5 = 5'b00100,
                    SEXT_H_FUNCT5 = 5'b00101,
                    RORI_FUNCT5   = 5'bXXXXX,
                    BCLRI_FUNCT5  = 5'bXXXXX,
                    BEXTI_FUNCT5  = 5'bXXXXX,
                    BINVI_FUNCT5  = 5'bXXXXX,
                    BESTI_FUNCT5  = 5'bXXXXX;

localparam [2:0]    ROL_FUNCT3   = 3'b001,
                    ROR_FUNCT3   = 3'b101,
                    BCLR_FUNCT3  = 3'b001,
                    BEXT_FUNCT3  = 3'b101,
                    BINV_FUNCT3  = 3'b001,
                    BSET_FUNCT3  = 3'b001,
                    MAX_FUNCT3   = 3'b111,
                    MAXU_FUNCT3  = 3'b110,
                    MIN_FUNCT3   = 3'b100,
                    MINU_FUNCT3  = 3'b101,
                    ANDN_FUNCT3  = 3'b111,
                    ORN_FUNCT3   = 3'b110,
                    XNOR_FUNCT3  = 3'b100;

localparam [6:0]    SH1ADD_FUNCT7       = 7'b0010000,
                    SH2ADD_FUNCT7       = 7'b0010000,
                    SH3ADD_FUNCT7       = 7'b0010000;

localparam [2:0]    SH1ADD_FUNCT3       =3'b010,
                    SH2ADD_FUNCT3       =3'b100,
                    SH3ADD_FUNCT3       =3'b110;



reg [15:0] ex_signals;         

// chip_select[1:0], ALU_op[3:0], MDU_op[2:0], BMU_op[4:0], rs1_shift_sel, rs2_negate_sel
always @* begin 
    case (EX_op)
    2'b00: // Load, Store, Branch, AUIPC, JAL, JALR  komutlar icin. Sadecec Toplama Var
                              ex_signals = 16'b00_0000_XXX_XXXXX_0_0;

    2'b01: //I-Type Komutlar, funct3 e gore Ayrilir, Sonra funct7.
        begin
            if(funct3 == 3'b001     )  begin // BMU ve I-Type SHAMT iceren komutlar
                            case (funct7) 
                                SLLI_FUNCT7  : ex_signals = 16'b00_0011_XXX_XXXXX_0_0;
                                CLZ_FUNCT7   ,
                                CTZ_FUNCT7   ,
                                CPOP_FUNCT7  ,
                                SEXT_B_FUNCT7: begin //clz,ctz,cpop,sext.b funct5 ile ayirmamiz gerekiyor
                                                case(funct5) 
                                                    CLZ_FUNCT5   : ex_signals = 16'b10_XXXX_XXX_00000_0_0;
                                                    CTZ_FUNCT5   : ex_signals = 16'b10_XXXX_XXX_00001_0_0;
                                                    CPOP_FUNCT5  : ex_signals = 16'b10_XXXX_XXX_00010_0_0;
                                                    SEXT_B_FUNCT5: ex_signals = 16'b10_XXXX_XXX_00110_0_0;
                                                    SEXT_H_FUNCT5: ex_signals = 16'b10_XXXX_XXX_00111_0_0;
                                                    default      : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;  
                                                endcase    
                                                end
                                BCLRI_FUNCT7 : ex_signals = 16'b10_XXXX_XXX_01011_0_0;
                                BINVI_FUNCT7 : ex_signals = 16'b10_XXXX_XXX_01101_0_0;
                                BESTI_FUNCT7 : ex_signals = 16'b10_XXXX_XXX_01110_0_0;      
                                default      : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            endcase
            end 
            else if(funct3 == 3'b101)  begin // BMU ve I-Type SHAMT iceren komutlar
                            case (funct7)
                                SRLI_FUNCT7 : ex_signals = 16'b00_0111_XXX_XXXXX_0_0;
                                SRAI_FUNCT7 : ex_signals = 16'b00_1000_XXX_XXXXX_0_0;
                                ORC_B_FUNCT7: ex_signals = 16'b10_XXXX_XXX_00011_0_0;
                                REV8_FUNCT7 : ex_signals = 16'b10_XXXX_XXX_00100_0_0;
                                RORI_FUNCT7 : ex_signals = 16'b10_XXXX_XXX_01001_0_0;
                                BEXTI_FUNCT7: ex_signals = 16'b10_XXXX_XXX_01100_0_0;
                                default     : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            endcase
            end
            else begin              //Diger I komutlar
                            case (funct3) 
                                ADDI_FUNCT3 : ex_signals = 16'b00_0000_XXX_XXXXX_0_0;
                                SLTI_FUNCT3 : ex_signals = 16'b00_0100_XXX_XXXXX_0_0;
                                SLTIU_FUNCT3: ex_signals = 16'b00_0101_XXX_XXXXX_0_0;
                                XORI_FUNCT3 : ex_signals = 16'b00_0110_XXX_XXXXX_0_0;
                                ORI_FUNCT3  : ex_signals = 16'b00_1001_XXX_XXXXX_0_0;
                                ANDI_FUNCT3 : ex_signals = 16'b00_1010_XXX_XXXXX_0_0;
                                default     : ex_signals = 16'bXX_XXXX_XXX_XXXXX_0_X;
                            endcase
            end       
        end

                                        
    2'b10:  // R-TYPE komutlar, Ilk once FUNCT7 e gore ayrilir
        begin
            case (funct7) 
                7'b0000000: // ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND
                            case(funct3)
                                ADD_FUNCT3    : ex_signals = 16'b00_0000_XXX_XXXXX_0_0;
                                SLT_FUNCT3    : ex_signals = 16'b00_0100_XXX_XXXXX_0_0;
                                SLL_FUNCT3    : ex_signals = 16'b00_0011_XXX_XXXXX_0_0; 
                                SLTU_FUNCT3   : ex_signals = 16'b00_0101_XXX_XXXXX_0_0;
                                XOR_FUNCT3    : ex_signals = 16'b00_0110_XXX_XXXXX_0_0;
                                OR_FUNCT3     : ex_signals = 16'b00_1001_XXX_XXXXX_0_0;
                                AND_FUNCT3    : ex_signals = 16'b00_1010_XXX_XXXXX_0_0;
                                default       : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            endcase
                7'b0000001: //MUL, MULH, MULHSU, MULHU, DIV,DIVU, REM, REMU
                            case(funct3) 
                                MUL_FUNCT3    : ex_signals = 16'b01_XXXX_000_XXXXX_0_0;
                                MULH_FUNCT3   : ex_signals = 16'b01_XXXX_001_XXXXX_0_0;
                                MULHSU_FUNCT3 : ex_signals = 16'b01_XXXX_010_XXXXX_0_0;
                                MULHU_FUNCT3  : ex_signals = 16'b01_XXXX_011_XXXXX_0_0;
                                DIV_FUNCT3    : ex_signals = 16'b01_XXXX_100_XXXXX_0_0;
                                DIVU_FUNCT3   : ex_signals = 16'b01_XXXX_101_XXXXX_0_0;
                                REM_FUNCT3    : ex_signals = 16'b01_XXXX_110_XXXXX_0_0;
                                REMU_FUNCT3   : ex_signals = 16'b01_XXXX_111_XXXXX_0_0;
                                default       : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            endcase
                7'b0100000: // SUB, SRA, ANDN, ORN, XNOR
                            case(funct3)
                                SUB_FUNCT3    : ex_signals = 16'b00_0001_XXX_XXXXX_0_1;
                                SRA_FUNCT3    : ex_signals = 16'b00_1000_XXX_XXXXX_0_0;
                                ANDN_FUNCT3   : ex_signals = 16'b00_1010_XXX_XXXXX_0_1;
                                ORN_FUNCT3    : ex_signals = 16'b00_1001_XXX_XXXXX_0_1;
                                XNOR_FUNCT3   : ex_signals = 16'b00_1011_XXX_XXXXX_0_0;
                                default       : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            endcase
                7'b0000100:  /*ZEXT.h Icin*/    ex_signals = 16'b10_XXXX_XXX_00101_0_0;
                7'b0110000: // ROL, ROR
                            case(funct3)
                                ROL_FUNCT3    : ex_signals = 16'b10_XXXX_XXX_01000_0_0;
                                ROR_FUNCT3    : ex_signals = 16'b10_XXXX_XXX_01001_0_0;
                                default       : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            endcase 
                7'b0100100: //BCLR, BEXT
                            case(funct3)
                                BCLR_FUNCT3   : ex_signals = 16'b10_XXXX_XXX_01011_0_0;
                                BEXT_FUNCT3   : ex_signals = 16'b10_XXXX_XXX_01100_0_0;
                                default       : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            endcase 
                7'b0110100: /* BINV*/           ex_signals = 16'b10_XXXX_XXX_01101_0_0;
                7'b0010100: /*BSET*/            ex_signals = 16'b10_XXXX_XXX_01110_0_0;
                7'b0000101: //MAX,MAXU, MIN,MINU
                            case(funct3)
                                MAX_FUNCT3    : ex_signals = 16'b10_XXXX_XXX_01010_0_0;
                                MAXU_FUNCT3   : ex_signals = 16'b10_XXXX_XXX_01111_0_0;
                                MIN_FUNCT3    : ex_signals = 16'b10_XXXX_XXX_10000_0_0;
                                MINU_FUNCT3   : ex_signals = 16'b10_XXXX_XXX_10001_0_0;
                                default       : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            endcase
                7'b0010000: //SH1ADD,SH2ADD,SH3ADD
                            case(funct3)
                                SH1ADD_FUNCT3 : ex_signals = 16'b00_0000_XXX_XXXXX_1_0; 
                                SH2ADD_FUNCT3 : ex_signals = 16'b00_0000_XXX_XXXXX_1_0;
                                SH3ADD_FUNCT3 : ex_signals = 16'b00_0000_XXX_XXXXX_1_0;
                                default       : ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            endcase
            default: ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
                            
            endcase 
        end
    default: ex_signals = 16'bXX_XXXX_XXX_XXXXX_X_X;
    endcase
end

assign {chip_select,ALU_op, MDU_op, BMU_op, rs1_shift_sel, rs2_negate_sel} = ex_signals;

endmodule


