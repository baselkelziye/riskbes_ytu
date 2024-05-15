`timescale 1ns / 1ps

module mux_4x1
#(
    parameter DATA_WIDTH = 8    // Width of each input
)
(
    input wire [DATA_WIDTH-1:0] in0,  // Input 0
    input wire [DATA_WIDTH-1:0] in1,  // Input 1
    input wire [DATA_WIDTH-1:0] in2,  // Input 2
    input wire [DATA_WIDTH-1:0] in3,  // Input 3
    input wire [1:0] select,          // Selection line
    output reg [DATA_WIDTH-1:0] out   // Output
);

always @* begin
    case (select)
        2'b00: out = in0;  // Select input 0
        2'b01: out = in1;  // Select input 1
        2'b10: out = in2;  // Select input 2
        2'b11: out = in3;  // Select input 3
        default: out = {DATA_WIDTH{1'b0}}; // Default output to all zeros
    endcase
end

endmodule
