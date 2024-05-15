module EX_Decoder(input  wire [1:0]  EX_op ,
                  input  wire [2:0] funct3 ,
                  input  wire [6:0] funct7 ,
                  output wire [4:0] ALU_op ,
                //   output wire [4:0] BMU_op ,
                  output wire [2:0] MDU_op ,
                  output wire [1:0] chip_select);


//ALU_op = 4'b0000 = ADD

//EX_op = 01 I- TYPE


//EX_OP = 10 R-TYPE

//EX_OP muhtemelen FPU icin olur cunku inlar R4-Type



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
reg [9:0] ex_signals;         

// chip_select[1:0], ALU_op[4:0]
always @* begin 
    case (EX_op)
    2'b00: // Load, Store, Branch, AUIPC, JAL, JALR  komutlar icin. Sadecec Toplama Var
                              ex_signals = 10'b00_00000_XXX;
    2'b01: //I-Type Komutlar, funct3 e gore Ayrilir, Sonra funct7.
        begin
            if(funct3 == 3'b001     )  begin // BMU ve I-Type SHAMT iceren komutlar
                            case (funct7) 
                                SLLI_FUNCT7 : ex_signals = 10'b00_00100_XXX;
                                default:      ex_signals = 10'bXX_XXXXX_XXX; 
                            endcase
            end 
            else if(funct3 == 3'b101)  begin // BMU ve I-Type SHAMT iceren komutlar
                            case (funct7)
                                SRLI_FUNCT7: ex_signals = 10'b00_10100_XXX;
                                SRAI_FUNCT7: ex_signals = 10'b00_10110_XXX;
                                default:     ex_signals = 10'bXX_XXXXX_XXX;
                            endcase
            end
            else begin              //Diger I komutlar
                            case (funct3) 
                                ADDI_FUNCT3 : ex_signals = 10'b00_00000_XXX;
                                SLTI_FUNCT3 : ex_signals = 10'b00_01000_XXX;
                                SLTIU_FUNCT3: ex_signals = 10'b00_01100_XXX;
                                XORI_FUNCT3 : ex_signals = 10'b00_10000_XXX;
                                ORI_FUNCT3  : ex_signals = 10'b00_11000_XXX;
                                ANDI_FUNCT3 : ex_signals = 10'b00_11100_XXX;
                                default     : ex_signals = 10'bXX_XXXXX_XXX;
                            endcase
            end       
        end
    2'b10:  // R-TYPE komutlar, Ilk once FUNCT7 e gore ayrilir
        begin
            case (funct7) 
                7'b0000000: // ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND
                            case(funct3)
                                ADD_FUNCT3    : ex_signals = 10'b00_00000_XXX;
                                SLL_FUNCT3    : ex_signals = 10'b00_00100_XXX; 
                                SLT_FUNCT3    : ex_signals = 10'b00_01000_XXX;
                                SLTU_FUNCT3   : ex_signals = 10'b00_01100_XXX;
                                XOR_FUNCT3    : ex_signals = 10'b00_10000_XXX;
                                OR_FUNCT3     : ex_signals = 10'b00_11000_XXX;
                                AND_FUNCT3    : ex_signals = 10'b00_11100_XXX;
                                default       : ex_signals = 10'bXX_XXXXX_XXX;
                            endcase
                7'b0000001: //MUL, MULH, MULHSU, MULHU, DIV,DIVU, REM, REMU
                            case(funct3) 
                                MUL_FUNCT3    : ex_signals = 10'b01_XXXXX_000;
                                MULH_FUNCT3   : ex_signals = 10'b01_XXXXX_001;
                                MULHSU_FUNCT3 : ex_signals = 10'b01_XXXXX_010;
                                MULHU_FUNCT3  : ex_signals = 10'b01_XXXXX_011;
                                DIV_FUNCT3    : ex_signals = 10'b01_XXXXX_100;
                                DIVU_FUNCT3   : ex_signals = 10'b01_XXXXX_101;
                                REM_FUNCT3    : ex_signals = 10'b01_XXXXX_110;
                                REMU_FUNCT3   : ex_signals = 10'b01_XXXXX_111;
                                default       : ex_signals = 10'bXX_XXXXX_XXX;
                            endcase
                7'b0100000:
                            case(funct3)
                                SUB_FUNCT3    : ex_signals = 10'b00_00010_XXX;
                                SRA_FUNCT3    : ex_signals = 10'b00_10110_XXX;
                            endcase 
            endcase 
        end

    endcase
end

assign {chip_select,ALU_op, MDU_op} = ex_signals;

endmodule


