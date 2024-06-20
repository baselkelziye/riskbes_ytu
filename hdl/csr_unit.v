module csr_unit (
    input clk_i,
    input rst_i,

    input en_i,
    input [1:0] op_i, // 01 = RW, 10 = RS, 11 = RC
    input source_sel_i, //0 = rs1, 1 = uimm

    input [4:0] rs1_label_i,
    input [31:0] rs1_value_i,

    input [11:0] addr_i,

    output [31:0] read_o
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

    wire [31:0] mscratch_read;
    wire mscratch_ack;

    csr_mscratch u_mscratch(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_i),

        .addr_i(addr_i),
        .set_i(setfield),
        .clear_i(clearfield),

        .read_o(mscratch_read),
        .ack_o(mscratch_ack)
    );
    
    wire [31:0] mstatus_read;
    wire mstatus_ack;
    
    //TODO: FS, XS and SD fields
    csr_mstatus u_mstatus(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_i),

        .addr_i(addr_i),
        .set_i(setfield),
        .clear_i(clearfield),

        .read_o(mstatus_read),
        .ack_o(mstatus_ack)
    );
    
    wire mstatush_ack;
    
    csr_zero #(
      .ADDRESS(12'h310)
    ) u_mstatush (
      .en_i(en_i),
      .addr_i(addr_i),
      .ack_o(mstatush_ack)
    );
    
    wire [31:0] mepc_read;
    wire mepc_ack;
    
    csr_mepc u_mepc(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_i),

        .addr_i(addr_i),
        .set_i(setfield),
        .clear_i(clearfield),

        .read_o(mepc_read),
        .ack_o(mepc_ack)
    );
    
    wire [31:0] mtvec_read;
    wire mtvec_ack;
    
    csr_mtvec u_mtvec(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_i),

        .addr_i(addr_i),
        .set_i(setfield),
        .clear_i(clearfield),

        .read_o(mtvec_read),
        .ack_o(mtvec_ack)
    );
    

    assign read_o = mscratch_read | mstatus_read | mepc_read | mtvec_read;

    `ifdef DEBUG

       integer ack_count;
   
       always @(negedge clk_i) begin // DEBUG
           ack_count = 
            mscratch_ack 
            + mstatus_ack 
            + mstatush_ack
            + mepc_ack
            + mtvec_ack;
   
           if((en_i == 0 && ack_count != 0) || (en_i == 1 && ack_count != 1)) begin
               $display("WARNING: Bad en_i and ack_count values: %d, %d",en_i , ack_count);
           end
       end
    
    `endif
    
endmodule