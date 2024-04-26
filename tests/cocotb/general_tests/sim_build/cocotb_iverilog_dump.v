module cocotb_iverilog_dump();
initial begin
    $dumpfile("sim_build/cpu.fst");
    $dumpvars(0, cpu);
end
endmodule
