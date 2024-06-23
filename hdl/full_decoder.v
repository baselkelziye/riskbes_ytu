module full_decoder(
   input [31:2] instr_i,

   //Uzantı destek bitleri (Forwarded)
   input is_a_supported_i,
   input is_b_supported_i,
   input is_f_supported_i,
   input is_m_supported_i,

   output [2:0] exception_o,
   output is_mret_o,
   output CSR_en_o,
   output [1:0] CSR_op_o,
   output CSR_source_sel_o,
   output [3:0] ALU_op_o ,
   output [4:0] BMU_op_o ,
   output MDU_en_o,
   output [2:0] MDU_op_o ,
   output [1:0] chip_select_o,
   output rs1_shift_sel_o,
   output rs2_negate_sel_o,
   output reg_wr_en_o,
   output [1:0] wb_sel_o,
   output op1_sel_o,
   output op2_sel_o,
   output is_load_instr_o,
   output is_store_instr_o
);

   wire [6:2] opcode = instr_i[6:2];
   wire [2:0] funct3 = instr_i[14:12];
   wire [4:0] funct5 = instr_i[24:20];
   wire [6:0] funct7 = instr_i[31:25];
   wire [11:0] funct12 = instr_i[31:20];

   wire [4:0] rd_label = instr_i[11:7];
   wire [4:0] rs1_label = instr_i[19:15];
   wire [4:0] rs2_label = instr_i[24:20];

   //ALU_op_o = 4'b0000 = ADD

   //EXCEPTION - Exception
   // 000 None
   // 001 Illegal Instruction
   // 010 ECALL
   // 011 EBREAK
   // 100 Misaligned Instruction
   // 101 Instruction Access Fault
   // 110-111 Reserved

   //CHIP SELECT
   // 00 ALU
   // 01 MDU
   // 10 BMU
   // 11 CSR

   //OPCODES
   localparam [6:2]  RTYPE_OPCODE   = 5'b01100,
                     ITYPE_OPCODE   = 5'b00100,
                     STORE_OPCODE   = 5'b01000,
                     LOAD_OPCODE    = 5'b00000,
                     BRANCH_OPCODE  = 5'b11000,
                     JALR_OPCODE    = 5'b11001,
                     JAL_OPCODE     = 5'b11011,
                     AUIPC_OPCODE   = 5'b00101,
                     LUI_OPCODE     = 5'b01101,
                     SYSTEM_OPCODE  = 5'b11100;

   localparam [2:0]  ADDI_FUNCT3          = 3'b000,
                     SLTI_FUNCT3          = 3'b010,
                     SLTIU_FUNCT3         = 3'b011,
                     XORI_FUNCT3          = 3'b100,
                     ORI_FUNCT3           = 3'b110,
                     ANDI_FUNCT3          = 3'b111,
                     BMU_SHAMT_A_FUNCT3   = 3'b001,
                     BMU_SHAMT_B_FUNCT3   = 3'b101;      

   //JALR FUNCT3
   localparam [2:0] JALR_FUNCT3 = 3'b000;

   //LOAD FUNCT3
   localparam [2:0] LB_FUNCT3  = 3'b000,
                    LH_FUNCT3  = 3'b001,
                    LW_FUNCT3  = 3'b010,
                    LBU_FUNCT3 = 3'b100,
                    LHU_FUNCT3 = 3'b101;

   //STORE FUNCT3
   localparam [2:0] SB_FUNCT3  = 3'b000,
                    SH_FUNCT3  = 3'b001,
                    SW_FUNCT3  = 3'b010;

   //BRANCH FUNCT3
   localparam [2:0] BEQ_FUNCT3  = 3'b000,
                    BNE_FUNCT3  = 3'b001,
                    BLT_FUNCT3  = 3'b100,
                    BGE_FUNCT3  = 3'b101,
                    BLTU_FUNCT3 = 3'b110,
                    BGEU_FUNCT3 = 3'b111;

   //I-TYPE FUNCT7
   localparam [6:0]  SLLI_FUNCT7  = 7'b0000000,
                     SRLI_FUNCT7  = 7'b0000000,
                     SRAI_FUNCT7  = 7'b0100000;

   //R-TYPE RV32I FUNCT7
   localparam [6:0]  ADD_FUNCT7   = 7'b0000000,
                     SUB_FUNCT7   = 7'b0100000,
                     SLL_FUNCT7   = 7'b0000000,
                     SLT_FUNCT7   = 7'b0000000,
                     SLTU_FUNCT7  = 7'b0000000,
                     XOR_FUNCT7   = 7'b0000000,
                     SRL_FUNCT7   = 7'b0000000,
                     SRA_FUNCT7   = 7'b0100000,
                     OR_FUNCT7    = 7'b0000000,
                     AND_FUNCT7   = 7'b0000000;

   localparam [2:0]  ADD_FUNCT3   = 3'b000,
                     SUB_FUNCT3   = 3'b000,
                     SLL_FUNCT3   = 3'b001,
                     SLT_FUNCT3   = 3'b010,
                     SLTU_FUNCT3  = 3'b011,
                     XOR_FUNCT3   = 3'b100,
                     SRL_FUNCT3   = 3'b101,
                     SRA_FUNCT3   = 3'b101,
                     OR_FUNCT3    = 3'b110,
                     AND_FUNCT3   = 3'b111;     

   localparam [2:0]  MUL_FUNCT3    = 3'b000,
                     MULH_FUNCT3   = 3'b001,
                     MULHSU_FUNCT3 = 3'b010,
                     MULHU_FUNCT3  = 3'b011,
                     DIV_FUNCT3    = 3'b100,
                     DIVU_FUNCT3   = 3'b101,
                     REM_FUNCT3    = 3'b110,
                     REMU_FUNCT3   = 3'b111;

   localparam [6:0]  BMU_F5_FUNCT7        = 7'b0110000,
                     ORC_B_FUNCT7         = 7'b0010100,
                     REV8_FUNCT7          = 7'b0110100,
                     RORI_FUNCT7          = 7'b0110000,
                     BCLRI_FUNCT7         = 7'b0100100,
                     BEXTI_FUNCT7         = 7'b0100100,
                     BINVI_FUNCT7         = 7'b0110100,
                     BESTI_FUNCT7         = 7'b0010100,
                     ANDN_FUNCT7          = 7'b0100000,
                     ORN_FUNCT7           = 7'b0100000,
                     XNOR_FUNCT7          = 7'b0100000;

   localparam [2:0]  CLZ_FUNCT3    = 3'b001,
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

   localparam [4:0]  CLZ_FUNCT5    = 5'b00000,
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

   localparam [2:0]  ROL_FUNCT3   = 3'b001,
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

   localparam [6:0]  SHADD_FUNCT7        = 7'b0010000,
                     MINMAX_FUNCT7       = 7'b0000101,
                     BSET_FUNCT7         = 7'b0010100,
                     BINV_FUNCT7         = 7'b0110100,
                     BEXT_BCLR_FUNCT7    = 7'b0100100,
                     ROTATE_FUNCT7       = 7'b0110000,
                     ZEXT_H_FUNCT7       = 7'b0000100,
                     SIMPLE_FUNCT7       = 7'b0000000,
                     SIMPLE_ALT_FUNCT7   = 7'b0100000,
                     MDU_FUNCT7          = 7'b0000001;

   localparam [2:0]  SH1ADD_FUNCT3        = 3'b010,
                     SH2ADD_FUNCT3        = 3'b100,
                     SH3ADD_FUNCT3        = 3'b110;

   localparam [2:0]  CSRRW_FUNCT3         = 3'b001,
                     CSRRS_FUNCT3         = 3'b010,
                     CSRRC_FUNCT3         = 3'b011,
                     CSRRWI_FUNCT3        = 3'b101,
                     CSRRSI_FUNCT3        = 3'b110,
                     CSRRCI_FUNCT3        = 3'b111,
                     PRIVJUMP_FUNCT3      = 3'b000;

   localparam [2:0] ZEXT_H_FUNCT3         = 3'b100;
   localparam [4:0] ZEXT_H_FUNCT5         = 5'b00000;

   localparam [11:0] MRET_FUNCT12         = 12'b0011000_00010,
                     WFI_FUNCT12          = 12'b0001000_00101,
                     ECALL_FUNCT12        = 12'b0000000_00000,
                     EBREAK_FUNCT12       = 12'b0000000_00001;


   reg [31:0] control_signals;
   localparam [31:0] ILLEGAL = 32'bX_XX_0_XX_X_001_XXXX_0_XXX_XXXXX_X_X_0_XX_X_X_0_0;         

   // is_mret_o,
   // chip_select_o[1:0],
   // CSR_en_o,
   // CSR_op_o[1:0],
   // CSR_source_sel_o,
   // exception_o[2:0],
   // ALU_op_o[3:0],
   // MDU_en_o,
   // MDU_op_o[2:0],
   // BMU_op_o[4:0],
   // rs1_shift_sel_o,
   // rs2_negate_sel_o
   // reg_wr_en_o,
   // wb_sel_o[1:0],
   // op1_sel_o,
   // op2_sel_o,
   // is_load_instr_o,
   // is_store_instr_o,
   
   always @(*) begin 
      control_signals = ILLEGAL;

      case (opcode)
         LOAD_OPCODE : begin
            case (funct3)
               LB_FUNCT3,
               LH_FUNCT3,
               LW_FUNCT3,
               LBU_FUNCT3,
               LHU_FUNCT3: control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_0_0_1_01_0_1_1_0;
            endcase
         end
         STORE_OPCODE : begin
            case (funct3)
               SB_FUNCT3,
               SH_FUNCT3,
               SW_FUNCT3: control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_0_0_0_XX_0_1_0_1;
            endcase
         end 
         BRANCH_OPCODE : begin
            case (funct3)
               BEQ_FUNCT3,
               BNE_FUNCT3,
               BLT_FUNCT3,
               BGE_FUNCT3,
               BLTU_FUNCT3,
               BGEU_FUNCT3: control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_0_0_0_XX_1_1_0_0;
            endcase
         end

         LUI_OPCODE: control_signals = 32'b0_00_0_XX_X_000_1100_0_XXX_XXXXX_0_0_1_00_X_1_0_0;
         AUIPC_OPCODE : control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_0_0_1_00_1_1_0_0;
         JAL_OPCODE : control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_0_0_1_11_1_1_0_0;

         JALR_OPCODE : begin
            if(funct3 == JALR_FUNCT3) begin
               control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_0_0_1_11_0_1_0_0;
            end
         end

         ITYPE_OPCODE: //I-Type Komutlar, funct3 e gore Ayrilir, Sonra funct7.
            begin
               case (funct3)
                  ADDI_FUNCT3 : control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_0_0_1_00_0_1_0_0;
                  SLTI_FUNCT3 : control_signals = 32'b0_00_0_XX_X_000_0100_0_XXX_XXXXX_0_0_1_00_0_1_0_0;
                  SLTIU_FUNCT3: control_signals = 32'b0_00_0_XX_X_000_0101_0_XXX_XXXXX_0_0_1_00_0_1_0_0;
                  XORI_FUNCT3 : control_signals = 32'b0_00_0_XX_X_000_0110_0_XXX_XXXXX_0_0_1_00_0_1_0_0;
                  ORI_FUNCT3  : control_signals = 32'b0_00_0_XX_X_000_1001_0_XXX_XXXXX_0_0_1_00_0_1_0_0;
                  ANDI_FUNCT3 : control_signals = 32'b0_00_0_XX_X_000_1010_0_XXX_XXXXX_0_0_1_00_0_1_0_0;
                  BMU_SHAMT_A_FUNCT3: begin
                     case (funct7) 
                        SLLI_FUNCT7  : control_signals = 32'b0_00_0_XX_X_00_0011_0_XXX_XXXXX_0_0_1_00_0_1_0_0;
                        BMU_F5_FUNCT7: begin //clz,ctz,cpop,sext.b,sext.h funct5 ile ayirmamiz gerekiyor
                           if(is_b_supported_i) begin
                              case(funct5) 
                                 CLZ_FUNCT5   : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_00000_0_0_1_00_0_1_0_0;
                                 CTZ_FUNCT5   : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_00001_0_0_1_00_0_1_0_0;
                                 CPOP_FUNCT5  : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_00010_0_0_1_00_0_1_0_0;
                                 SEXT_B_FUNCT5: control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_00110_0_0_1_00_0_1_0_0;
                                 SEXT_H_FUNCT5: control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_00111_0_0_1_00_0_1_0_0;
                              endcase    
                           end 
                        end
                        BCLRI_FUNCT7 : begin
                           if(is_b_supported_i) begin
                              control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01011_0_0_1_00_0_1_0_0;
                           end
                        end 
                        BINVI_FUNCT7 : begin
                           if(is_b_supported_i) begin
                              control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01101_0_0_1_00_0_1_0_0;
                           end
                        end 
                        BESTI_FUNCT7 : begin
                           if(is_b_supported_i) begin
                              control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01110_0_0_1_00_0_1_0_0;
                           end
                        end
                     endcase
                  end
                  BMU_SHAMT_B_FUNCT3: begin
                     case (funct7)
                        SRLI_FUNCT7 : control_signals = 32'b0_00_0_XX_X_000_0111_0_XXX_XXXXX_0_0_1_00_0_1_0_0;
                        SRAI_FUNCT7 : control_signals = 32'b0_00_0_XX_X_000_1000_0_XXX_XXXXX_0_0_1_00_0_1_0_0;
                        ORC_B_FUNCT7: begin
                           if(is_b_supported_i && funct5 == ORC_B_FUNCT5) begin
                              control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_00011_0_0_1_00_0_1_0_0;
                           end
                        end 
                        REV8_FUNCT7 : begin
                           if(is_b_supported_i && funct5 == REV8_FUNCT5) begin
                              control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_00100_0_0_1_00_0_1_0_0;
                           end
                        end 
                        RORI_FUNCT7 : begin
                           if(is_b_supported_i) begin
                              control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01001_0_0_1_00_0_1_0_0;
                           end
                        end 
                        BEXTI_FUNCT7: begin
                           if(is_b_supported_i) begin
                              control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01100_0_0_1_00_0_1_0_0;
                           end
                        end
                     endcase
                  end
               endcase    
            end
                                             
         RTYPE_OPCODE:  // R-TYPE komutlar, Ilk once FUNCT7 e gore ayrilir
            begin
               case (funct7) 
                  SIMPLE_FUNCT7: // ADD, SLL, SLT, SLTU, XOR, SRL, OR, AND
                     case(funct3)
                        ADD_FUNCT3    : control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_0_0_1_00_0_0_0_0;
                        SLT_FUNCT3    : control_signals = 32'b0_00_0_XX_X_000_0100_0_XXX_XXXXX_0_0_1_00_0_0_0_0;
                        SLL_FUNCT3    : control_signals = 32'b0_00_0_XX_X_000_0011_0_XXX_XXXXX_0_0_1_00_0_0_0_0; 
                        SLTU_FUNCT3   : control_signals = 32'b0_00_0_XX_X_000_0101_0_XXX_XXXXX_0_0_1_00_0_0_0_0;
                        XOR_FUNCT3    : control_signals = 32'b0_00_0_XX_X_000_0110_0_XXX_XXXXX_0_0_1_00_0_0_0_0;
                        OR_FUNCT3     : control_signals = 32'b0_00_0_XX_X_000_1001_0_XXX_XXXXX_0_0_1_00_0_0_0_0;
                        AND_FUNCT3    : control_signals = 32'b0_00_0_XX_X_000_1010_0_XXX_XXXXX_0_0_1_00_0_0_0_0;
                     endcase
                  MDU_FUNCT7: begin //MUL, MULH, MULHSU, MULHU, DIV,DIVU, REM, REMU
                     if(is_m_supported_i) begin
                        case(funct3) 
                           MUL_FUNCT3    : control_signals = 32'b0_01_0_XX_X_000_XXXX_1_000_XXXXX_0_0_1_00_0_0_0_0;
                           MULH_FUNCT3   : control_signals = 32'b0_01_0_XX_X_000_XXXX_1_001_XXXXX_0_0_1_00_0_0_0_0;
                           MULHSU_FUNCT3 : control_signals = 32'b0_01_0_XX_X_000_XXXX_1_010_XXXXX_0_0_1_00_0_0_0_0;
                           MULHU_FUNCT3  : control_signals = 32'b0_01_0_XX_X_000_XXXX_1_011_XXXXX_0_0_1_00_0_0_0_0;
                           DIV_FUNCT3    : control_signals = 32'b0_01_0_XX_X_000_XXXX_1_100_XXXXX_0_0_1_00_0_0_0_0;
                           DIVU_FUNCT3   : control_signals = 32'b0_01_0_XX_X_000_XXXX_1_101_XXXXX_0_0_1_00_0_0_0_0;
                           REM_FUNCT3    : control_signals = 32'b0_01_0_XX_X_000_XXXX_1_110_XXXXX_0_0_1_00_0_0_0_0;
                           REMU_FUNCT3   : control_signals = 32'b0_01_0_XX_X_000_XXXX_1_111_XXXXX_0_0_1_00_0_0_0_0;
                        endcase
                     end
                  end        
                  SIMPLE_ALT_FUNCT7: // SUB, SRA, ANDN, ORN, XNOR
                     case(funct3)
                        SUB_FUNCT3    : control_signals = 32'b0_00_0_XX_X_000_0001_0_XXX_XXXXX_0_1_1_00_0_0_0_0;
                        SRA_FUNCT3    : control_signals = 32'b0_00_0_XX_X_000_1000_0_XXX_XXXXX_0_0_1_00_0_0_0_0;
                        ANDN_FUNCT3   : begin
                           if(is_b_supported_i) begin
                              control_signals = 32'b0_00_0_XX_X_000_1010_0_XXX_XXXXX_0_1_1_00_0_0_0_0;
                           end
                        end
                        ORN_FUNCT3    : begin
                           if(is_b_supported_i) begin
                              control_signals = 32'b0_00_0_XX_X_000_1001_0_XXX_XXXXX_0_1_1_00_0_0_0_0;
                           end
                        end
                        XNOR_FUNCT3   : begin
                           if(is_b_supported_i) begin
                              control_signals = 32'b0_00_0_XX_X_000_1011_0_XXX_XXXXX_0_0_1_00_0_0_0_0;
                           end
                        end
                     endcase
                  ZEXT_H_FUNCT7: begin
                     if(is_b_supported_i && funct3 == ZEXT_H_FUNCT3 && funct5 == ZEXT_H_FUNCT5) begin
                        control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_00101_0_0_1_00_0_0_0_0;
                     end
                  end    
                  ROTATE_FUNCT7: begin // ROL, ROR
                     if(is_b_supported_i) begin
                        case(funct3)
                           ROL_FUNCT3    : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01000_0_0_1_00_0_0_0_0;
                           ROR_FUNCT3    : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01001_0_0_1_00_0_0_0_0;
                        endcase 
                     end
                  end
                  BEXT_BCLR_FUNCT7: begin
                     if(is_b_supported_i) begin
                        case(funct3)
                           BCLR_FUNCT3   : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01011_0_0_1_00_0_0_0_0;
                           BEXT_FUNCT3   : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01100_0_0_1_00_0_0_0_0;
                        endcase
                     end
                  end
                  BINV_FUNCT7: begin
                     if(is_b_supported_i && funct3 == BINV_FUNCT3) begin
                        control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01101_0_0_1_00_0_0_0_0;
                     end
                  end 
                  BSET_FUNCT7: begin
                     if(is_b_supported_i && funct3 == BSET_FUNCT3) begin
                        control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01110_0_0_1_00_0_0_0_0;
                     end
                  end 
                  MINMAX_FUNCT7: begin //MAX,MAXU,MIN,MINU
                     if(is_b_supported_i) begin
                        case(funct3)
                           MAX_FUNCT3    : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01010_0_0_1_00_0_0_0_0;
                           MAXU_FUNCT3   : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_01111_0_0_1_00_0_0_0_0;
                           MIN_FUNCT3    : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_10000_0_0_1_00_0_0_0_0;
                           MINU_FUNCT3   : control_signals = 32'b0_10_0_XX_X_000_XXXX_0_XXX_10001_0_0_1_00_0_0_0_0;
                        endcase
                     end
                  end
                  SHADD_FUNCT7: begin //SH1ADD,SH2ADD,SH3ADD
                     if(is_b_supported_i) begin
                        case(funct3)
                           SH1ADD_FUNCT3 : control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_1_0_1_00_0_0_0_0; 
                           SH2ADD_FUNCT3 : control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_1_0_1_00_0_0_0_0;
                           SH3ADD_FUNCT3 : control_signals = 32'b0_00_0_XX_X_000_0000_0_XXX_XXXXX_1_0_1_00_0_0_0_0;
                        endcase   
                     end
                  end               
               endcase 
            end
      SYSTEM_OPCODE: case(funct3)
            CSRRW_FUNCT3 :  control_signals = 32'b0_11_1_01_0_000_XXXX_0_XXX_XXXXX_X_X_1_00_X_X_0_0;
            CSRRS_FUNCT3 :  control_signals = 32'b0_11_1_10_0_000_XXXX_0_XXX_XXXXX_X_X_1_00_X_X_0_0;
            CSRRC_FUNCT3 :  control_signals = 32'b0_11_1_11_0_000_XXXX_0_XXX_XXXXX_X_X_1_00_X_X_0_0;
            CSRRWI_FUNCT3 : control_signals = 32'b0_11_1_01_1_000_XXXX_0_XXX_XXXXX_X_X_1_00_X_X_0_0;
            CSRRSI_FUNCT3 : control_signals = 32'b0_11_1_10_1_000_XXXX_0_XXX_XXXXX_X_X_1_00_X_X_0_0;
            CSRRCI_FUNCT3 : control_signals = 32'b0_11_1_11_1_000_XXXX_0_XXX_XXXXX_X_X_1_00_X_X_0_0;
            PRIVJUMP_FUNCT3 :  begin
                  if(rd_label == 0 && rs1_label == 0) begin
                     case (funct12)
                        ECALL_FUNCT12 :     control_signals = 32'bX_XX_0_XX_X_010_XXXX_0_XXX_XXXXX_X_X_0_XX_X_X_0_0;
                        EBREAK_FUNCT12 :    control_signals = 32'bX_XX_0_XX_X_011_XXXX_0_XXX_XXXXX_X_X_0_XX_X_X_0_0;
                        MRET_FUNCT12 :      control_signals = 32'b1_XX_0_XX_X_000_XXXX_0_XXX_XXXXX_X_X_0_XX_X_X_0_0;
                        WFI_FUNCT12 :       control_signals = 32'b0_XX_0_XX_X_000_XXXX_0_XXX_XXXXX_X_X_0_XX_X_X_0_0; //WFI=NOP
                     endcase
                  end
            end
         endcase
      endcase
   end

   assign {
      is_mret_o,
      chip_select_o,
      CSR_en_o,
      CSR_op_o,
      CSR_source_sel_o,
      exception_o,
      ALU_op_o,
      MDU_en_o,
      MDU_op_o,
      BMU_op_o,
      rs1_shift_sel_o,
      rs2_negate_sel_o,
      reg_wr_en_o,
      wb_sel_o,
      op1_sel_o,
      op2_sel_o,
      is_load_instr_o,
      is_store_instr_o
   } = control_signals;

endmodule


