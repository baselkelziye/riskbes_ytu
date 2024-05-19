module barrel_shifter_32bit (
 input  [31:0] data_i,
 input  [1:0]  ctrl_i,
 output [31:0] data_o
);
   barrel_shifter_8bit bs_3 (
    .data_i(data_i[7:0]), 
    .ctrl_i(ctrl_i), 
    .carry_i(3'b000),
    .data_o(data_o[7:0])
   );
   barrel_shifter_8bit bs_2 (
    .data_i(data_i[15:8]), 
    .ctrl_i(ctrl_i), 
    .carry_i(data_i[7:5]),
    .data_o(data_o[15:8])
   );
   barrel_shifter_8bit bs_1 (
    .data_i(data_i[23:16]),
    .ctrl_i(ctrl_i),
    .carry_i(data_i[15:13]),
    .data_o(data_o[23:16])
   );
   barrel_shifter_8bit bs_0 (
    .data_i(data_i[31:24]),
    .ctrl_i(ctrl_i),
    .carry_i(data_i[23:21]),
    .data_o(data_o[31:24])
   );
endmodule