`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

//Forwarding unit.
//Result from load instruction is forwarded when ForwardA/B is  = 3 (2'b11)
//Since load instruction's value can be forwarded only from mem/wb stage (load hazard) only that case is checked.
//we add is_memory_instruction_mem_wb_o to check if the instruction is load, if yes we forward the value from LOAD, if its not we pass alu result.
//ex/mem is simple. not addition logic needed.
//////////////////////////////////////////////////////////////////////////////////


module forwarding_unit(
    input [4:0] rd_label_ex_mem_i,
    input [4:0] rd_label_mem_wb_i,
    input [4:0] rs1_label_i,
    input [4:0] rs2_label_i,
    input is_load_instr_mem_wb_i,
    output reg [1:0]  forwardA_o,
    output reg [1:0]  forwardB_o
    );
    
// 00 -> no forwarding
// 01 -> forward MEM/WB (not LOAD)
// 10 -> forward EX/MEM
// 11 -> forward MEM/WB (LOAD)

   localparam [1:0]  NO_FORWARDING              = 2'b00,
                     FORWARD_MEM_WB_NO_LOAD     = 2'b01,
                     FORWARD_EX_MEM             = 2'b10,
                     FORWARD_MEM_WB_WITH_LOAD   = 2'b11;

   always @(*) begin
      if(rs1_label_i == 0) begin
         forwardA_o = NO_FORWARDING;
      end else if (rs1_label_i == rd_label_ex_mem_i) begin
         forwardA_o = FORWARD_EX_MEM;
      end else if (rs1_label_i == rd_label_mem_wb_i) begin
         if (is_load_instr_mem_wb_i) begin
            forwardA_o = FORWARD_MEM_WB_WITH_LOAD;
         end else begin
            forwardA_o = FORWARD_MEM_WB_NO_LOAD;
         end
      end else begin
         forwardA_o = NO_FORWARDING;
      end
   end

   always @(*) begin
      if(rs2_label_i == 0) begin
         forwardB_o = NO_FORWARDING;
      end else if (rs2_label_i == rd_label_ex_mem_i) begin
         forwardB_o = FORWARD_EX_MEM;
      end else if (rs2_label_i == rd_label_mem_wb_i) begin
         if (is_load_instr_mem_wb_i) begin
            forwardB_o = FORWARD_MEM_WB_WITH_LOAD;
         end else begin
            forwardB_o = FORWARD_MEM_WB_NO_LOAD;
         end     
      end else begin
         forwardB_o = NO_FORWARDING;
      end
   end

endmodule