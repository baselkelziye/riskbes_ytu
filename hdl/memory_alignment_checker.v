module memory_alignment_checker (
   input [1:0] addr_align_i,
   input is_load_instr_i,
   input is_store_instr_i,
   input [2:0] funct3_i,
   output reg misaligned_o
);

/* localparam LB_FUNCT3  = 3'b000;
   localparam LH_FUNCT3  = 3'b001;
   localparam LW_FUNCT3  = 3'b010;
   localparam LBU_FUNCT3 = 3'b100;
   localparam LHU_FUNCT3 = 3'b101;

   localparam SB_FUNCT3  = 3'b000;
   localparam SH_FUNCT3  = 3'b001;
   localparam SW_FUNCT3  = 3'b010; */

   localparam  BYTE_ALIGN     = 2'b00,
               HALFWORD_ALIGN = 2'b01,
               WORD_ALIGN     = 2'b10;

   wire [1:0] align_type = funct3_i[1:0]; //funct3_i[2] önemsiz
   
   always @(*) begin
      if(is_load_instr_i || is_store_instr_i) begin
         case (align_type)
            BYTE_ALIGN:       misaligned_o = 1'b0;
            HALFWORD_ALIGN:   misaligned_o = addr_align_i[0];
            WORD_ALIGN:       misaligned_o = |addr_align_i;
            default:          misaligned_o = 1'bx;
         endcase
      end else begin
         misaligned_o = 1'b0;
      end
   end

endmodule