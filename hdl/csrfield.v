module csrfield #(
    parameter WIDTH = 1,
    parameter RESET_VALUE = 0
) (
    input clk_i,
    input rst_i,
    input en_i,

    input [WIDTH - 1 : 0] set_i,
    input [WIDTH - 1 : 0] clear_i,

    output [WIDTH - 1 : 0] read_o,
    output [WIDTH - 1 : 0] value_o
);

    reg [WIDTH - 1 : 0] value;

    assign read_o = en_i ? value : 0;
    assign value_o = value;

    always @(posedge clk_i) begin
        if (rst_i) begin
            value <= RESET_VALUE;
        end else if (en_i) begin
            value <= (value & ~clear_i) | set_i;
        end
    end
    
endmodule