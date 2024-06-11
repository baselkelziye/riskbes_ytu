module divider_unsigned
(
      input  clk_i,
      input  rst_i,
      input  start_i,
      input  [31:0] numerator_i,
      input  [31:0] denominator_i,
      output reg [31:0] quotient_o,
      output reg [31:0] remainder_o,
      output reg done_o
);

parameter IDLE = 2'b00, SHIFT_SUB = 2'b01, D = 2'b10;
reg [1:0] state, next_state;

reg [31:0] counter, next_counter;
reg [31:0] Q;
reg [31:0] R;

// next state condition
always @(posedge clk_i or posedge rst_i) begin
      if(rst_i) begin
            state <= IDLE;
            quotient_o <= 32'b0;
            remainder_o <= 32'b0;
      end
      else begin
            state <= next_state;
            counter <= next_counter;
            quotient_o <= Q;
            remainder_o <= R;
      end
end

// next state logic
always @(*) begin
      case (state)
            IDLE: begin
                  if(start_i) next_state = SHIFT_SUB;
                  else next_state = IDLE;
            end

            SHIFT_SUB: begin
                  if(counter == 32'hFFFFFFFF) next_state = D;
                  else next_state = SHIFT_SUB;
            end

            D: begin
                  next_state = IDLE;
            end

            default: next_state = IDLE;
      endcase
end

// state output logic
always @(*) begin
      case (state)
            IDLE: begin
                  Q = 32'b0;
                  R = 32'b0;
                  next_counter = 32'd31;
                  done_o = 1'b0;
            end

            SHIFT_SUB: begin
                  if (denominator_i <= remainder_o) begin
                        Q[31:0] = {quotient_o[30:0], 1'b1};
                        if (counter < 32'd32)
                              R[31:0] = {remainder_o - denominator_i, numerator_i[counter]};
                        else
                              R[31:0] = remainder_o - denominator_i;
                  end else begin
                        Q = {quotient_o[30:0], 1'b0};
                        if (counter < 32'd32)
                              R[31:0] = {remainder_o[30:0], numerator_i[counter]};
                        else
                              R[31:0] = remainder_o[31:0];
                  end

                  next_counter = counter - 32'd1;
                  done_o = 1'b0;
            end

            D: begin
                  done_o = 1'b1;
                  Q = 32'b0;
                  R = 32'b0;
                  next_counter = 32'd31;
            end

            default: begin
                  Q = 32'b0;
                  R = 32'b0;
                  next_counter = 32'd31;
                  done_o = 1'b0;
            end
      endcase
end

endmodule
