import cocotb
from cocotb.triggers import Timer
from memory import MemoryAdapter

def get_register_file(dut):
    return dut.cpu.core.u_id.u_regfile.registers_r
  
@cocotb.coroutine
async def run_clock(dut, num_cycles, period_ns):
    """
    Coroutine to drive the clock signal of the DUT.
    
    :param dut: The device under test.
    :param num_cycles: Number of clock cycles to run.
    :param period_ns: Clock period in nanoseconds.
    """
    # Half period time calculation for toggling the clock.
    half_period = period_ns // 2

    # Run the clock for a specified number of cycles.
    for _ in range(num_cycles):
        dut.clk_i.value = 0
        await Timer(half_period, units='ns')
        dut.clk_i.value = 1
        await Timer(half_period, units='ns')

filepath = "assembly_codes/"
period_ns = 2

async def load_code(dut, file_path):
    with open(file_path, "r") as file:
        lines = file.readlines()

        i = 0
        j = 0
        qword = 0

        for _, line in enumerate(lines):
            word = int(line.strip(), 16)
            if(i < 4):
                qword |= word << (i * 32)
                i += 1
            else:
                dut.ram.data[j].value = qword
                qword = word
                i = 1
                j += 1
        
        dut.ram.data[j].value = qword

    await Timer(1, units='ns')

@cocotb.test()
async def basel_bubblesort(dut):
    filename = "basel_bubblesort.txt"
    dut.rst_i.value = 1
    await run_clock(dut, 10, 2)
    dut.rst_i.value = 0
    await load_code(dut, filepath + filename)
    num_cycles = 2000  # Define the number of cycles to run the clock
    await run_clock(dut, num_cycles, period_ns)
    # After the clock has been run for 400 cycles, you can add your comparison logic here.  
    data_memory = MemoryAdapter(dut)
    expected_data_values = ["0x01", "0x02", "0x03", "0x04", "0x05", "0x06", "0x07", "0x08", "0x09", "0x0b"]

    for i in range(10):
        # Fetch the value from the memory adapter
        dut_value = data_memory[256 + i]

        # Assuming dut_value is already an integer, we can compare directly after converting
        # the expected value from hex to int
        expected_value = int(expected_data_values[i], 16)
        
        # Now compare the values
        if dut_value != expected_value:
            dut._log.error(f"Mismatch at Data Memory {256+i}: expected {expected_data_values[i]}, got {hex(dut_value)}")
        else:
            dut._log.info(f"Data Memory {256+i} matches the expected value: {hex(dut_value)}")

@cocotb.test()
async def mem_test(dut):
    filename = "mem_test.txt"
    dut.rst_i.value = 1
    await run_clock(dut, 10, 2)
    dut.rst_i.value = 0
    await load_code(dut, filepath + filename)
    memory = MemoryAdapter(dut)

    word1 = [0x12, 0x34, 0x56, 0x78]
    word2 = [0x0, 0xBC, 0xDE, 0xFF]

    for i in range(4):
        memory[0x80 + i] = word1[i]
        memory[0x1080 + i] = word2[i]
        await Timer(1, units='ns')


    num_cycles = 300  # Define the number of cycles to run the clock
    await run_clock(dut, num_cycles, period_ns)

    for i in range(4):
        assert memory[0x80 + i] == word1[i] ^ 0xFF
        assert memory[0x1080 + i] == word2[i] ^ 0xFF
    
    assert get_register_file(dut)[31].value == 1

@cocotb.test()
async def BMU_test(dut):
    filename = "bmu_test.txt"
    dut.rst_i.value = 1
    await run_clock(dut, 10, 2)
    dut.rst_i.value = 0
    register_file = dut.cpu.core.u_id.u_regfile.registers_rw
    await load_code(dut, filepath + filename)
    dut._log.info("BMU Test Code loaded")
    num_cycles = 400
    await run_clock(dut, num_cycles, period_ns)
    # Single loop iterating over both expected values and additional registers
    expected_values = ["0x02", "0x64", "0x1f", "0xfffff000", "0xfffffeef", "0xdeadbeef", "0xc", "0xd", "0x4", "0x00ffff00", "0xefbeadde", "0x0000beef",
                       "0xffffa000", "0xffffffef", "0x190", "0x19", "0x19", "0x1", "0x1", "0x7ffff000", "0x7ffff000", "0x7ffff000", "0x7ffff000", "0xfffff000", "0xfffff000",
                       "0x68", "0x6c", "0x74", "0xeef", "0xdeadbfff", "0xffffffff"]
    
    
    additional_registers = [2, 3, 4, 5, 6, 7, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 18, 17, 20, 19, 16, 15, 14, 13, 12, 11, 10, 9, 8, 1]
    if(len(expected_values) != len(additional_registers)):
        dut._log.error("Mismatch in the number of expected values and additional registers")
        return
    # Single loop iterating over both expected values and additional registers
    for idx, reg in enumerate(additional_registers):
        dut_value = register_file[reg].value
        expected_value = int(expected_values[idx], 16)
        if dut_value != expected_value:
            dut._log.error(f"Mismatch at Register {reg}: expected {expected_values[idx]}, got {hex(dut_value)}")
        else:
            dut._log.info(f"Register {reg} matches the expected value: {hex(dut_value)}")

@cocotb.test()
async def pipeline_carpma(dut):
    filename = "pipeline_carpma.txt"
    dut.rst_i.value = 1
    await run_clock(dut, 10,2)
    dut.rst_i.value = 0
    register_file = dut.cpu.core.u_id.u_regfile.registers_rw
    await load_code(dut, filepath + filename)
    dut._log.info("pipeline carpma code loaded")
    num_cycles = 400
    await run_clock(dut, num_cycles, period_ns)
    expected_values = ["0xffffffff", "0x1", "0x1", "0xfffffffe", "0xabcde000", "0xfffffffd", "0xfffffffd", "0x8", "0x1", "0xfffffffd", "0xfffffffd"]
    registers_order = [1,2,3,4,5, 6,7,9,8,10,11]
    for idx, reg in enumerate(registers_order):
        dut_value = register_file[reg].value
        expected_value = int(expected_values[idx], 16)
        if dut_value != expected_value:
            dut._log.error(f"Mismatch at Register {reg}: expected {expected_values[idx]}, got {hex(dut_value)}")
        else:
            dut._log.info(f"Register {reg} matches the expected value: {hex(dut_value)}")