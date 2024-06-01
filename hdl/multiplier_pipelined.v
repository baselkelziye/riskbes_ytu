// Unsigned 32-bit 3-stage Pipelined Multiplier
module multiplier_pipelined (
 input         clk_i,
 input         rst_i,
 input         en_i,
 input  [31:0] muler_i,
 input  [31:0] mulcand_i,
 output  [63:0] product_o,
 output reg  ack_o
);

   reg  [2:0] state;
   reg        running;
   
   // Register Wires - Input Register Outputs                  
   reg [31:0] muler_q, muland_q;

   // State machine logic
   always @(posedge clk_i, posedge rst_i) begin 
    if (rst_i) begin 
     state    <= 0;
     running  <= 0;
     ack_o    <= 0;
     muler_q  <= 0;
     muland_q <= 0;
    end
    // Start state machine
    else if (en_i && !running) begin 
     state    <= 1;
     running  <= 1;
     ack_o    <= 0;
     muler_q  <= muler_i;
     muland_q <= mulcand_i;
    end
    // ack_o, set flag, stop running
    else if (state == 3'd4) begin 
     state    <= 0;
     running  <= 0;
     ack_o    <= 1;
    end
    // Go to next state
    else if (running) begin
     state    <= state + 1;
     ack_o    <= 0;
    end
    else begin 
     state    <= 0;
     running  <= 0;
     ack_o    <= 0;
    end
   end
   
   ////////////////////////////////////////////////// 
   //              Input Regigister
   //////////////////////////////////////////////////
   // 32-bit Partial Products
   wire [31:0] pp0,  pp1,  pp2,  pp3,  pp4,  pp5,  pp6,  pp7, 
               pp8,  pp9,  pp10, pp11, pp12, pp13, pp14, pp15,
               pp16, pp17, pp18, pp19, pp20, pp21, pp22, pp23, 
               pp24, pp25, pp26, pp27, pp28, pp29, pp30, pp31;

   partial_product pp_32(
    .muler_i   (muler_q),
    .mulcand_i (muland_q),
    .pp0_o  (pp0),   .pp1_o  (pp1),   .pp2_o  (pp2),   .pp3_o  (pp3),
    .pp4_o  (pp4),   .pp5_o  (pp5),   .pp6_o  (pp6),   .pp7_o  (pp7),
    .pp8_o  (pp8),   .pp9_o  (pp9),   .pp10_o (pp10),  .pp11_o (pp11),   
    .pp12_o (pp12),  .pp13_o (pp13),  .pp14_o (pp14),  .pp15_o (pp15),   
    .pp16_o (pp16),  .pp17_o (pp17),  .pp18_o (pp18),  .pp19_o (pp19),   
    .pp20_o (pp20),  .pp21_o (pp21),  .pp22_o (pp22),  .pp23_o (pp23),   
    .pp24_o (pp24),  .pp25_o (pp25),  .pp26_o (pp26),  .pp27_o (pp27),
    .pp28_o (pp28),  .pp29_o (pp29),  .pp30_o (pp30),  .pp31_o (pp31)
   );

   // 64-bit Padded Partial Products
   wire [63:0] pad0,  pad1,  pad2,  pad3,  pad4,  pad5,  pad6,  pad7, 
               pad8,  pad9,  pad10, pad11, pad12, pad13, pad14, pad15,
               pad16, pad17, pad18, pad19, pad20, pad21, pad22, pad23, 
               pad24, pad25, pad26, pad27, pad28, pad29, pad30, pad31;
    
   // Shift Partial Products to Generate Padded Partial Products
   assign pad0  = {32'b0, pp0}  <<  0;
   assign pad1  = {32'b0, pp1}  <<  1;
   assign pad2  = {32'b0, pp2}  <<  2;
   assign pad3  = {32'b0, pp3}  <<  3;
   assign pad4  = {32'b0, pp4}  <<  4;
   assign pad5  = {32'b0, pp5}  <<  5;
   assign pad6  = {32'b0, pp6}  <<  6;
   assign pad7  = {32'b0, pp7}  <<  7;
   assign pad8  = {32'b0, pp8}  <<  8;
   assign pad9  = {32'b0, pp9}  <<  9;
   assign pad10 = {32'b0, pp10} << 10;
   assign pad11 = {32'b0, pp11} << 11;
   assign pad12 = {32'b0, pp12} << 12;
   assign pad13 = {32'b0, pp13} << 13;
   assign pad14 = {32'b0, pp14} << 14;
   assign pad15 = {32'b0, pp15} << 15;
   assign pad16 = {32'b0, pp16} << 16;
   assign pad17 = {32'b0, pp17} << 17;
   assign pad18 = {32'b0, pp18} << 18;
   assign pad19 = {32'b0, pp19} << 19;
   assign pad20 = {32'b0, pp20} << 20;
   assign pad21 = {32'b0, pp21} << 21;
   assign pad22 = {32'b0, pp22} << 22;
   assign pad23 = {32'b0, pp23} << 23;
   assign pad24 = {32'b0, pp24} << 24;
   assign pad25 = {32'b0, pp25} << 25;
   assign pad26 = {32'b0, pp26} << 26;
   assign pad27 = {32'b0, pp27} << 27;
   assign pad28 = {32'b0, pp28} << 28;
   assign pad29 = {32'b0, pp29} << 29;
   assign pad30 = {32'b0, pp30} << 30;
   assign pad31 = {32'b0, pp31} << 31;

   // Padded Partial Product Sums
   // 0th Level Sums
   wire [63:0] sumL0_0, sumL0_1, sumL0_2,  sumL0_3,  sumL0_4,  sumL0_5,  sumL0_6,  sumL0_7,
               sumL0_8, sumL0_9, sumL0_10, sumL0_11, sumL0_12, sumL0_13, sumL0_14, sumL0_15;
   // 1st Level Sums
   wire [63:0] sumL1_0, sumL1_1, sumL1_2,  sumL1_3,  sumL1_4,  sumL1_5,  sumL1_6,  sumL1_7;
   // 2nd Level Sums
   wire [63:0] sumL2_0, sumL2_1, sumL2_2, sumL2_3;
   // 3rd Level Sums
   wire [63:0] sumL3_0, sumL3_1; 
   // 4th Level Sum
   wire [63:0] sumL4_0; // Product

   // Oth Level Multiplier CLAs
   cla_64bit cla_64bitL0_0 (
    .term1_i  (pad0[63:0]),
    .term2_i  (pad1[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_0),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_1 (
    .term1_i  (pad2[63:0]),
    .term2_i  (pad3[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_1),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_2 (
    .term1_i  (pad4[63:0]),
    .term2_i  (pad5[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_2),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_3 (
    .term1_i  (pad6[63:0]),
    .term2_i  (pad7[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_3),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_4 (
    .term1_i  (pad8[63:0]),
    .term2_i  (pad9[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_4),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_5 (
    .term1_i  (pad10[63:0]),
    .term2_i  (pad11[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_5),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_6 (
    .term1_i  (pad12[63:0]),
    .term2_i  (pad13[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_6),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_7 (
    .term1_i  (pad14[63:0]),
    .term2_i  (pad15[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_7),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_8 (
    .term1_i  (pad16[63:0]),
    .term2_i  (pad17[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_8),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_9 (
    .term1_i  (pad18[63:0]),
    .term2_i  (pad19[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_9),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_10 (
    .term1_i  (pad20[63:0]),
    .term2_i  (pad21[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_10),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_11 (
    .term1_i  (pad22[63:0]),
    .term2_i  (pad23[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_11),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_12 (
    .term1_i  (pad24[63:0]),
    .term2_i  (pad25[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_12),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_13 (
    .term1_i  (pad26[63:0]),
    .term2_i  (pad27[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_13),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_14 (
    .term1_i  (pad28[63:0]),
    .term2_i  (pad29[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_14),
    .carry_o  ()
   );
   cla_64bit cla_64bitL0_15 (
    .term1_i  (pad30[63:0]),
    .term2_i  (pad31[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL0_15),
    .carry_o  ()
   );

   ////////////////////////////////////////////////// 
   //              Stage Regigister
   //////////////////////////////////////////////////
   
   // Register Wires - Stage Register Outputs                        
   wire [63:0] sumL0_0q, sumL0_1q, sumL0_2q,  sumL0_3q,  sumL0_4q,  sumL0_5q,  sumL0_6q,  sumL0_7q,
               sumL0_8q, sumL0_9q, sumL0_10q, sumL0_11q, sumL0_12q, sumL0_13q, sumL0_14q, sumL0_15q;
   d_reg #(
    .WIDTH(64)
   ) stage_reg00 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_0),
    .data_o(sumL0_0q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg01 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_1),
    .data_o(sumL0_1q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg02 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_2),
    .data_o(sumL0_2q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg03 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_3),
    .data_o(sumL0_3q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg04 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_4),
    .data_o(sumL0_4q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg05 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_5),
    .data_o(sumL0_5q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg06 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_6),
    .data_o(sumL0_6q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg07 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_7),
    .data_o(sumL0_7q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg08 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_8),
    .data_o(sumL0_8q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg09 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_9),
    .data_o(sumL0_9q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg10 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_10),
    .data_o(sumL0_10q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg11 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_11),
    .data_o(sumL0_11q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg12 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_12),
    .data_o(sumL0_12q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg13 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_13),
    .data_o(sumL0_13q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg14 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_14),
    .data_o(sumL0_14q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg15 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL0_15),
    .data_o(sumL0_15q) 
   );


   // 1st Level Level Multiplier CLAs
   cla_64bit cla_64bitL1_0 (
    .term1_i  (sumL0_0q[63:0]),
    .term2_i  (sumL0_1q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL1_0),
    .carry_o  ()
   );
   cla_64bit cla_64bitL1_1 (
    .term1_i  (sumL0_2q[63:0]),
    .term2_i  (sumL0_3q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL1_1),
    .carry_o  ()
   );
   cla_64bit cla_64bitL1_2 (
    .term1_i  (sumL0_4q[63:0]),
    .term2_i  (sumL0_5q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL1_2),
    .carry_o  ()
   );
   cla_64bit cla_64bitL1_3 (
    .term1_i  (sumL0_6q[63:0]),
    .term2_i  (sumL0_7q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL1_3),
    .carry_o  ()
   );
   cla_64bit cla_64bitL1_4 (
    .term1_i  (sumL0_8q[63:0]),
    .term2_i  (sumL0_9q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL1_4),
    .carry_o  ()
   );
   cla_64bit cla_64bitL1_5 (
    .term1_i  (sumL0_10q[63:0]),
    .term2_i  (sumL0_11q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL1_5),
    .carry_o  ()
   );
   cla_64bit cla_64bitL1_6 (
    .term1_i  (sumL0_12q[63:0]),
    .term2_i  (sumL0_13q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL1_6),
    .carry_o  ()
   );
   cla_64bit cla_64bitL1_7 (
    .term1_i  (sumL0_14q[63:0]),
    .term2_i  (sumL0_15q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL1_7),
    .carry_o  ()
   );

   ////////////////////////////////////////////////// 
   //              Stage Regigister
   //////////////////////////////////////////////////
   
   // Register Wires - Stage Register Outputs                        
   wire [63:0] sumL1_0q, sumL1_1q, sumL1_2q,  sumL1_3q,  sumL1_4q,  sumL1_5q,  sumL1_6q,  sumL1_7q;

   d_reg #(
    .WIDTH(64)
   ) stage_reg16 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL1_0),
    .data_o(sumL1_0q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg17 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL1_1),
    .data_o(sumL1_1q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg18 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL1_2),
    .data_o(sumL1_2q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg19 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL1_3),
    .data_o(sumL1_3q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg20 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL1_4),
    .data_o(sumL1_4q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg21 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL1_5),
    .data_o(sumL1_5q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg22 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL1_6),
    .data_o(sumL1_6q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg23 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL1_7),
    .data_o(sumL1_7q) 
   );

   // 2nd Level Multiplier CLAs
   cla_64bit cla_64bitL2_0 (
    .term1_i  (sumL1_0q[63:0]),
    .term2_i  (sumL1_1q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL2_0),
    .carry_o  ()
   );
   cla_64bit cla_64bitL2_1 (
    .term1_i  (sumL1_2q[63:0]),
    .term2_i  (sumL1_3q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL2_1),
    .carry_o  ()
   );
   cla_64bit cla_64bitL2_2 (
    .term1_i  (sumL1_4q[63:0]),
    .term2_i  (sumL1_5q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL2_2),
    .carry_o  ()
   );
   cla_64bit cla_64bitL2_3 (
    .term1_i  (sumL1_6q[63:0]),
    .term2_i  (sumL1_7q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL2_3),
    .carry_o  ()
   );

   ////////////////////////////////////////////////// 
   //              Stage Regigister
   //////////////////////////////////////////////////

   // Register Wires - Stage Register Outputs                        
   wire [63:0] sumL2_0q, sumL2_1q, sumL2_2q,  sumL2_3q;
   d_reg #(
    .WIDTH(64)
   ) stage_reg24 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL2_0),
    .data_o(sumL2_0q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg25 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL2_1),
    .data_o(sumL2_1q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg26 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL2_2),
    .data_o(sumL2_2q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg27 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL2_3),
    .data_o(sumL2_3q) 
   );

   // 3rd Level Multiplier CLAs
   cla_64bit cla_64bitL3_0 (
    .term1_i  (sumL2_0q[63:0]),
    .term2_i  (sumL2_1q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL3_0),
    .carry_o  ()
   );
   cla_64bit cla_64bitL3_1 (
    .term1_i  (sumL2_2q[63:0]),
    .term2_i  (sumL2_3q[63:0]),
    .carry_i  (1'b0),
    .result_o (sumL3_1),
    .carry_o  ()
   );

   ////////////////////////////////////////////////// 
   //              Stage Regigister
   //////////////////////////////////////////////////

   // Register Wires - Stage Register Outputs                        
   wire [63:0] sumL3_0q, sumL3_1q;
   d_reg #(
    .WIDTH(64)
   ) stage_reg28 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL3_0),
    .data_o(sumL3_0q) 
   );
   d_reg #(
    .WIDTH(64)
   ) stage_reg29 (
    .clk_i(clk_i),
    .rst_i(rst_i),
    .data_i(sumL3_1),
    .data_o(sumL3_1q) 
   );

   // 4rd Level Multiplier CLAs
   cla_64bit cla_64bitL4_0 (
    .term1_i  (sumL3_0q[63:0]),
    .term2_i  (sumL3_1q[63:0]),
    .carry_i  (1'b0),
    .result_o (product_o),
    .carry_o  ()
   );

endmodule