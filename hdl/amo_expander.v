module amo_expander (
   input clk_i,
   input rst_i,
   input branching_i,
   input stall_i,

   input [4:0] instr_rd_i,
   input [4:0] instr_rs1_i,
   input [4:0] instr_rs2_i,
   input [1:0] instr_funct2a_i,
   input [2:0] instr_funct3a_i,
   input instr_is_opcode_amo_i,
   output [31:2] instr_replaced_o,
   output instr_sel_o
);

   localparam [1:0]  AMOOP_STATE    = 2'b00,
                     AMOSWAP_STATE  = 2'b01,
                     AMOEND_STATE   = 2'b10,
                     NO_AMO_STATE    = 2'b11;

   reg [1:0] state;

   assign instr_sel_o = state != NO_AMO_STATE;

   reg [4:0] rd, rs1, rs2;
   reg [2:0] funct3a;

   wire [1:0] funct2a_to_state = {instr_funct2a_i[1], |instr_funct2a_i}; //Convert funct2a to state
   
   //Buyruk üretici için girdiler. Bu kodları belki daha okunaklı şekilde yazılabilir.
   wire opcode_sel = |state;
   wire rs1_sel = |state;
   wire rs2_sel = ~state[1];

   wire [31:2] instr;

   amo_instr_generator u_instr_gen(
      .rd_i(rd),
      .rs1_i(rs1),
      .rs2_i(rs2),
      .funct3a_i(funct3a),

      .opcode_sel_i(opcode_sel),
      .rs1_sel_i(rs1_sel),
      .rs2_sel_i(rs2_sel),

      .instr_o(instr_replaced_o)
   );

   always @(posedge clk_i) begin
      if(rst_i) begin
         rd <= 0;
         rs1 <= 0;
         rs2 <= 0;
         state <= NO_AMO_STATE;
      end else if (branching_i) begin
         state <= NO_AMO_STATE;
      end else if (!stall_i) begin
         case (state)
            NO_AMO_STATE: begin
               if(instr_is_opcode_amo_i) begin
                  state <= funct2a_to_state;
               end
               rd <= instr_rd_i;
               rs1 <= instr_rs1_i;
               rs2 <= instr_rs2_i;
               funct3a <= instr_funct3a_i;
            end 
            AMOOP_STATE:   state <= AMOEND_STATE;
            AMOSWAP_STATE: state <= NO_AMO_STATE;
            AMOEND_STATE:  state <= NO_AMO_STATE;
         endcase      
      end
   end

endmodule