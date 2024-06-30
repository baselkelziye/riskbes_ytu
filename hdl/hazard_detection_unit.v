module hazard_detection_unit(
    input is_load_instruction_ex_i,
    input [4:0] rd_label_ex_i,
    input [4:0] rs1_label_id_i,
    input [4:0] rs2_label_id_i, 
    input branching_i,

    output reg stall_o
);

   always @(*) begin
      stall_o = 1'b0;

      if (!branching_i && is_load_instruction_ex_i) begin
         if (rd_label_ex_i != 5'b00000) begin
            if ((rs1_label_id_i == rd_label_ex_i) || (rs2_label_id_i == rd_label_ex_i)) begin
               stall_o = 1'b1;
            end
         end
      end
   end

endmodule