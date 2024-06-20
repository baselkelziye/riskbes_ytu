module EX_Decoder(input  wire [6:2] opcode,
                  input  wire [2:0] funct3 ,
                  input  wire [6:0] funct7 ,
                  input  wire [4:0] rd_label,
                  input  wire [4:0] rs1_label,
                  input  wire [4:0] rs2_label,
                  output wire [1:0] privjump,
                  output wire CSR_en,
                  output wire [1:0] CSR_op,
                  output wire CSR_source_sel,
                  output wire [3:0] ALU_op ,
                  output wire [4:0] BMU_op ,
                  output wire MDU_en,
                  output wire [2:0] MDU_op ,
                  output wire [1:0] chip_select,
                  output wire rs1_shift_sel,
                  output wire rs2_negate_sel);


wire [4:0] funct5 = rs2_label;
wire [11:0] funct12 = {funct7, funct5};

//ALU_op = 4'b0000 = ADD

//EX_op = 01 I- TYPE


//EX_OP = 10 R-TYPE

//EX_OP muhtemelen FPU icin olur cunku inlar R4-Type

//PRIVJUMP - Priviliged Jump
// 00 None
// 01 MRET
// 10 ECALL
// 11 EBREAK

//CHIP SELECT
// 00 ALU
// 01 MDU
// 10 BMU
// 11 CSRs

//OPCODES
localparam [6:2] RTYPE_OPCODE   = 5'b01100,
                 ITYPE_OPCODE   = 5'b00100,
                 STORE_OPCODE   = 5'b01000,
                 LOAD_OPCODE    = 5'b00000,
                 BRANCH_OPCODE  = 5'b11000,
                 JALR_OPCODE    = 5'b11001,
                 JAL_OPCODE     = 5'b11011,
                 AUIPC_OPCODE   = 5'b00101,
                 LUI_OPCODE     = 5'b01101,
                 SYSTEM_OPCODE  = 5'b11100;

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

localparam [2:0]    SH1ADD_FUNCT3       = 3'b010,
                    SH2ADD_FUNCT3       = 3'b100,
                    SH3ADD_FUNCT3       = 3'b110;

localparam [2:0]    CSRRW_FUNCT3        = 3'b001,
                    CSRRS_FUNCT3        = 3'b010,
                    CSRRC_FUNCT3        = 3'b011,
                    CSRRWI_FUNCT3       = 3'b101,
                    CSRRSI_FUNCT3       = 3'b110,
                    CSRRCI_FUNCT3       = 3'b111,
                    PRIVJUMP_FUNCT3     = 3'b000;

localparam [11:0]   MRET_FUNCT12        = 12'b0001000_00010,
                    WFI_FUNCT12         = 12'b0011000_00101,
                    ECALL_FUNCT12       = 12'b0000000_00000,
                    EBREAK_FUNCT12      = 12'b0000000_00001;


reg [22:0] ex_signals;         

// chip_select[1:0], CSR_en, CSR_op[1:0], CSR_source_sel, privjump[1:0], ALU_op[3:0], MDU_en, MDU_op[2:0], BMU_op[4:0], rs1_shift_sel, rs2_negate_sel
always @* begin 
    case (opcode)
    LOAD_OPCODE,
    STORE_OPCODE,
    BRANCH_OPCODE,
    AUIPC_OPCODE,
    JAL_OPCODE,
    JALR_OPCODE: // Load, Store, Branch, AUIPC, JAL, JALR  komutlar icin. Sadecec Toplama Var
        ex_signals = 23'b00_0_XX_X_00_0000_0_XXX_XXXXX_0_0;

    ITYPE_OPCODE: //I-Type Komutlar, funct3 e gore Ayrilir, Sonra funct7.
        begin
            if(funct3 == 3'b001     )  begin // BMU ve I-Type SHAMT iceren komutlar
                            case (funct7) 
                                SLLI_FUNCT7  : ex_signals = 23'b00_0_XX_X_00_0011_0_XXX_XXXXX_0_0;
                                CLZ_FUNCT7   ,
                                CTZ_FUNCT7   ,
                                CPOP_FUNCT7  ,
                                SEXT_B_FUNCT7: begin //clz,ctz,cpop,sext.b funct5 ile ayirmamiz gerekiyor
                                                case(funct5) 
                                                    CLZ_FUNCT5   : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_00000_0_0;
                                                    CTZ_FUNCT5   : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_00001_0_0;
                                                    CPOP_FUNCT5  : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_00010_0_0;
                                                    SEXT_B_FUNCT5: ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_00110_0_0;
                                                    SEXT_H_FUNCT5: ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_00111_0_0;
                                                    default      : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;  
                                                endcase    
                                                end
                                BCLRI_FUNCT7 : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01011_0_0;
                                BINVI_FUNCT7 : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01101_0_0;
                                BESTI_FUNCT7 : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01110_0_0;      
                                default      : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase
            end 
            else if(funct3 == 3'b101)  begin // BMU ve I-Type SHAMT iceren komutlar
                            case (funct7)
                                SRLI_FUNCT7 : ex_signals = 23'b00_0_XX_X_00_0111_0_XXX_XXXXX_0_0;
                                SRAI_FUNCT7 : ex_signals = 23'b00_0_XX_X_00_1000_0_XXX_XXXXX_0_0;
                                ORC_B_FUNCT7: ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_00011_0_0;
                                REV8_FUNCT7 : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_00100_0_0;
                                RORI_FUNCT7 : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01001_0_0;
                                BEXTI_FUNCT7: ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01100_0_0;
                                default     : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase
            end
            else begin              //Diger I komutlar
                            case (funct3) 
                                ADDI_FUNCT3 : ex_signals = 23'b00_0_XX_X_00_0000_0_XXX_XXXXX_0_0;
                                SLTI_FUNCT3 : ex_signals = 23'b00_0_XX_X_00_0100_0_XXX_XXXXX_0_0;
                                SLTIU_FUNCT3: ex_signals = 23'b00_0_XX_X_00_0101_0_XXX_XXXXX_0_0;
                                XORI_FUNCT3 : ex_signals = 23'b00_0_XX_X_00_0110_0_XXX_XXXXX_0_0;
                                ORI_FUNCT3  : ex_signals = 23'b00_0_XX_X_00_1001_0_XXX_XXXXX_0_0;
                                ANDI_FUNCT3 : ex_signals = 23'b00_0_XX_X_00_1010_0_XXX_XXXXX_0_0;
                                default     : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase
            end       
        end

                                        
    RTYPE_OPCODE:  // R-TYPE komutlar, Ilk once FUNCT7 e gore ayrilir
        begin
            case (funct7) 
                7'b0000000: // ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND
                            case(funct3)
                                ADD_FUNCT3    : ex_signals = 23'b00_0_XX_X_00_0000_0_XXX_XXXXX_0_0;
                                SLT_FUNCT3    : ex_signals = 23'b00_0_XX_X_00_0100_0_XXX_XXXXX_0_0;
                                SLL_FUNCT3    : ex_signals = 23'b00_0_XX_X_00_0011_0_XXX_XXXXX_0_0; 
                                SLTU_FUNCT3   : ex_signals = 23'b00_0_XX_X_00_0101_0_XXX_XXXXX_0_0;
                                XOR_FUNCT3    : ex_signals = 23'b00_0_XX_X_00_0110_0_XXX_XXXXX_0_0;
                                OR_FUNCT3     : ex_signals = 23'b00_0_XX_X_00_1001_0_XXX_XXXXX_0_0;
                                AND_FUNCT3    : ex_signals = 23'b00_0_XX_X_00_1010_0_XXX_XXXXX_0_0;
                                default       : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase
                7'b0000001: //MUL, MULH, MULHSU, MULHU, DIV,DIVU, REM, REMU
                            case(funct3) 
                                MUL_FUNCT3    : ex_signals = 23'b01_0_XX_X_00_XXXX_1_000_XXXXX_0_0;
                                MULH_FUNCT3   : ex_signals = 23'b01_0_XX_X_00_XXXX_1_001_XXXXX_0_0;
                                MULHSU_FUNCT3 : ex_signals = 23'b01_0_XX_X_00_XXXX_1_010_XXXXX_0_0;
                                MULHU_FUNCT3  : ex_signals = 23'b01_0_XX_X_00_XXXX_1_011_XXXXX_0_0;
                                DIV_FUNCT3    : ex_signals = 23'b01_0_XX_X_00_XXXX_1_100_XXXXX_0_0;
                                DIVU_FUNCT3   : ex_signals = 23'b01_0_XX_X_00_XXXX_1_101_XXXXX_0_0;
                                REM_FUNCT3    : ex_signals = 23'b01_0_XX_X_00_XXXX_1_110_XXXXX_0_0;
                                REMU_FUNCT3   : ex_signals = 23'b01_0_XX_X_00_XXXX_1_111_XXXXX_0_0;
                                default       : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase
                7'b0100000: // SUB, SRA, ANDN, ORN, XNOR
                            case(funct3)
                                SUB_FUNCT3    : ex_signals = 23'b00_0_XX_X_00_0001_0_XXX_XXXXX_0_1;
                                SRA_FUNCT3    : ex_signals = 23'b00_0_XX_X_00_1000_0_XXX_XXXXX_0_0;
                                ANDN_FUNCT3   : ex_signals = 23'b00_0_XX_X_00_1010_0_XXX_XXXXX_0_1;
                                ORN_FUNCT3    : ex_signals = 23'b00_0_XX_X_00_1001_0_XXX_XXXXX_0_1;
                                XNOR_FUNCT3   : ex_signals = 23'b00_0_XX_X_00_1011_0_XXX_XXXXX_0_0;
                                default       : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase
                7'b0000100:  /*ZEXT.h Icin*/    ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_00101_0_0;
                7'b0110000: // ROL, ROR
                            case(funct3)
                                ROL_FUNCT3    : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01000_0_0;
                                ROR_FUNCT3    : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01001_0_0;
                                default       : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase 
                7'b0100100: //BCLR, BEXT
                            case(funct3)
                                BCLR_FUNCT3   : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01011_0_0;
                                BEXT_FUNCT3   : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01100_0_0;
                                default       : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase 
                7'b0110100: /* BINV*/           ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01101_0_0;
                7'b0010100: /*BSET*/            ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01110_0_0;
                7'b0000101: //MAX,MAXU, MIN,MINU
                            case(funct3)
                                MAX_FUNCT3    : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01010_0_0;
                                MAXU_FUNCT3   : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_01111_0_0;
                                MIN_FUNCT3    : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_10000_0_0;
                                MINU_FUNCT3   : ex_signals = 23'b10_0_XX_X_00_XXXX_0_XXX_10001_0_0;
                                default       : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase
                7'b0010000: //SH1ADD,SH2ADD,SH3ADD
                            case(funct3)
                                SH1ADD_FUNCT3 : ex_signals = 23'b00_0_XX_X_00_0000_0_XXX_XXXXX_1_0; 
                                SH2ADD_FUNCT3 : ex_signals = 23'b00_0_XX_X_00_0000_0_XXX_XXXXX_1_0;
                                SH3ADD_FUNCT3 : ex_signals = 23'b00_0_XX_X_00_0000_0_XXX_XXXXX_1_0;
                                default       : ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            endcase
            default: ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                            
            endcase 
        end
   LUI_OPCODE: ex_signals = 23'b00_0_XX_X_00_1100_0_XXX_XXXXX_0_0;
   SYSTEM_OPCODE: case(funct3)
         CSRRW_FUNCT3 :  ex_signals = 23'b11_1_01_0_00_XXXX_0_XXX_XXXXX_X_X;
         CSRRS_FUNCT3 :  ex_signals = 23'b11_1_10_0_00_XXXX_0_XXX_XXXXX_X_X;
         CSRRC_FUNCT3 :  ex_signals = 23'b11_1_11_0_00_XXXX_0_XXX_XXXXX_X_X;
         CSRRWI_FUNCT3 : ex_signals = 23'b11_1_01_1_00_XXXX_0_XXX_XXXXX_X_X;
         CSRRSI_FUNCT3 : ex_signals = 23'b11_1_10_1_00_XXXX_0_XXX_XXXXX_X_X;
         CSRRCI_FUNCT3 : ex_signals = 23'b11_1_11_1_00_XXXX_0_XXX_XXXXX_X_X;
         PRIVJUMP_FUNCT3 :  begin
            if(rd_label == 0 && rs1_label == 0) begin
                case (funct12)
                    ECALL_FUNCT12 :     ex_signals = 23'bXX_0_XX_X_10_XXXX_0_XXX_XXXXX_X_X;
                    EBREAK_FUNCT12 :    ex_signals = 23'bXX_0_XX_X_11_XXXX_0_XXX_XXXXX_X_X;
                    MRET_FUNCT12 :      ex_signals = 23'bXX_0_XX_X_01_XXXX_0_XXX_XXXXX_X_X;
                    WFI_FUNCT12 :       ex_signals = 23'bXX_0_XX_X_00_XXXX_0_XXX_XXXXX_X_X; //WFI=NOP
                    default:            ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
                endcase
            end else begin
                ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
            end
         end
      endcase
   default: ex_signals = 23'bXX_X_XX_X_XX_XXXX_X_XXX_XXXXX_X_X;
   endcase
end

assign {chip_select, CSR_en, CSR_op, CSR_source_sel, privjump, ALU_op, MDU_en, MDU_op, BMU_op, rs1_shift_sel, rs2_negate_sel} = ex_signals;

endmodule


