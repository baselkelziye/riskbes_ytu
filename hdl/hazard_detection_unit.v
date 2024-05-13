module hazard_detection_unit(
    input is_load_instruction,
    input [4:0] rd_label_id_ex_o,
    input [4:0] rs1_label_if_id_o,
    input [4:0] rs2_label_if_id_o,   
    output reg hazard_o
);

always @(*) begin

    if(is_load_instruction)
        begin
            if ((rs1_label_if_id_o == rd_label_id_ex_o) || (rs2_label_if_id_o == rd_label_id_ex_o)) begin
                hazard_o = 1'b1;
            end
            else begin
                hazard_o = 1'b0;
            end
          
        end
    else begin
        hazard_o = 1'b0;
        end

end

endmodule