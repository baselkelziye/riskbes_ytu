SIM=icarus
TOPLEVEL_LANG=verilog

# Define the directory containing Verilog source files
HDL_DIR := ../../../hdl

# Use wildcard to include all Verilog (*.v) files from HDL_DIR
VERILOG_SOURCES := $(wildcard $(HDL_DIR)/*.v)

# Specify the name of your top-level module (not the file name)
TOPLEVEL = my_wrapper

# Specify the name of your test module
MODULE = general_tests

# Include cocotb's Makefile
include $(shell cocotb-config --makefiles)/Makefile.sim
