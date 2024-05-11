`timescale 1ns / 1ps
//TODO

//6.01.2023


//TEKNOFEST ICIN YAPILACAKLAR
//otomatik bi sekilde OBJ KODLARI OKUYUP INSTURCTION CACHE'e YERLESTIR
//memory erisiminde adres alignment bakilacak mi?
//resetleri aktif 0 yap
//Hazard detection yapinca aradaki komutu NOP yapmamiz gerekir mi?

module core(
   input clk_i,
   input rst_i,
   
   input instr_cache_blocking_n_i,
   
   input [31:0] instr_cache_data_i,
   input [31:0] data_cache_data_i,
   
   output [31:2] instr_cache_address_o,
   output [31:2] data_cache_address_o,
   output [3:0] data_cache_write_en_o,
   output [31:0] data_cache_data_o
);
    
   //***********IF-ID STAGE VARIABLES************
   wire is_long_if_id_o; 
    
   wire [31:1] pc_if_id_o; //ID asamasina giren PC olduugu icin PC_ID_O isimlend
   wire [31:2] instruction_if_id_o;
    
   wire [4:0] rd_if_id_o  = instruction_if_id_o[11:7]; 
   wire [4:0] rs1_if_id_o = instruction_if_id_o[19:15]; 
   wire [4:0] rs2_if_id_o = instruction_if_id_o[24:20];
   wire [6:0] instruction_opcode_if_id_o = {instruction_if_id_o[6:2], 2'b11};
   wire [2:0] instruction_funct3_if_id_o = instruction_if_id_o[14:12];
   wire [6:0] instruction_funct7_if_id_o = instruction_if_id_o[31:25];
   wire [24:0] instruction_payload_if_id_o = instruction_if_id_o[31:7];
    
    
    //*******************ID-EX STAGE VARIABLES***********   
    wire is_long_id_ex_o;  

    wire [31:0] rs1_value_id_ex_o;
    
    wire [31:0] pc_id_ex_o; //pass PC to ID/EX stage

    wire [31:0] rs2_value_id_ex_o;

    wire [31:0] imm_value_id_ex_o;

    wire [2:0] imm_sel_id_ex_o; 

    wire alu_op1_sel_id_ex_o;

    wire alu_op2_sel_id_ex_o; 

    wire [4:0] alu_op_id_ex_o; 

    wire [2:0] branch_sel_id_ex_o;  

    wire [3:0] read_write_sel_id_ex_o; 

    wire [1:0] wb_sel_id_ex_o;

    wire reg_wb_en_id_ex_o;  
    
    wire [4:0] rd_id_ex_o; //pass rd label for the writeback   
    wire [4:0] rs1_label_id_ex_o; //forwarding unit
    
    wire [4:0] rs2_label_id_ex_o;    
    wire is_memory_instruction_id_ex_o;
    
    //*****************EX-MEM******************
    wire is_long_ex_mem_o; 
    
    wire [31:0] alu_out_ex_mem_i; // for alu output
    wire [31:0] alu_out_ex_mem_o;
    wire reg_wb_en_ex_mem_o;
    wire [4:0] rd_ex_mem_o;  
    wire [31:0] pc_ex_mem_o;  
    wire [1:0] wb_sel_ex_mem_o; // control signal to WB                              
    wire [31:0] imm_ex_mem_o;   
    wire [3:0] read_write_sel_ex_mem_o;
    wire [4:0] rs1_label_ex_mem_o;
    wire [4:0] rs2_label_ex_mem_o;   
    wire [31:0] rs2_ex_mem_o; 
    wire is_memory_instruction_ex_mem_o;  
    wire PC_sel_w_ex_mem_o;
    
    // forwarding unit                   
    wire [31:0] alu_in1_forwarded_input;
    wire [31:0] alu_in2_forwarded_input;
    wire [1:0]  forwardA;
    wire [1:0]  forwardB;
    
    //    *********** MEM-WB STAGE ***************
    wire is_long_mem_wb_o; 

    wire reg_wb_en_mem_wb_o;  
    wire [4:0] rd_mem_wb_o;  
    wire [31:0] alu_out_mem_wb_o;  
    wire [1:0] wb_sel_mem_wb_o; // control signal to write back to reg file (which value) 
    wire [31:0] rd_data_mem_wb_o; 
    wire [31:0] imm_mem_wb_o;
    wire [31:0] pc_mem_wb_o;
    wire is_memory_instruction_mem_wb_o; 
    wire [31:0] rs2_mem_wb_o;   
    wire [31:0] pc_mem_wb_o_4; 

    //************ tmp values *******************\\
    
    //tmp control signals
    wire stall;
    wire [31:0] alu_in1_w;
    wire [31:0] alu_in2_w; 
    wire [31:0] reg_wb_data_w;
    wire data_busy_w;
    wire ins_busy_w;
    wire busy_w;
    wire write_en_w;
    
    assign busy_w = (data_busy_w | ins_busy_w);
    assign write_en_w = (reg_wb_en_mem_wb_o & !busy_w); //reg i mem_wb_o yapmak laizm en son

   u_if u_if(
     .clk_i(clk_i),
     .rst_i(rst_i),
     .cache_blocking_n_i(instr_cache_blocking_n_i),
     .cache_data_i(instr_cache_data_i),
     .cache_address_o(instr_cache_address_o),
     .data_busywait_i(data_busy_w),
     .ins_busywait_o(ins_busy_w),
     .stall(stall),
     .branching(PC_sel_w_ex_mem_o),
     .branch_pc(alu_out_ex_mem_o[31:1]),
     .instr_o(instruction_if_id_o),
     .is_long_o(is_long_if_id_o),
     .pc_o(pc_if_id_o)
   );
    
        
   wire [31:1] u_id_pc_o;  
   assign pc_id_ex_o = {u_id_pc_o, 1'b0};   
   instruction_decode_stage u_id(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .instr_i(instruction_if_id_o),
      .busywait(busy_w),
      .flush(PC_sel_w_ex_mem_o),
      .stall(stall),
      
      .rd_label_i(rd_mem_wb_o),
      .rd_data_i(reg_wb_data_w),
      .rd_enable_i(reg_wb_en_mem_wb_o),
      
      .is_long_i(is_long_if_id_o),
      .pc_i(pc_if_id_o),
      .pc_id_ex_o(u_id_pc_o),
        
      .rs1_value_id_ex_o(rs1_value_id_ex_o),
      .rs2_value_id_ex_o(rs2_value_id_ex_o),
      .imm_value_id_ex_o(imm_value_id_ex_o),
      .imm_sel_id_ex_o(imm_sel_id_ex_o),
      .alu_op1_sel_id_ex_o(alu_op1_sel_id_ex_o),
      .alu_op2_sel_id_ex_o(alu_op2_sel_id_ex_o),
      .alu_op_id_ex_o(alu_op_id_ex_o),
      .branch_sel_id_ex_o(branch_sel_id_ex_o),   //signal 3 bit
      .read_write_sel_id_ex_o(read_write_sel_id_ex_o),
      .wb_sel_id_ex_o(wb_sel_id_ex_o),
      .reg_wb_en_id_ex_o(reg_wb_en_id_ex_o),
      .rd_id_ex_o(rd_id_ex_o),
      .rs1_label_id_ex_o(rs1_label_id_ex_o),
      .rs2_label_id_ex_o(rs2_label_id_ex_o),
      .is_memory_instruction_id_ex_o(is_memory_instruction_id_ex_o),
      .is_load_instruction_id_ex_o(is_load_instruction_id_ex_o),
      .is_long_id_ex_o(is_long_id_ex_o)
   );


    //Dallanma birimi (umutuun raporuna bakilmali)
    branch_jump u_branch_jump(
        .in1_i(alu_in1_w),          //alu output yap
        .in2_i(alu_in2_w),
        .bj_sel_i(branch_sel_id_ex_o), //sinyal
        .PC_sel_o(PC_sel_w)            //sinyal
    );
        

                         
     //Yonlendirma birimi, kendi dosyasinda aciklama yapildi
    forwarding_unit forwarding_unit(
        .rd_label_ex_mem_o(rd_ex_mem_o),
        .rd_label_mem_wb_o(rd_mem_wb_o),
        .rs1_label_id_ex_o(rs1_label_id_ex_o),
        .rs2_label_id_ex_o(rs2_label_id_ex_o),
        .reg_wb_en_ex_mem_o(reg_wb_en_ex_mem_o),
        .reg_wb_en_mem_wb_o(reg_wb_en_mem_wb_o),
        .is_memory_instruction_mem_wb_o(is_memory_instruction_mem_wb_o),
        .forwardA(forwardA),
        .forwardB(forwardB)
    );
    
    
        //bu mux RS1 degerinin en guncelini secer (forwarding unit ile)
    mux #(
        .DATA_WIDTH(32),
        .NUM_INPUTS(4)   
    ) rs1_latest_value_selector (
        .in_flat(
        {rd_data_mem_wb_o, // LOAD sonucu
         alu_out_ex_mem_o, // ex_mem deki ALU sonucu
         alu_out_mem_wb_o, // mem_wb deki ALU sonucu
         rs1_value_id_ex_o}),    // reg file dan okunan rs1 degeri
        .select(forwardA), // Selection signal
        .out(alu_in1_w)    // Output of the MUX
    );


    mux #(
        .DATA_WIDTH(32),    
        .NUM_INPUTS(2)      
    ) pc_or_rs1_selector (
        .in_flat(
        {pc_id_ex_o,                  //PC degeri
         alu_in1_w}),                 // En guncel rs1 degeri
        .select(alu_op1_sel_id_ex_o), 
        .out(alu_in1_forwarded_input) 
    );


    //Asagidaki iki mux yukari ile ayni sadece farkli seyleri seciyor
    mux #(
        .DATA_WIDTH(32),    
        .NUM_INPUTS(2)      
    ) imm_or_rs2_selector (
        .in_flat(
        {imm_value_id_ex_o,                  //imm degeri
         alu_in2_w}),                  // en guncel rs2 degeri
        .select(alu_op2_sel_id_ex_o),  
        .out(alu_in2_forwarded_input)       
    );

   
    mux #(
        .DATA_WIDTH(32),    
        .NUM_INPUTS(4)      
    ) rs2_latest_value_selector (
        .in_flat(
        {rd_data_mem_wb_o, 
         alu_out_ex_mem_o,
         alu_out_mem_wb_o,
         rs2_value_id_ex_o}), 
        .select(forwardB),         
        .out(alu_in2_w) 
    );
                                   
    alu u_alu(
        .alu1_i(alu_in1_forwarded_input),  //bunlar anlik cikis oldugu icin pipeline'a girmelerine gerek yok.
        .alu2_i(alu_in2_forwarded_input),
        .alu_op_i(alu_op_id_ex_o),
        .result_o(alu_out_ex_mem_i)
    );

    ex_mem_stage_reg ex_mem(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .busywait(busy_w),
        .is_long_ex_mem_i(is_long_id_ex_o),
        .is_long_ex_mem_o(is_long_ex_mem_o),
        .alu_out_ex_mem_i(alu_out_ex_mem_i),
        .alu_out_ex_mem_o(alu_out_ex_mem_o),
        .reg_wb_en_ex_mem_i(reg_wb_en_id_ex_o),
        .reg_wb_en_ex_mem_o(reg_wb_en_ex_mem_o),
        .rd_ex_mem_i(rd_id_ex_o), //in_id nin cikisini ver buraya
        .rd_ex_mem_o(rd_ex_mem_o),
        .pc_ex_mem_i(pc_id_ex_o),
        .pc_ex_mem_o(pc_ex_mem_o),
        .wb_sel_ex_mem_i(wb_sel_id_ex_o),
        .wb_sel_ex_mem_o(wb_sel_ex_mem_o),
        .imm_ex_mem_i(imm_value_id_ex_o),
        .imm_ex_mem_o(imm_ex_mem_o),
        .rs1_label_ex_mem_i(rs1_label_id_ex_o),
        .rs1_label_ex_mem_o(rs1_label_ex_mem_o),
        .rs2_label_ex_mem_i(rs2_label_id_ex_o),
        .rs2_label_ex_mem_o(rs2_label_ex_mem_o),
        .read_write_sel_ex_mem_i(read_write_sel_id_ex_o),
        .read_write_sel_ex_mem_o(read_write_sel_ex_mem_o),
        .rs2_ex_mem_i(alu_in2_w),
        .rs2_ex_mem_o(rs2_ex_mem_o),
        .is_memory_instruction_ex_mem_i(is_memory_instruction_id_ex_o),
        .is_memory_instruction_ex_mem_o(is_memory_instruction_ex_mem_o),
        .PC_sel_w_ex_mem_i(PC_sel_w),
        .PC_sel_w_ex_mem_o(PC_sel_w_ex_mem_o)
    );
                 
    
//    data_cache c_data_cache(
//        .clk_i(clk_i),
//        .rst_i(rst_i),
//        .address_i(alu_out_ex_mem_o),
//        .write_data_i(rs2_ex_mem_o), //rs2 n�n de�erini ta�� yaz oraya
//        .read_write_sel_i(read_write_sel_ex_mem_o),
//        .read_data_o(data_cache_data_out),
//        .busy_o(data_busy_w)
//    );

//   assign data_cache_address_o = alu_out_ex_mem_o[31:2];

//   cache_access_unit cache_access_unit(
//      .clk_i(clk_i),
//      .rst_i(rst_i),
//      .addr_align_i(alu_out_ex_mem_o[1:0]),
//      .core_raw_data_i(rs2_ex_mem_o),
//      .cache_raw_data_i(data_cache_data_i),
//      .op_type_i(read_write_sel_ex_mem_o),
//      .write_en_o(data_cache_write_en_o),
//      .core_normalized_data_o(data_cache_data_o),
//      .cache_normalized_data_o(data_cache_data_out),
//      .busy_o(data_busy_w)
//   );
  
   
//   mem_wb_stage_reg mem_wb(
//        .clk_i(clk_i),
//        .rst_i(rst_i),
//        .busywait(busy_w),
//        .is_long_mem_wb_i(is_long_ex_mem_o),
//        .is_long_mem_wb_o(is_long_mem_wb_o),
//        .reg_wb_en_mem_wb_i(reg_wb_en_ex_mem_o),
//        .reg_wb_en_mem_wb_o(reg_wb_en_mem_wb_o),
//        .rd_mem_wb_i(rd_ex_mem_o),
//        .rd_mem_wb_o(rd_mem_wb_o),
//        .rd_data_mem_wb_i(data_cache_data_out),
//        .rd_data_mem_wb_o(rd_data_mem_wb_o),
//        .alu_out_mem_wb_i(alu_out_ex_mem_o),
//        .alu_out_mem_wb_o(alu_out_mem_wb_o),
//        .wb_sel_mem_wb_i(wb_sel_ex_mem_o),
//        .wb_sel_mem_wb_o(wb_sel_mem_wb_o),
//        .imm_mem_wb_i(imm_ex_mem_o),
//        .imm_mem_wb_o(imm_mem_wb_o),
//        .pc_mem_wb_i(pc_ex_mem_o),
//        .pc_mem_wb_o(pc_mem_wb_o),
//        .is_memory_instruction_mem_wb_i(is_memory_instruction_ex_mem_o),
//        .is_memory_instruction_mem_wb_o(is_memory_instruction_mem_wb_o),
//        .rs2_mem_wb_i(rs2_ex_mem_o),
//        .rs2_mem_wb_o(rs2_mem_wb_o)
//    );

   memory_stage u_mem(
      .clk_i(clk_i),
      .rst_i(rst_i),
      
      .busywait_i(busy_w),
      
      .data_cache_data_i(data_cache_data_i),
      .op_type_i(read_write_sel_ex_mem_o),
      .reg_wb_en_i(reg_wb_en_ex_mem_o),
      .rd_label_i(rd_ex_mem_o),
      .alu_out_i(alu_out_ex_mem_o),
      .wb_sel_i(wb_sel_ex_mem_o),
      .imm_i(imm_ex_mem_o),
      .pc_i(pc_ex_mem_o),
      .is_memory_instruction_i(is_memory_instruction_ex_mem_o),
      .rs2_data_i(rs2_ex_mem_o),
      .is_long_i(is_long_ex_mem_o),
      
      .data_busywait_o(data_busy_w),
      .data_cache_data_o(data_cache_data_o),
      .data_cache_write_en_o(data_cache_write_en_o),
      .data_cache_address_o(data_cache_address_o),
      .load_val_o(rd_data_mem_wb_o),
      
      .reg_wb_en_o(reg_wb_en_mem_wb_o),
      .rd_label_o(rd_mem_wb_o),
      .alu_out_o(alu_out_mem_wb_o),
      .wb_sel_o(wb_sel_mem_wb_o),
      .imm_o(imm_mem_wb_o),
      .pc_o(pc_mem_wb_o),
      .is_memory_instruction_o(is_memory_instruction_mem_wb_o),
      .rs2_data_o(rs2_mem_wb_o),
      .is_long_o(is_long_mem_wb_o)
   );

    pc_adder u_pc_adder1(
        .in_i(pc_mem_wb_o), //PC i 4 ile toplar
        .out_o(pc_mem_wb_o_4), // cunku son muxta PC+4 var, su ana kadar sadece PC i ilettik biz, 4 ile toplayip yollamamiz lazim.
        .is_long(is_long_mem_wb_o)
    );

    mux #(
        .DATA_WIDTH(32),    // Set the data width of each input to 32 bits
        .NUM_INPUTS(4)      // Set the number of inputs to 4 (for a 4-to-1 MUX)
    ) u_wb_mux (
        .in_flat({pc_mem_wb_o_4, imm_mem_wb_o, rd_data_mem_wb_o, alu_out_mem_wb_o}), // Concatenate inputs for the mux
        .select(wb_sel_mem_wb_o),    // Selection signal
        .out(reg_wb_data_w)          // Output of the MUX
    );
     
endmodule
