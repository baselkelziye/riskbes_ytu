`timescale 1ns / 1ps

module mux_2x1
#(
    parameter DATA_WIDTH = 8    // Width of each input
)
(
    input wire [DATA_WIDTH-1:0] in0,  // Input 0
    input wire [DATA_WIDTH-1:0] in1,  // Input 1
    input wire select,                // Selection line
    output reg [DATA_WIDTH-1:0] out   // Output
);

always @* begin
    case (select)
        1'b0: out = in0;  // Select input 0
        1'b1: out = in1;  // Select input 1
        default: out = {DATA_WIDTH{1'b0}}; // Default output to all zeros
    endcase
end

endmodule
