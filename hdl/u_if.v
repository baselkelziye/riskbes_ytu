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
    
    input data_busywait_i,
    output ins_busywait_o,
    input stall,
    
    input branching,
    input [31:1] branch_pc,
    
    output reg [31:2] instr_o,
    output reg is_long_o,
    output reg [31:1] pc_o
    );
    
reg state_upper_half;
reg state_delayed_read;
reg branched;

assign ins_busywait_o = branching ^ branched;

localparam [31:2] INSTR_NOP = 30'b000000000000000000000000000100;

reg [29:0] fetch_counter;
wire [29:0] fetch_counter_next = fetch_counter + 1;
wire [29:0] fetch_address = state_delayed_read ? fetch_counter_next : fetch_counter;

wire [31:0] cache_data;

wire [31:2] aligned_instr = cache_data[31:2];
wire is_long_a = cache_data[0] & cache_data[1];
wire is_long_b = cache_data[16] & cache_data[17];

wire [31:1] pc_aligned = {fetch_counter, 1'b0};
wire [31:1] pc_unaligned = {fetch_counter, 1'b1};

reg [15:2] instr_save;
wire [31:2] unaligned_instr = {cache_data[15:0], instr_save};

instr_cache cache(
    .address_i(fetch_address),
    .read_data_o(cache_data));

wire [15:0] decompr_i = state_upper_half ? cache_data[31:16] : cache_data[15:0];
wire [31:2] decompr_o;

instr_decompression_unit decompr(decompr_o, decompr_i);

always @(posedge clk_i) begin
    instr_save <= cache_data[31:18];

    if(!rst_i) begin
        if(!data_busywait_i && !stall) begin
            branched <= branching;
        
            if (branching) begin
                instr_o <= INSTR_NOP;
                //is_long_o <= 1'b0;
                //pc_o <= pc_unaligned; 
            
                fetch_counter <= branch_pc[31:2];
                state_upper_half <= branch_pc[1];
                state_delayed_read <= 1'b0;
            end else begin
                if (state_upper_half) begin
                    is_long_o <= 1'b0;
                    pc_o <= pc_unaligned;   
                    
                    state_upper_half <= 1'b0;

                    if (is_long_b) begin //Sadece dallanmadan sonra
                        instr_o <= INSTR_NOP;
                        state_delayed_read <= 1'b1;
                    end else begin //Normalde beklenen durum
                        instr_o <= decompr_o;
                        fetch_counter <= fetch_counter_next;
                        state_delayed_read <= 1'b0;
                    end
                end else begin
                    if (state_delayed_read) begin
                        instr_o <= unaligned_instr;
                        is_long_o <= 1'b1;
                        pc_o <= pc_unaligned;      
                        fetch_counter <= fetch_counter_next;
                        
                        if (!is_long_b) begin
                            state_upper_half <= 1'b1;
                            state_delayed_read <= 1'b0;
                        end
                    end else begin
                        is_long_o <= is_long_a;
                        pc_o <= pc_aligned;
                        instr_o <= is_long_a ? aligned_instr : decompr_o;
                        
                        if (is_long_a) begin
                            fetch_counter <= fetch_counter_next;
                        end else begin
                            state_delayed_read <= is_long_b;
                            state_upper_half <= ~is_long_b;
                        end
                    end
                end
            end
        end else begin
            instr_o <= INSTR_NOP;
        end
    end else begin
        fetch_counter <= 30'b0;
        state_upper_half <= 1'b0;
        state_delayed_read <= 1'b0;
        instr_o <= INSTR_NOP;
    end
end
    
endmodule
