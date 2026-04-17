# simulator
XRUN = xrun 

#Directory
RTL_DIR = ../rtl
TB_DIR = ../tb
SIM_DIR = .

# uvm 
UVM_ARGS = -uvm -uvmhome CDNS-1.2 

# compile
COMP_ARGS = -sv \
			-access +rwc \
			-incdir ../prim/rtl 
			-incdir ../tlul/rtl
			-incdir $(RTL_DIR) \
			-incdir $(TB_DIR)/agent \
			-incdir $(TB_DIR)/env \
			-incdir $(TB_DIR)/sequences \
			-incdir $(TB_DIR)/tests \
			-incdir $(TB_DIR)/top \
			-incdir $(TB_DIR)/coverage \
			-incdir $(TB_DIR)/sva 

# Default test 
TEST ?= i2c_base_test 

# Targets 
.PHONY: compile sim clean 

compile:
	$(XRUN) $(UVM_ARGS) $(COMP_ARGS) \
	-f $(SIM_DIR)/filelist.f \
	-elaborate 

sim:
	$(XRUN) $(UVM_ARGS) $(COMP_ARGS) \
	-f $(SIM_DIR)/filelist.f \
	-run -uvmtest=$(TEST) \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=UVM_MEDIUM 

clean:
	rm -rf xrun.log xrun.key xcelium.d waves.vcd