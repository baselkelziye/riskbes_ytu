`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2024 05:30:59 PM
// Design Name: 
// Module Name: memory_stage
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module memory_stage(
   input clk_i,
   input rst_i,
   input busywait_i,
    
   input [31:0] data_cache_data_i,
   input [3:0] op_type_i,
   input reg_wb_en_i,
   input [4:0] rd_label_i,
   input [31:0] alu_out_i,
   input [1:0] wb_sel_i,
   input [31:0] imm_i,
   input [31:0] pc_i,
   input is_memory_instruction_i,
   input [31:0] rs2_data_i,
   input is_long_i,
    
   output [31:0] data_cache_data_o,
   output [3:0] data_cache_write_en_o,
   output [31:2] data_cache_address_o,
   output reg [31:0] load_val_o,
   
   output reg reg_wb_en_o,
   output reg [4:0] rd_label_o,
   output reg [31:0] alu_out_o,
   output reg [1:0] wb_sel_o,
   output reg [31:0] imm_o,
   output reg [31:0] pc_o,
   output reg is_memory_instruction_o,
   output reg [31:0] rs2_data_o,
   output reg is_long_o,
   
   output data_cache_enabled_o
);

   assign data_cache_enabled_o = is_memory_instruction_i;
   assign data_cache_address_o = alu_out_i[31:2];
   
   wire [31:0] load_val_next;

   cache_access_unit cau(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .addr_align_i(alu_out_i[1:0]),
      .core_raw_data_i(rs2_data_i),
      .cache_raw_data_i(data_cache_data_i),
      .op_type_i(op_type_i),
      .write_en_o(data_cache_write_en_o),
      .core_normalized_data_o(data_cache_data_o),
      .cache_normalized_data_o(load_val_next)
   );
   
   always @(posedge clk_i) begin
      if(rst_i) begin
         is_long_o <= 1'b0;
         reg_wb_en_o <= 1'b0;
         rd_label_o <= 5'b0;
         alu_out_o <= 32'b0;
         wb_sel_o <= 2'b0;
         imm_o <= 32'b0;
         pc_o <= 32'b0;
         is_memory_instruction_o <= 1'b0;
         rs2_data_o <= 32'b0;
         load_val_o <= 32'b0;
      end else begin
         if(!busywait_i) begin
            is_long_o <= is_long_i;
            reg_wb_en_o <= reg_wb_en_i;
            rd_label_o <= rd_label_i;
            alu_out_o <= alu_out_i;
            wb_sel_o <= wb_sel_i;
            imm_o <= imm_i;
            pc_o <= pc_i;
            is_memory_instruction_o <= is_memory_instruction_i;
            rs2_data_o <= rs2_data_i;
            load_val_o <= load_val_next;
         end
      end
   end

endmodule
