module csr_unit (
   input clk_i,
   input rst_i,

   input en_i,
   input [1:0] op_i, // 01 = RW, 10 = RS, 11 = RC
   input source_sel_i, //0 = rs1, 1 = uimm

   input has_exception_i,
   input [3:0] exception_i,
   input [31:2] pc_i,

   input [4:0] rs1_label_i,
   input [31:0] rs1_value_i,

   input [11:0] addr_i,

   output [31:0] read_o,

   output [31:0] mtvec_o,
   output [31:0] mepc_o,

   //Uzantı destek bitleri (Forwarded)
   output is_a_supported_o,
   output is_b_supported_o,
   output is_f_supported_o,
   output is_m_supported_o
);

   localparam OP_RW = 2'b01;
   localparam OP_RS = 2'b10;
   localparam OP_RC = 2'b11;

   wire [31:0] source = source_sel_i ? {{27{1'b0}}, rs1_label_i} : rs1_value_i;
   
   reg [31:0] setfield, clearfield;

   always @(*) begin
      case (op_i)
         OP_RW: begin
            setfield = source;
            clearfield = ~source;
         end
         OP_RS: begin
            setfield = source;
            clearfield = 0;
         end
         OP_RC: begin
            setfield = 0;
            clearfield = source;
         end
         default: begin
            setfield= 32'bx;
            clearfield = 32'bx;
         end
      endcase
   end

   wire [31:0] mscratch_value;
   wire mscratch_ack;

   wire [31:0] mscratch_read = mscratch_ack ? mscratch_value : 0;
   csr_mscratch u_mscratch(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .en_i(en_i),

      .addr_i(addr_i),
      .set_i(setfield),
      .clear_i(clearfield),

      .ack_o(mscratch_ack),

      .value_o(mscratch_value)
   );
   
   wire [31:0] mstatus_value;
   wire mstatus_ack;

   wire [31:0] mstatus_read = mstatus_ack ? mstatus_value : 0;   
   //TODO: FS, XS and SD fields
   csr_mstatus u_mstatus(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .en_i(en_i),

      .addr_i(addr_i),
      .set_i(setfield),
      .clear_i(clearfield),

      .ack_o(mstatus_ack),

      .value_o(mstatus_value)
   );
   
   wire mstatush_ack;
   
   csr_zero #(
      .ADDRESS(12'h310)
   ) u_mstatush (
      .en_i(en_i),
      .addr_i(addr_i),
      .ack_o(mstatush_ack)
   );
   
   wire [31:0] mepc_value;
   wire mepc_ack;

   wire [31:0] mepc_read = mepc_ack ? mepc_value : 0;

   csr_mepc u_mepc(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .en_i(en_i),

      .pc_i(pc_i),
      .has_exception_i(has_exception_i),

      .addr_i(addr_i),
      .set_i(setfield),
      .clear_i(clearfield),

      .ack_o(mepc_ack),

      .value_o(mepc_value)
   );
   
   wire [31:0] mtvec_value;
   wire mtvec_ack;

   wire [31:0] mtvec_read = mtvec_ack ? mtvec_value : 0;
   csr_mtvec u_mtvec(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .en_i(en_i),

      .addr_i(addr_i),
      .set_i(setfield),
      .clear_i(clearfield),

      .ack_o(mtvec_ack),

      .value_o(mtvec_value)
   );

   wire [31:0] mcause_value;
   wire mcause_ack;

   wire [31:0] mcause_read = mcause_ack ? mcause_value : 0;
   csr_mcause u_mcause(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .en_i(en_i),

      .has_exception_i(has_exception_i),
      .exception_i(exception_i),

      .addr_i(addr_i),
      .set_i(setfield),
      .clear_i(clearfield),

      .ack_o(mcause_ack),

      .value_o(mcause_value)
   );

   //Bu uygun mu? Komiteden cevap bekle.
   wire mtval_ack;
   
   csr_zero #(
      .ADDRESS(12'h343)
   ) u_mtval (
      .en_i(en_i),
      .addr_i(addr_i),
      .ack_o(mtval_ack)
   );

   wire [31:0] misa_value;
   wire misa_ack;

   wire [31:0] misa_read = misa_ack ? misa_value : 0;
   csr_misa u_misa(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .en_i(en_i),

      .addr_i(addr_i),
      .set_i(setfield),
      .clear_i(clearfield),

      .ack_o(misa_ack),
      .value_o(misa_value),

      .is_a_supported_o(is_a_supported_o),
      .is_b_supported_o(is_b_supported_o),
      .is_f_supported_o(is_f_supported_o),
      .is_m_supported_o(is_m_supported_o)
   );

   assign read_o = mscratch_read | mstatus_read | mepc_read | mtvec_read | mcause_read | misa_read;
   assign mtvec_o = mtvec_value;
   assign mepc_o = mepc_value;

   `ifdef DEBUG

      integer ack_count;

      always @(negedge clk_i) begin // DEBUG
         ack_count = 
         mscratch_ack 
         + mstatus_ack 
         + mstatush_ack
         + mepc_ack
         + mtvec_ack
         + mtval_ack
         + mcause_ack
         + misa_ack;

         if((en_i == 0 && ack_count != 0) || (en_i == 1 && ack_count != 1)) begin
            $display("WARNING: Bad en_i and ack_count values: %d, %d",en_i , ack_count);
         end
      end
   
   `endif
   
endmodule