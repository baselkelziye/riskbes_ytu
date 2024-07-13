
module clz(
    input [31:0] rs1,  // 64-bit giriþ
    output reg [5:0] rd      // 6-bit çýkýþ (Baþtaki sýfýr sayýsý)
);

reg [15:0] half16;
reg [7:0] half8;
reg [3:0] half4;
reg [5:0] result;

always @(rs1) begin
    if (rs1 == 32'b0) begin
        result = 32; // Eðer tüm bitler sýfýrsa
    end else begin
        result[5] = 1'b0;
        result[4] = (rs1[31:16] == 16'b0);
        half16 = result[4] ? rs1[15:0] : rs1[31:16];
        
        result[3] = (half16[15:8] == 8'b0);
        half8 = result[3] ? half16[7:0] : half16 [15:8];
        
        result[2] = (half8[7:4] == 4'b0);
        half4 = result[2] ? half8[3:0] : half8[7:4];
        
        result[1] = (half4[3:2] == 2'b0);
        result[0] = result[1] ? ~half4[1] : ~half4[3];
    end
    rd = result;
end

endmodule