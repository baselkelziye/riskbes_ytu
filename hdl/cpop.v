module cpop (
    input wire [31:0] rs1_value_i,  // 32-bit input
    output reg [5:0] ones_count_o  // 6-bit output, since the maximum number of ones in a 32-bit number is 32
);

    // Internal variable for intermediate calculations
integer i;
always @(*) begin
    ones_count_o = 0;
    for(i = 0; i < 32; i = i+1) begin
        ones_count_o = ones_count_o + rs1_value_i[i];
    end
end


endmodule
