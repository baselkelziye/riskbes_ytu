//`timescale 1ns / 1ps

////TODO
////FUNCT3 we IS MEM SINYALLERINI ALDIM, READ MEM LERI KALDIRIP FUNCT3 E GORE YAZ/OKU


////READ_write_sel     FUNCT3
////LB = 4'b1000       000
////LH = 4'b1001       001
////LW = 4'b1010       010
////LBU = 4'b1100      100
////LHU = 4'b1101      101


//module data_cache(
//    input clk_i,
//    input rst_i,
//    input [31:0]address_i,
//    input [31:0]write_data_i,
//    input is_load_instr,
//    input is_store_instr,
//    input [2:0] funct3_i,
//    output reg [31:0]read_data_o,
//    output reg busy_o);
    
//    wire is_mem_instr = is_load_instr || is_store_instr;
//    reg[7:0] cache_r[0:65535];
    
//    wire[7:0] data_r[0:3];
    
//    always @ (is_mem_instr) begin
//        if(is_mem_instr)begin
//            busy_o = 1;
//        end else begin
//            busy_o = 0;
//        end
//    end
    
//    assign {data_r[3],data_r[2],data_r[1],data_r[0]} = {{cache_r[{address_i[31:2],2'b11}]},{cache_r[{address_i[31:2],2'b10}]},{cache_r[{address_i[31:2],2'b01}]},{cache_r[{address_i[31:2],2'b00}]}};
    
//    wire [7:0]data_byte_r;
//    wire [15:0]data_half_r;
//    wire [31:0]data_word_r;
    

//    assign data_byte_r = data_r[address_i[1:0]];
//    assign data_half_r = {data_r[{address_i[1],1'b1}],data_r[{address_i[1],1'b0}]};
//    assign data_word_r = {data_r[2'b11],data_r[2'b10],data_r[2'b01],data_r[2'b00]};
    
//    wire [31:0]LB;
//    wire [31:0]LH;
//    wire [31:0]LW;
//    wire [31:0]LBU;
//    wire [31:0]LHU;
    
    
//    assign LB = {{24{data_byte_r[7]}}, data_byte_r};
//    assign LH = {{16{data_half_r[15]}}, data_half_r};
//    assign LW = {data_word_r};
//    assign LBU = {24'b0, data_byte_r};
//    assign LHU = {16'b0, data_half_r};

//    wire [3:0] load_word_case;
//    assign load_word_case = {is_load_instr, funct3_i};
        
//    always @ (*)begin
//        if(is_load_instr) begin
//        case(funct3_i)
//            3'b000: read_data_o = LB;
//            3'b001: read_data_o = LH;
//            3'b010: read_data_o = LW;
//            3'b100: read_data_o = LBU;
//            3'b101: read_data_o = LHU;
//        endcase 
//        busy_o = 1'b0;
//        end
//    end
//// SB = 4b'1011      000
//// SH = 4'b1110      001
//// SW = 4b'1111      010
//    always @ (posedge clk_i) begin
//        if(is_store_instr) begin
//            case(funct3_i)
//                3'b000:
//                    cache_r[address_i[31:0]] = write_data_i[7:0];
//                3'b001: begin
//                    cache_r[{address_i[31:1],1'b0}] = write_data_i[7:0];
//                    cache_r[{address_i[31:1],1'b1}] = write_data_i[15:8];
//                end
//                3'b010: begin
//                    cache_r[{address_i[31:2],{2'b00}}] = write_data_i[7:0];
//                    cache_r[{address_i[31:2],{2'b01}}] = write_data_i[15:8];
//                    cache_r[{address_i[31:2],{2'b10}}] = write_data_i[23:16];
//                    cache_r[{address_i[31:2],{2'b11}}] = write_data_i[31:24];
//                end
//            endcase
//            busy_o = 1'b0;
//        end
//    end
    
//    integer i;
    
//    always @ (rst_i) begin
//        if(rst_i) begin
//            for(i = 0 ; i<65536 ; i = i+1) begin
//                cache_r[i] = 32'b0;            
//            end
//        end
//    end
    
    
//endmodule



`timescale 1ns / 1ps
//bura nasil calisiyor? LH da ariza var.

module data_cache(
    input clk_i,
    input rst_i,
    input [31:0]address_i,
    input [31:0]write_data_i,
    input [3:0]read_write_sel_i,
    output reg [31:0]read_data_o,
    output reg busy_o);
    
    reg[7:0] cache_r[0:65535];
    
    wire[7:0] data_r[0:3];
    
    always @ (read_write_sel_i) begin
        if(read_write_sel_i[3])begin
            busy_o = 1;
        end else begin
            busy_o = 0;
        end
    end
    
    assign  {data_r[3],data_r[2],data_r[1],data_r[0]} = {{cache_r[{address_i[31:2],2'b11}]},{cache_r[{address_i[31:2],2'b10}]},{cache_r[{address_i[31:2],2'b01}]},{cache_r[{address_i[31:2],2'b00}]}};
    
    reg [7:0]data_byte_r;
    reg [15:0]data_half_r;
    reg [31:0]data_word_r;
    
    always @ (*) begin
        
        case(read_write_sel_i)
            4'b1000: data_byte_r = data_r[address_i[1:0]];
            4'b1001: data_half_r = {data_r[{address_i[1],1'b1}],data_r[{address_i[1],1'b0}]};
            4'b1010: data_word_r = {data_r[2'b11],data_r[2'b10],data_r[2'b01],data_r[2'b00]};
        endcase
        
    end
    
    wire [31:0]LB;
    wire [31:0]LH;
    wire [31:0]LW;
    wire [31:0]LBU;
    wire [31:0]LHU;
    
    
    assign LB = {{24{data_byte_r[7]}}, data_byte_r};
    assign LH = {{16{data_half_r[15]}}, data_half_r};
    assign LW = {data_word_r};
    assign LBU = {24'b0, data_byte_r};
    assign LHU = {16'b0, data_half_r};
        
    always @ (*)begin

        case(read_write_sel_i)
            4'b1000: read_data_o = LB;
            4'b1001: read_data_o = LH;
            4'b1010: read_data_o = LW;
            4'b1100: read_data_o = LBU;
            4'b1101: read_data_o = LHU;
        endcase 
        busy_o = 1'b0;
    end
    
    always @ (*) begin
        if(read_write_sel_i[3]) begin
            case(read_write_sel_i)
                4'b1011:
                    cache_r[address_i[31:0]] = write_data_i[7:0];
                4'b1110: begin
                    cache_r[{address_i[31:1],1'b0}] = write_data_i[7:0];
                    cache_r[{address_i[31:1],1'b1}] = write_data_i[15:8];
                end
                4'b1111: begin
                    cache_r[{address_i[31:2],{2'b00}}] = write_data_i[7:0];
                    cache_r[{address_i[31:2],{2'b01}}] = write_data_i[15:8];
                    cache_r[{address_i[31:2],{2'b10}}] = write_data_i[23:16];
                    cache_r[{address_i[31:2],{2'b11}}] = write_data_i[31:24];
                end
            endcase
            busy_o = 1'b0;
        end
    end
    
    
    integer i;
//    initial begin
//    for(i = 0 ; i<65536 ; i = i+1)
//        cache_r[i] = i;
//    end
    
    always @ (rst_i) begin
        if(rst_i) begin
            for(i = 0 ; i<65536 ; i = i+1) begin
                cache_r[i] = 32'b0;            
            end
        end
    end
    
    
endmodule
