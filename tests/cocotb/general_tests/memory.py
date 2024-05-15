def generate_all_ones(count):
    return (1 << count) - 1

class MemoryAdapter:
    _CACHE_BYTE_SEL_WIDTH = 2
    _CACHE_BYTE_SEL_PATTERN = generate_all_ones(_CACHE_BYTE_SEL_WIDTH)

    _CACHE_WORD_SEL_WIDTH = 2
    _CACHE_WORD_SEL_SHIFT = _CACHE_BYTE_SEL_WIDTH
    _CACHE_WORD_SEL_PATTERN = generate_all_ones(_CACHE_WORD_SEL_WIDTH)

    _CACHE_OFFSET_WIDTH = 3 #Verilog'taki değerden 2 eksik olacak
    _CACHE_OFFSET_SHIFT = _CACHE_WORD_SEL_SHIFT + _CACHE_WORD_SEL_WIDTH
    _CACHE_OFFSET_PATTERN = generate_all_ones(_CACHE_OFFSET_WIDTH)

    _CACHE_INDEX_WIDTH = 4
    _CACHE_INDEX_SHIFT = _CACHE_OFFSET_SHIFT + _CACHE_OFFSET_WIDTH
    _CACHE_INDEX_PATTERN = generate_all_ones(_CACHE_INDEX_WIDTH)

    _CACHE_TAG_WIDTH = 9
    _CACHE_TAG_SHIFT = _CACHE_INDEX_SHIFT + _CACHE_INDEX_WIDTH
    _CACHE_TAG_PATTERN = generate_all_ones(_CACHE_TAG_WIDTH)

    _RAM_SEL_WIDTH = 4
    _RAM_SEL_PATTERN = generate_all_ones(_RAM_SEL_WIDTH)

    _RAM_ADDR_WIDTH = 16
    _RAM_ADDR_SHIFT = _RAM_SEL_WIDTH
    _RAM_ADDR_PATTERN = generate_all_ones(_RAM_ADDR_WIDTH)

    def get_cache_tag(address):
        return (address >> MemoryAdapter._CACHE_TAG_SHIFT) & MemoryAdapter._CACHE_TAG_PATTERN

    def get_cache_index(address):
        return (address >> MemoryAdapter._CACHE_INDEX_SHIFT) & MemoryAdapter._CACHE_INDEX_PATTERN

    def get_cache_offset(address):
        return (address >> MemoryAdapter._CACHE_OFFSET_SHIFT) & MemoryAdapter._CACHE_OFFSET_PATTERN

    def get_cache_word_sel(address):
        return (address >> MemoryAdapter._CACHE_WORD_SEL_SHIFT) & MemoryAdapter._CACHE_WORD_SEL_PATTERN

    def get_cache_byte_sel(address):
        return address & MemoryAdapter._CACHE_BYTE_SEL_PATTERN

    def get_ram_addr(address):
        return (address >> MemoryAdapter._RAM_ADDR_SHIFT) & MemoryAdapter._RAM_ADDR_PATTERN

    def get_ram_sel(address):
        return address & MemoryAdapter._RAM_SEL_PATTERN

    def __init__(self, dut):
        self.dut = dut

    def __getitem__(self, address):
        cache_index = MemoryAdapter.get_cache_index(address)
        if(self.dut.cpu.dcache.block_valid[cache_index].value == 1 and \
            MemoryAdapter.get_cache_tag(address) == self.dut.cpu.dcache.block_tag[cache_index].value):
            
            return int(self.dut.cpu.dcache.genblk3[cache_index].block \
                .genblk1[MemoryAdapter.get_cache_word_sel(address)].sub \
                .genblk1[MemoryAdapter.get_cache_byte_sel(address)] \
                .sub.bytes[MemoryAdapter.get_cache_offset(address)].value)
        else:
            ram_sel = MemoryAdapter.get_ram_sel(address)
            lsb = ram_sel * 8

            return (self.dut.ram.data[MemoryAdapter.get_ram_addr(address)].value >> lsb) & 0xFF

    def __setitem__(self, address, value):
        ram_addr = MemoryAdapter.get_ram_addr(address)
        ram_sel = MemoryAdapter.get_ram_sel(address)
        lsb = ram_sel * 8

        ramdata = int(self.dut.ram.data[ram_addr].value)
        pattern = (0xFF << lsb) ^ 0xFFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF_FFFF
        ramdata &= pattern
        ramdata |= value << lsb

        self.dut.ram.data[ram_addr].value = ramdata