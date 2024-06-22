module csrfield #(
    parameter WIDTH = 1,
    parameter RESET_VALUE = 0
) (
    input clk_i,
    input rst_i,
    input en_i,

    input [WIDTH - 1 : 0] set_i,
    input [WIDTH - 1 : 0] clear_i,

    output [WIDTH - 1 : 0] value_o,
    output [WIDTH - 1 : 0] value_next_o
);

   reg [WIDTH - 1 : 0] value;
   reg [WIDTH - 1 : 0] value_next;

   always @(*) begin
      if (en_i) begin
         value_next = (value & ~clear_i) | set_i;
      end else begin
         value_next = value;
      end
   end

   always @(posedge clk_i) begin
      if (rst_i) begin
         value <= RESET_VALUE;
      end else if (en_i) begin
         value <= value_next;
      end
   end

   assign value_o = value;
   assign value_next_o = value_next;
   
endmodule