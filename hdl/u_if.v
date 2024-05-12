`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/28/2024 02:12:58 PM
// Design Name: 
// Module Name: u_if
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


module u_if(
    input clk_i,
    input rst_i,
    
    input [31:0] cache_data_i,

    input stall,
    
    input branching,
    input [31:1] branch_pc,
    
    output [31:2] cache_address_o,
    
    output [31:2] instr_o,
    output is_long_o,
    output reg [31:1] pc_o,
    
    output ins_busywait_o,
    
    input cache_blocking_n_i
    );

reg branched;

assign ins_busywait_o = branched ^ branching;

parameter FETCH_WIDTH = 30;

reg [FETCH_WIDTH + 1:2] fetch_counter;
wire [FETCH_WIDTH + 1:2] fetch_counter_next;
wire fetch_counter_carry;

wire fetch_counter_sel, fetch_address_sel, pc_aligned_n_sel;
wire [FETCH_WIDTH + 1:2] fetch_address = fetch_address_sel ? fetch_counter_next : fetch_counter;

wire [31:1] pc_aligned = {fetch_counter, 1'b0};
wire [31:1] pc_unaligned = {fetch_counter, 1'b1};

wire [31:2] branch_fetch_counter = branch_pc[31:2];
wire branch_aligned_n = branch_pc[1];

wire [31:0] cache_data;

increment #(.DATA_WIDTH(FETCH_WIDTH)) fetch_counter_inc
(
    .value_i(fetch_counter),
    .value_o(fetch_counter_next),
    .carry_o(fetch_counter_carry)
);

//instr_cache cache(
//    .address_i(fetch_address),
//    .read_data_o(cache_data)
// );

assign cache_address_o = fetch_address;
assign cache_data = cache_data_i;

u_fetch fetch(
    .clk_i(clk_i),
    .rst_i(rst_i),
    
    .cache_blocking_n_i(cache_blocking_n_i),
    
    .stall(stall),
    
    .cache_data_i(cache_data),
    
    .branching(branching),
    .branch_aligned_n_i(branch_aligned_n),
    
    .fetch_counter_sel_o(fetch_counter_sel),
    .fetch_address_sel_o(fetch_address_sel),
    .pc_aligned_n_sel_o(pc_aligned_n_sel),
    
    .instr_o(instr_o),
    .is_long_o(is_long_o)
);

always @(posedge clk_i) begin
    if(!rst_i) begin
        if(!stall && cache_blocking_n_i) begin 
            branched <= branching;
        
            if(branching) begin
                fetch_counter <= branch_fetch_counter;
            end else if(fetch_counter_sel) begin
                fetch_counter <= fetch_counter_next;
            end
              
            pc_o <= pc_aligned_n_sel ? pc_unaligned : pc_aligned;
        end
    end else begin
        fetch_counter <= 32'b0;
    end
end
    
endmodule
