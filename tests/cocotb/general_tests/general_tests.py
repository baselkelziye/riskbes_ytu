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
