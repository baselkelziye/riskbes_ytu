module csr_unit (
    input clk_i,
    input rst_i,

    input en_i,
    input [1:0] op_i, //00 = ECALL/EBREAK, 01 = RW, 10 = RS, 11 = RC
    input source_sel_i, //0 = rs1, 1 = uimm

    input [4:0] rs1_label_i,
    input [31:0] rs1_value_i,

    input [11:0] addr_i,

    output [31:0] value_o
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
            default: ; //TO-DO: ECALL ~ EBREAK
        endcase
    end

    wire [31:0] mscratch_val;
    wire mscratch_ack;

    csr_mscratch u_mscratch(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .en_i(en_i),

        .addr_i(addr_i),
        .set_i(setfield),
        .clear_i(clearfield),

        .value_o(mscratch_val),
        .ack_o(mscratch_ack)
    );

    assign value_o = mscratch_val;

    `ifdef DEBUG

       integer ack_count;
   
       always @(negedge clk_i) begin // DEBUG
           ack_count = 0;
   
           ack_count = ack_count + mscratch_ack;
   
           if((en_i == 0 && ack_count != 0) || (en_i == 1 && ack_count != 1)) begin
               $display("WARNING: Bad en_i and ack_count values: %d, %d",en_i , ack_count);
           end
       end
    
    `endif
    
endmodule