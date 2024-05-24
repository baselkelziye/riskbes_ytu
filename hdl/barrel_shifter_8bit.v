module barrel_shifter_8bit (
 input [7:0] data_i, 
 input [1:0] ctrl_i, 
 input [2:0] carry_i,
 output [7:0] data_o
);
   wire [2:0] z;
   wire [7:0] y;

   //2 bit shift right

// Instantiate the mux_2x1 for 1-bit inputs
mux_2x1 #(
    .DATA_WIDTH(1)
) cins_2 (
    .in0(1'b0), 
    .in1(carry_i[2]), 
    .select(ctrl_i[1]), 
    .out(z[2])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) cins_1 (
    .in0(1'b0),
    .in1(carry_i[1]),
    .select(ctrl_i[1]),
    .out(z[1])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) cins_0 (
    .in0(carry_i[2]),
    .in1(carry_i[0]),
    .select(ctrl_i[1]),
    .out(z[0])
);

// 2-bit shift left
mux_2x1 #(
    .DATA_WIDTH(1)
) ins_27 (
    .in0(data_i[7]),
    .in1(data_i[5]),
    .select(ctrl_i[1]),
    .out(y[7])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_26 (
    .in0(data_i[6]),
    .in1(data_i[4]),
    .select(ctrl_i[1]),
    .out(y[6])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_25 (
    .in0(data_i[5]),
    .in1(data_i[3]),
    .select(ctrl_i[1]),
    .out(y[5])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_24 (
    .in0(data_i[4]),
    .in1(data_i[2]),
    .select(ctrl_i[1]),
    .out(y[4])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_23 (
    .in0(data_i[3]),
    .in1(data_i[1]),
    .select(ctrl_i[1]),
    .out(y[3])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_22 (
    .in0(data_i[2]),
    .in1(data_i[0]),
    .select(ctrl_i[1]),
    .out(y[2])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_21 (
    .in0(data_i[1]),
    .in1(z[2]),
    .select(ctrl_i[1]),
    .out(y[1])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_20 (
    .in0(data_i[0]),
    .in1(z[1]),
    .select(ctrl_i[1]),
    .out(y[0])
);

// 1-bit shift left
mux_2x1 #(
    .DATA_WIDTH(1)
) ins_07 (
    .in0(y[7]),
    .in1(y[6]),
    .select(ctrl_i[0]),
    .out(data_o[7])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_06 (
    .in0(y[6]),
    .in1(y[5]),
    .select(ctrl_i[0]),
    .out(data_o[6])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_05 (
    .in0(y[5]),
    .in1(y[4]),
    .select(ctrl_i[0]),
    .out(data_o[5])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_04 (
    .in0(y[4]),
    .in1(y[3]),
    .select(ctrl_i[0]),
    .out(data_o[4])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_03 (
    .in0(y[3]),
    .in1(y[2]),
    .select(ctrl_i[0]),
    .out(data_o[3])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_02 (
    .in0(y[2]),
    .in1(y[1]),
    .select(ctrl_i[0]),
    .out(data_o[2])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_01 (
    .in0(y[1]),
    .in1(y[0]),
    .select(ctrl_i[0]),
    .out(data_o[1])
);

mux_2x1 #(
    .DATA_WIDTH(1)
) ins_00 (
    .in0(y[0]),
    .in1(z[0]),
    .select(ctrl_i[0]),
    .out(data_o[0])
);


endmodule