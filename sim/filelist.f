// Stub packages (only what's not in prim)
../tb/top/stub_pkgs.sv



// TLUL
../tlul/rtl/tlul_pkg.sv
../tlul/rtl/tlul_adapter_reg.sv
../tlul/rtl/tlul_cmd_intg_chk.sv
../tlul/rtl/tlul_cmd_intg_gen.sv
../tlul/rtl/tlul_rsp_intg_gen.sv
../tlul/rtl/tlul_rsp_intg_chk.sv
../tlul/rtl/tlul_err.sv
../tlul/rtl/tlul_data_integ_dec.sv
../tlul/rtl/tlul_data_integ_enc.sv

// I2C RTL
../rtl/i2c_pkg.sv
../rtl/i2c_reg_pkg.sv
../rtl/i2c_reg_top.sv
../rtl/i2c_fifos.sv
../rtl/i2c_fifo_sync_sram_adapter.sv
../rtl/i2c_bus_monitor.sv
../rtl/i2c_controller_fsm.sv
../rtl/i2c_target_fsm.sv
../rtl/i2c_core.sv
../rtl/i2c.sv

// Testbench
../tb/env/i2c_tb_pkg.sv
../tb/top/i2c_if.sv
../tb/top/tlul_if.sv
../tb/top/tb_top.sv