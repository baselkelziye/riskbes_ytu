import cocotb
from cocotb.triggers import Timer

def get_register_file(dut):
    return dut.cpu.core.u_id.u_regfile.registers
        

def extract_data_cache(dut):
   result = []
   
   BLOCK_COUNT = 16
   SUBBLOCK_COUNT = 4
   SUBSUBBLOCK_COUNT = 4
   SUBSUBBLOCK_BYTE_COUNT = 8
   
   # Evet bunların sıralaması böyle olacak
   for i in range(BLOCK_COUNT):
      for j in range(SUBSUBBLOCK_BYTE_COUNT):
         for k in range(SUBBLOCK_COUNT):
            for l in range (SUBSUBBLOCK_COUNT):
               result.append(dut.cpu.dcache.genblk1[i].block.genblk1[k].sub.genblk1[l].sub.bytes[j])
         
   return result
  
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
""" async def load_instruction_cache(dut, file_path):
    dut.cpu.instr_sel = 0; # Select cache, not internal rom;

    cache_size = 100  # Example size, adjust according to your actual cache size
    
    # Reset/Clear the instruction cache
    for i in range(cache_size):
        dut.cpu.icache.genblk2[i >> 5].block.genblk1[i & 3].sub.words[(i >> 2) & 7].value = 0x13  # NOP
    
    # Minimal wait time after clearing the cache
    await Timer(1, units='ns')

    # Load new instructions into the cache
    with open(file_path, "r") as file:
        lines = file.readlines()
        for i, line in enumerate(lines):
            instruction = int(line.strip(), 16)
            # Assign the instruction to the cache
            dut.cpu.icache.genblk2[i >> 5].block.genblk1[i & 3].sub.words[(i >> 2) & 7].value = instruction

    # Wait time to ensure assignment is processed
    await Timer(1, units='ns') """

async def load_code(dut, file_path):
    dut.cpu.instr_sel.value = 0 # Select cache, not internal rom;

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
    data_memory = extract_data_cache(dut)
    expected_data_values = ["0x01", "0x02", "0x03", "0x04", "0x05", "0x06", "0x07", "0x08", "0x09", "0x0b"]

    for i in range(10):
    # Fetch the value from your DUT's data memory directly
        dut_value = data_memory[256 + i].value

        # Assuming dut_value is already an integer, we can compare directly after converting
        # the expected value from hex to int
        expected_value = int(expected_data_values[i], 16)
        
        # Now compare the values
        if dut_value != expected_value:
            dut._log.error(f"Mismatch at Data Memory {256+i}: expected {expected_data_values[i]}, got {hex(dut_value)}")
        else:
            dut._log.info(f"Data Memory {256+i} matches the expected value: {hex(dut_value)}")
        
    
@cocotb.test()
async def umut_cpu(dut):
    filename = "umut_cpu.txt"
    dut.rst_i.value = 1
    await run_clock(dut, 10, 2)
    dut.rst_i.value = 0
    await load_code(dut, filepath + filename)

    num_cycles = 400
    await run_clock(dut, num_cycles, period_ns)
    expect_values = ["0x0a", "0x0a", "0xa00", "0xa0a", "0xa00", "0x646400", "0x03", "0x9ff",
                      "0xa0b", "0x0b",  "0x1000", "0x1048", "0x00", "0x01", "0x01",
                        "0x01", "0x00", "0x00", "0x00", "0x00", "0x00", "0x00", "0x00", "0x02",
                        "0x50", "0xffff9b38", "0xffffff01", "0xffffffff", "0x00", "0x01", "0xff"]
    register_file = get_register_file(dut)
    for i in range(31):
        dut_value = register_file[i+1].value
        expected_value = int(expect_values[i], 16)
        
        if dut_value != expected_value:
            dut._log.error(f"Mismatch at Register {i+1}: expected {expect_values[i]}, got {hex(dut_value)}")
        else:
            dut._log.info(f"Register {i+1} matches the expected value: {hex(dut_value)}")


""" @cocotb.test()
async def zahid_bubblesort(dut):
    filename = "zahid_bubblesort.txt"
    dut.rst_i.value = 1
    await run_clock(dut, 10, 2)
    dut.rst_i.value = 0
    await load_instruction_cache(dut, filepath + filename)
    num_cycles = 2000  # Define the number of cycles to run the clock
    await run_clock(dut, num_cycles, period_ns)
    # After the clock has been run for 400 cycles, you can add your comparison logic here.  
    data_memory = extract_memory(dut)
    expected_values = ["0x14", "0x00", "0x00", "0x00", "0x13", "0x00", "0x00", "0x00", "0x12", "0x00", "0x00", "0x00",
                       "0x11", "0x00", "0x00", "0x00", "0x10", "0x00", "0x00", "0x00", "0x0f", "0x00", "0x00", "0x00",
                       "0x0e", "0x00", "0x00", "0x00", "0x0d", "0x00", "0x00", "0x00", "0x0c", "0x00", "0x00", "0x00",
                       "0x0b", "0x00", "0x00", "0x00", "0x0a", "0x00", "0x00", "0x00", "0x09"]
    for i in range(45):
        dut_value = data_memory[i].value
        expected_value = int(expected_values[i], 16)
        
        if dut_value != expected_value:
            dut._log.error(f"Mismatch at Data Memory {i}: expected {expected_values[i]}, got {hex(dut_value)}")
        else:
            dut._log.info(f"Data Memory {i} matches the expected value: {hex(dut_value)}") """


@cocotb.test()
async def zahid_carpma(dut):
    filename = "zahid_carpma.txt"
    dut.rst_i.value = 1
    await run_clock(dut, 10, 2)
    dut.rst_i.value = 0
    await load_code(dut, filepath + filename)
    num_cycles = 100
    await run_clock(dut, num_cycles, period_ns)
    expected_value = 143 #in decimal
    register_file = get_register_file(dut)
    
    if(register_file[10].value != expected_value):
        dut._log.error(f"Mismatch at Register 10: expected {expected_value}, got {register_file[10].value}")
    else:
        dut._log.info(f"Register 10 matches the expected value: {register_file[10].value}")
