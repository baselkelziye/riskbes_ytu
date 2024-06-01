module d_reg #(
 parameter WIDTH=32
) (  
 input      clk_i,
 input      rst_i,
 input      [WIDTH-1:0] data_i,
 output reg [WIDTH-1:0] data_o
);

   always @ (posedge clk_i, posedge rst_i) begin
    if (rst_i) begin
     data_o <= 0;
    end else begin
     data_o <= data_i;
    end
   end
 
endmodule