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
	rm -rf xcelium.d
	# Packages first, then modules
	find ../prim/rtl ../prim_generic/rtl -name "*_pkg.sv" \
	  ! -name "prim_ram_2p_pkg.sv" \
	  > /tmp/prim_files.f
	find ../prim/rtl -name "*.sv" ! -name "*_pkg.sv" \
	  ! -name "prim_lc_*.sv" \
	  ! -name "prim_flash*.sv" \
	  ! -name "prim_sha2*.sv" \
	  ! -name "prim_edn_req.sv" \
	  ! -name "prim_trivium.sv" \
	  ! -name "prim_ram_2p*.sv" \
	  ! -name "prim_ram_1r1w*.sv" \
	  ! -name "prim_rom_adv.sv" \
	  ! -name "prim_gate_gen.sv" \
	  ! -name "prim_racl_error_arb.sv" \
	  >> /tmp/prim_files.f
	find ../prim_generic/rtl -name "*.sv" ! -name "*_pkg.sv" \
	  ! -name "prim_flash*.sv" \
	  ! -name "prim_generic_flash*.sv" \
	  ! -name "prim_ram_1r1w.sv" \
	  ! -name "prim_ram_2p.sv" \
	  >> /tmp/prim_files.f
	$(XRUN) $(UVM_ARGS) $(COMP_ARGS) \
	-timescale 1ns/1ps \
	-f /tmp/prim_files.f \
	-f $(SIM_DIR)/filelist.f \
	-elaborate \
	-xmlibdirname xcelium.d \
	-log xrun_elab.log \
	-messages \
	-status

SEED ?= 1

sim:
	$(XRUN) \
	-R \
	-xmlibdirname xcelium.d \
	-log xrun_sim.log \
	-messages \
	-status \
	-svseed $(SEED) \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=UVM_MEDIUM || true

clean:
	rm -rf xrun.log xrun.key xcelium.d waves.vcd