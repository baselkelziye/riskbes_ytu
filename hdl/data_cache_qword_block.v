`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/03/2024 05:39:11 PM
// Design Name: 
// Module Name: data_cache_qword_block
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


module data_cache_qword_block #(
   parameter ADDR_WIDTH = 5
)(
   input clk_i, rst_i,
   input [ADDR_WIDTH - 1 : 2] addr_r_i,
   output [31:0] data0_o, data1_o, data2_o, data3_o,
   input [ADDR_WIDTH - 1 : 0] addr_w_i,
   input [31:0] data_i,
   input [3:0] write_en_i,
   input [127:0] flush_data_i,
   input [QWORD_PER_BLOCK_COUNT - 1 : 0] flushing_n_i,
   output [QWORD_PER_BLOCK_COUNT - 1 : 0] dirty_o,
   input cleaned_n_i
);
   integer DEBUGINT;

   localparam QWORD_PER_BLOCK_COUNT = 2 ** SUB_ADDR_WIDTH;
   
   reg [QWORD_PER_BLOCK_COUNT - 1 : 0] dirty; //Written after flush?
   assign dirty_o = dirty;

   wire [1:0] sel_w = addr_w_i[1:0];
   
   localparam SUB_ADDR_WIDTH = ADDR_WIDTH - 2;
   
   wire [SUB_ADDR_WIDTH - 1 : 0] sub_addr_r = addr_r_i[ADDR_WIDTH - 1 : 2];
   wire [SUB_ADDR_WIDTH - 1 : 0] sub_addr_w = addr_w_i[ADDR_WIDTH - 1 : 2];
   
   localparam SUB_COUNT = 4;
   
   wire [31:0] sub_data_r [0 : SUB_COUNT - 1];
   
   wire [QWORD_PER_BLOCK_COUNT - 1 : 0] fn = dirty | flushing_n_i;
   
   genvar I;
   
   generate
      for(I = 0; I < SUB_COUNT; I = I + 1) begin
         localparam FLUSH_LSB = I * 32;
         localparam FLUSH_MSB = FLUSH_LSB + 31;
      
         wire [3:0] wen = sel_w == I ? write_en_i : 4'b0;
      
         data_cache_word_block #(
            .ADDR_WIDTH(SUB_ADDR_WIDTH)
         ) sub (
            .clk_i(clk_i),
            .addr_r_i(sub_addr_r),
            .addr_w_i(sub_addr_w),
            .data_i(data_i),
            .write_en_i(wen),
            .data_o(sub_data_r[I]),
            .flush_data_i(flush_data_i[FLUSH_MSB : FLUSH_LSB]),
            .flushing_n_i(fn)
         );
      end
      
      for(I = 0; I < QWORD_PER_BLOCK_COUNT; I = I + 1) begin
         wire updating;
         if(I == 0) begin
            assign updating = ~flushing_n_i[0];
         end else begin
            assign updating = ~flushing_n_i[I] & flushing_n_i[I - 1];
         end
      
         always @(posedge clk_i) begin
            if (rst_i) begin
               dirty[I] <= 1'b0;
            end else begin   
               // Eğer güncelleniyorsa, cleaned_n ata; eğer güncellenmeden yazılıyorsa, 1 ata; diğer durumlarda değiştirme.
               if (updating) begin
                  dirty[I] <= cleaned_n_i;
               end else begin
                  if (addr_w_i == I && write_en_i != 4'b0) begin
                     dirty[I] <= 1'b1;
                  end
               end
            end
         end
      end
   endgenerate

   assign data0_o = sub_data_r[0];
   assign data1_o = sub_data_r[1];
   assign data2_o = sub_data_r[2];
   assign data3_o = sub_data_r[3];

endmodule
