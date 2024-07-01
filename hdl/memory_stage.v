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
   input data_cache_blocking_n_i,
    
   input [31:0] data_cache_data_i,
   input is_load_instruction_i,
   input is_store_instruction_i,
   input [2:0] funct3_i,
   input [4:0] rd_label_i,
   input [31:0] alu_out_i,
   input [1:0] wb_sel_i,
   input [31:0] imm_i,
   input [31:0] pc_i,
   input [31:0] rs2_data_i,

   input exception_detected_i,
   
   input [1:0] mem_data_sel_i,
   input sets_reservation_i,
   input uses_reservation_i,
    
   output [31:0] data_cache_data_o,
   output [3:0] data_cache_write_en_o,
   output [31:2] data_cache_address_o,
   output reg [31:0] mem_data_o,

   output reg [4:0] rd_label_o,
   output reg [31:0] alu_out_o,
   output reg [1:0] wb_sel_o,
   output reg [31:0] imm_o,
   output reg [31:0] pc_o,
   output reg is_load_instruction_o,
   output reg [31:0] rs2_data_o,
   
   output data_cache_enabled_o
);
   reg reservation;
   wire reservation_tmp = (reservation | sets_reservation_i) & ~uses_reservation_i;
   wire reservation_next = !exception_detected_i ? reservation_tmp : reservation; //Eğer exception varsa değeri değiştirme

   wire is_memory_instruction = is_load_instruction_i || is_store_instruction_i;
   wire is_successful = !uses_reservation_i || reservation; //Ya rezervasyon'a gerek yok, ya da zaten var

   assign data_cache_address_o = alu_out_i[31:2];
   assign data_cache_enabled_o = !exception_detected_i && is_memory_instruction && is_successful;

   wire [4:0] rd_label = !exception_detected_i ? rd_label_i : 5'b00000; //Eğer exception varsa, yazmayı durdur
 
   wire [31:0] load_val;
   wire [31:0] cond_val = {{31{1'b0}}, ~reservation};

   wire [31:0] mem_data;

   mux_4x1 #(
      .DATA_WIDTH(32)
   ) u_mem_data_sel (
      .in0(mem_data_o),
      .in1(load_val),
      .in2(cond_val),
      .in3(32'hBADC0DE),
      .select(mem_data_sel_i),
      .out(mem_data)
   );
   
   memory_access_unit mau(
      .clk_i(clk_i),
      .rst_i(rst_i),
      .addr_align_i(alu_out_i[1:0]),
      .core_raw_data_i(rs2_data_i),
      .cache_raw_data_i(data_cache_data_i),
      .is_store_instruction_i(is_store_instruction_i),
      .funct3_i(funct3_i),
      .write_en_o(data_cache_write_en_o),
      .core_normalized_data_o(data_cache_data_o),
      .cache_normalized_data_o(load_val)
   );
   
   always @(posedge clk_i) begin
      if(rst_i) begin
         rd_label_o <= 5'b0;
         alu_out_o <= 32'b0;
         wb_sel_o <= 2'b0;
         imm_o <= 32'b0;
         pc_o <= 32'b0;
         rs2_data_o <= 32'b0;
         mem_data_o <= 0;
         is_load_instruction_o <= 0;
         reservation <= 0;
      end else begin
         if(!busywait_i) begin
            rd_label_o <= rd_label;
            alu_out_o <= alu_out_i;
            wb_sel_o <= wb_sel_i;
            imm_o <= imm_i;
            pc_o <= pc_i;
            rs2_data_o <= rs2_data_i;     
            mem_data_o <= mem_data;  
            is_load_instruction_o <= is_load_instruction_i;
            reservation <= reservation_next;
         end
      end
   end

endmodule
