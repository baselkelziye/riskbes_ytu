`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/10/2024 04:45:10 PM
// Design Name: 
// Module Name: instruction_fetch_stage
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


module instruction_fetch_stage(
    input clk_i,
    input rst_i,
    
    input data_busywait_i,
    output ins_busywait_o,
    input stall,
    
    input branching,
    input [31:1] branch_pc,
    
    output reg [31:2] instr_o,
    output reg [31:2] pc_o
);
   reg branched;
   
   assign ins_busywait_o = branched ^ branching;
   
   parameter FETCH_WIDTH = 29;
   
   reg [FETCH_WIDTH - 1:0] fetch_counter;
   wire [FETCH_WIDTH - 1:0] fetch_counter_next;
   wire fetch_counter_carry;
   
   wire [31:2] branch_fetch_counter = branch_pc[31:2];
   wire branch_aligned_n = branch_pc[1];
   
   wire [31:0] cache_data;
   
   increment #(.DATA_WIDTH(FETCH_WIDTH)) fetch_counter_inc
   (
       .value_i(fetch_counter),
       .value_o(fetch_counter_next),
       .carry_o(fetch_counter_carry)
   );
   
   instr_cache cache(
       .address_i(fetch_counter),
       .read_data_o(cache_data)
   );

   always @(posedge clk_i) begin
       if(!rst_i) begin
           if(!data_busywait_i && !stall) begin 
               branched <= branching;
           
               if(branching) begin
                  fetch_counter <= branch_fetch_counter;
               end else begin
                  fetch_counter <= fetch_counter_next;
               end
                 
               pc_o <= fetch_counter;
               instr_o <= cache_data[31:2];
           end
       end else begin
           fetch_counter <= {FETCH_WIDTH{1'b0}};
       end
   end

endmodule
