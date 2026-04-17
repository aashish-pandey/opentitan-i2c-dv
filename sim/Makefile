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
			-incdir ../prim/rtl \
			-incdir ../tlul/rtl \
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
	find ../prim/rtl -name "*.sv" \
	  ! -name "prim_lc_*.sv" \
	  ! -name "prim_flash*.sv" \
	  ! -name "prim_sha2*.sv" \
	  ! -name "prim_prince.sv" \
	  ! -name "prim_edn_req.sv" \
	  ! -name "prim_trivium.sv" \
	  ! -name "prim_ram_2p*.sv" \
	  ! -name "prim_ram_1r1w*.sv" \
	  ! -name "prim_rom_adv.sv" \
	  ! -name "prim_gate_gen.sv" \
	  > /tmp/prim_files.f
	find ../prim_generic/rtl -name "*.sv" \
	  ! -name "prim_flash*.sv" \
	  ! -name "prim_generic_flash*.sv" \
	  ! -name "prim_ram_1r1w.sv" \
	  ! -name "prim_ram_2p.sv" \
	  >> /tmp/prim_files.f
	$(XRUN) $(UVM_ARGS) $(COMP_ARGS) \
	-f /tmp/prim_files.f \
	-f $(SIM_DIR)/filelist.f \
	-elaborate \
	-xmlibdirname xcelium.d \
	-log xrun_elab.log \
	-messages \
	-status

sim:
	$(XRUN) $(UVM_ARGS) $(COMP_ARGS) \
	-f $(SIM_DIR)/filelist.f \
	-run -uvmtest=$(TEST) \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=UVM_MEDIUM 

clean:
	rm -rf xrun.log xrun.key xcelium.d waves.vcd