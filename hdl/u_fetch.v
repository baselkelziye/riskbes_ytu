`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/06/2024 06:27:02 PM
// Design Name: 
// Module Name: u_fetch
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


module u_fetch(
        input clk_i,
        input rst_i,
        
        input data_busywait_i,
        input stall,
        
        input [31:0] cache_data_i,
        
        input branching,
        input branch_aligned_n_i, //0: Dallanılan adres hizalı (PC[1] = 0), 1: Dallanılan adres hizasız (PC[1] = 1)
        
        output fetch_counter_sel_o, //0: fetch_counter'ı değiştirme, 1: fetch_counter'ı arttır
        output fetch_address_sel_o, //0: fetch_address = fetch_counter, 1: fetch_address = fetch_counter + 1
        output pc_aligned_n_sel_o, //0: PC[1] = 0, 1: PC[1] = 1
        
        output reg [31:2] instr_o,
        output reg is_long_o
    );
    
    reg state_upper_half;
    reg state_delayed_read;

    assign fetch_counter_sel_o = state_upper_half ?  ~is_long_b : (state_delayed_read | is_long_a);
    assign fetch_address_sel_o = state_delayed_read;
    assign pc_aligned_n_sel_o = state_upper_half | state_delayed_read;

    localparam [31:2] INSTR_NOP = 30'b000000000000000000000000000100;
    
    wire [31:2] aligned_instr = cache_data_i[31:2];
    wire is_long_a = cache_data_i[0] & cache_data_i[1];
    wire is_long_b = cache_data_i[16] & cache_data_i[17];
    
    reg [15:2] instr_save;
    wire [31:2] unaligned_instr = {cache_data_i[15:0], instr_save};
    
    wire [15:0] decompr_i = state_upper_half ? cache_data_i[31:16] : cache_data_i[15:0];
    wire [31:2] decompr_o;
        
    instr_decompression_unit decompr(
        .instr_o(decompr_o),
        .instr_i(decompr_i)
    );
    
    always @(posedge clk_i) begin
        instr_save <= cache_data_i[31:18];
    
        if(!rst_i) begin
            if(!data_busywait_i && !stall) begin      
                if (branching) begin
                    instr_o <= INSTR_NOP;
                
                    state_upper_half <= branch_aligned_n_i;
                    state_delayed_read <= 1'b0;
                end else begin
                    if (state_upper_half) begin
                        is_long_o <= 1'b0;
                        
                        state_upper_half <= 1'b0;
    
                        if (is_long_b) begin //Sadece dallanmadan sonra
                            instr_o <= INSTR_NOP;
                            state_delayed_read <= 1'b1;
                        end else begin //Normalde beklenen durum
                            instr_o <= decompr_o;
                            state_delayed_read <= 1'b0;
                        end
                    end else begin
                        if (state_delayed_read) begin
                            instr_o <= unaligned_instr;
                            is_long_o <= 1'b1; 
                            if (!is_long_b) begin
                                state_upper_half <= 1'b1;
                                state_delayed_read <= 1'b0;
                            end
                        end else begin
                            is_long_o <= is_long_a;
                            instr_o <= is_long_a ? aligned_instr : decompr_o;
                            
                            if (!is_long_a) begin
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
            state_upper_half <= 1'b0;
            state_delayed_read <= 1'b0;
            instr_o <= INSTR_NOP;
        end
    end
        
endmodule
