module amo_instr_generator(
   input opcode_sel_i,
   input [4:0] rd_i,
   input [4:0] rs1_i,
   input [4:0] rs2_i,
   input rs1_sel_i,
   input rs2_sel_i,
   input [2:0] funct3a_i,
   output [31:2] instr_o
);

   localparam [6:2] R_TYPE = 5'b01100;
   localparam [6:2] P_AMOEND = 5'b00111;

   wire [6:2] opcode;

   mux_2x1 #(
      .DATA_WIDTH(5)
   ) u_opcode_sel (
      .in0(R_TYPE),
      .in1(P_AMOEND),
      .select(opcode_sel_i),
      .out(opcode)
   );

   wire [4:0] rs1;

   mux_2x1 #(
      .DATA_WIDTH(5)
   ) u_rs1_sel (
      .in0(rd_i),
      .in1(rs1_i),
      .select(rs1_sel_i),
      .out(rs1)
   );

   wire [4:0] rs2;

   mux_2x1 #(
      .DATA_WIDTH(5)
   ) u_rs2_sel (
      .in0(rd_i),
      .in1(rs2_i),
      .select(rs2_sel_i),
      .out(rs2)
   );

   localparam [2:0]  AMOADD_FUNCT3A    = 3'b000,
                     AMOXOR_FUNCT3A    = 3'b001,
                     AMOAND_FUNCT3A    = 3'b011,
                     AMOOR_FUNCT3A     = 3'b010,
                     AMOMIN_FUNCT3A    = 3'b100,
                     AMOMAX_FUNCT3A    = 3'b101,
                     AMOMINU_FUNCT3A   = 3'b110,
                     AMOMAXU_FUNCT3A   = 3'b111;

   localparam [2:0]  ADD_FUNCT3  = 3'b000,
                     XOR_FUNCT3  = 3'b100,
                     AND_FUNCT3  = 3'b111,
                     OR_FUNCT3   = 3'b110,
                     MIN_FUNCT3  = 3'b100,
                     MAX_FUNCT3  = 3'b111,
                     MINU_FUNCT3 = 3'b101,
                     MAXU_FUNCT3 = 3'b110;

   localparam [6:0]  ALU_FUNCT7    = 7'b0000000,
                     MINMAX_FUNCT7 = 7'b0000101;
   
   reg [2:0] funct3;

   always @(*) begin
      case(funct3a_i)
         AMOADD_FUNCT3A:  funct3 = ADD_FUNCT3;
         AMOXOR_FUNCT3A:  funct3 = XOR_FUNCT3;
         AMOAND_FUNCT3A:  funct3 = AND_FUNCT3;
         AMOOR_FUNCT3A:   funct3 = OR_FUNCT3;
         AMOMIN_FUNCT3A:  funct3 = MIN_FUNCT3;
         AMOMAX_FUNCT3A:  funct3 = MAX_FUNCT3;
         AMOMINU_FUNCT3A: funct3 = MINU_FUNCT3;
         AMOMAXU_FUNCT3A: funct3 = MAXU_FUNCT3;
      endcase
   end

   wire funct7_sel = funct3a_i[2];
   wire [6:0] funct7;

   mux_2x1 #(
      .DATA_WIDTH(7)
   ) u_funct7_sel (
      .in0(ALU_FUNCT7),
      .in1(MINMAX_FUNCT7),
      .select(funct7_sel),
      .out(funct7)
   );

   assign instr_o = {
      funct7,
      rs2,
      rs1,
      funct3,
      rd_i,
      opcode
   };

endmodule