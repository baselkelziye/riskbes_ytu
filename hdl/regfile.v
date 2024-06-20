module regfile(
    input clk_i,
    input rst_i,
    input [4:0] rd_i,
    input [31:0] rd_data_i,
    input [4:0] rs1_i,
    input [4:0] rs2_i,
    output reg [31:0] rs1_data_o,
    output reg [31:0] rs2_data_o
);
   localparam REG_COUNT = 32;
   genvar I;

   reg [31:0] registers_rw [1 : REG_COUNT - 1]; // Array of 31 read-write GPRs (x0 is read-only 0)
   wire [31:0] registers_r [0 : REG_COUNT - 1]; // Array of 32 readable GPRs
   
   assign registers_r[0] = 0;
   
   generate
      for(I = 1; I < REG_COUNT; I = I + 1) begin
         assign registers_r[I] = registers_rw[I];
         
         //Positive edge yazma
         always @(posedge clk_i) begin
            if (rst_i) begin //Bu gerekli mi?
               registers_rw[I] <= 0;
            end else if (rd_i == I) begin
               registers_rw[I] <= rd_data_i;
            end
         end
      end
   endgenerate
   
   //Negative edge okuma
   always @(negedge clk_i) begin
      //Not: Değerler yeni atanıyorsa güncel olan değer rd_data_i'de registers_r'da değil.
      rs1_data_o <= rs1_i != 5'b0 && rs1_i == rd_i ? rd_data_i : registers_r[rs1_i];
      rs2_data_o <= rs2_i != 5'b0 &&  rs2_i == rd_i ? rd_data_i : registers_r[rs2_i];
   end

endmodule