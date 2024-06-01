module d_reg_en(  
 input      clk_i,
 input      rst_i,
 input      en_i,
 input      [63:0] data_i,
 output reg [63:0] data_o
);

   always @ (posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
     data_o <= 0;
    end else if(en_i) begin
     data_o <= data_i;
    end else
        data_o <= data_o;
   end
 
endmodule