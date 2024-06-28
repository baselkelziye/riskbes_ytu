module fp_regfile(
    input             clk_i         ,
    input             rst_i         ,
    input             write_en_i    ,
    input      [4:0 ] fp_rd_label_i ,
    input      [31:0] fp_rd_data_i  ,
    input      [4:0 ] fp_rs1_label_i, 
    input      [4:0 ] fp_rs2_label_i,
    input      [4:0 ] fp_rs3_label_i,
    output reg [31:0] fp_rs1_data_o ,
    output reg [31:0] fp_rs2_data_o ,
    output reg [31:0] fp_rs3_data_o
);


   localparam REG_COUNT = 32;
   genvar I;

   reg  [31:0] fp_registers_rw [0 : REG_COUNT - 1]; // Array of 32 read-write GPRs
   wire [31:0] fp_registers_r  [0 : REG_COUNT - 1]; // Array of 32 readable GPRs

   generate
      for(I = 1; I < REG_COUNT; I = I + 1) begin
         assign fp_registers_r[I] = fp_registers_rw[I];
         
         //Positive edge yazma
         always @(posedge clk_i) begin
            if (rst_i) begin //Bu gerekli mi?
               fp_registers_rw[I] <= 0;
            end else if (rd_i == I) begin
               fp_registers_rw[I] <= rd_data_i;
            end
         end
      end
   endgenerate

   always @(negedge clk_i) begin
      //Not: Değerler yeni atanıyorsa güncel olan değer rd_data_i'de fp_registers_r'da değil.
      rs1_data_o <= rs1_i != 5'b0 && rs1_i == rd_i ? rd_data_i : fp_registers_r[rs1_i];
      rs2_data_o <= rs2_i != 5'b0 && rs2_i == rd_i ? rd_data_i : fp_registers_r[rs2_i];
      rs3_data_o <= rs3_i != 5'b0 && rs3_i == rd_i ? rd_data_i : fp_registers_r[rs3_i];
   end

endmodule