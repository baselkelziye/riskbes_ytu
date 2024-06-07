module divider_pipelined(
 input         clk_i,
 input         rst_i,
 input  [31:0] dividend_i,
 input  [31:0] divisor_i,
 input         en_i,
 output [31:0] quo_o,
 output [31:0] rem_o,
 output        ack_o
);

   localparam STAGE_LIST = 32'h0101_0101;
   reg        ready    [32:0];
   reg [31:0] dividend [32:0];  
   reg [31:0] divisor  [32:0];
   reg [31:0] quotient [32:0];     

   always@* begin
    ready[0]    = en_i;    
    dividend[0] = dividend_i;
    divisor[0]  = divisor_i;
    quotient[0] = 0;
   end
   
   generate
   	genvar i;
   	for (i=0;i<32;i=i+1) begin:gen_div
     wire [i:0]    m = dividend[i]>>(32-i-1);
     wire [i:0]    n = divisor[i]; 
     wire          q = (|(divisor[i]>>(i+1))) ? 1'b0 : ( m>=n );
     wire [i:0]    t = q ? (m - n) : m;
	 wire [32-1:0] u = dividend[i]<<(i+1);
     wire [32+i:0] d = {t,u}>>(i+1);
     if (STAGE_LIST[32-i-1]) begin:gen_ff
      always @ ( posedge clk_i or posedge  rst_i ) begin
       if (rst_i) begin
        ready[i+1] <= 0;
        dividend[i+1] <= 0;
        divisor[i+1] <= 0;
        quotient[i+1] <= 0;
       end
       else begin
        ready[i+1] <= ready[i];
        dividend[i+1] <= d;
        divisor[i+1] <= divisor[i];
        quotient[i+1] <= quotient[i]|(q<<(32-i-1));
       end
      end
     end
     else begin:gen_comb
      always @* begin
       ready[i+1]    = ready[i];
       dividend[i+1] = d;
       divisor[i+1]  = divisor[i];
       quotient[i+1] = quotient[i]|(q<<(32-i-1));                	
      end
     end
    end
   endgenerate
   assign quo_o = quotient[32];
   assign rem_o = dividend[32];
   assign ack_o = ready[32];
endmodule