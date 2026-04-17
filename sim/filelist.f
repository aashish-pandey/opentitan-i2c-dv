// Stub packages (only what's not in prim)
../tb/top/stub_pkgs.sv

// PRIM
../prim/rtl/prim_util_pkg.sv
../prim/rtl/prim_mubi_pkg.sv
../prim/rtl/prim_subreg_pkg.sv
../prim/rtl/prim_pkg.sv
../prim/rtl/prim_assert.sv
../prim/rtl/prim_count_pkg.sv
../prim/rtl/prim_secded_pkg.sv
../prim/rtl/prim_alert_pkg.sv
../prim/rtl/prim_esc_pkg.sv
../prim/rtl/prim_subreg.sv
../prim/rtl/prim_subreg_arb.sv
../prim/rtl/prim_subreg_ext.sv
../prim/rtl/prim_subreg_shadow.sv
../prim/rtl/prim_reg_we_check.sv
../prim/rtl/prim_intr_hw.sv
../prim/rtl/prim_fifo_sync.sv
../prim/rtl/prim_fifo_sync_cnt.sv
../prim/rtl/prim_arbiter_tree.sv
../prim/rtl/prim_ram_1p_adv.sv

//prim_generic
../prim_generic/rtl/prim_buf.sv
../prim_generic/rtl/prim_flop.sv
../prim_generic/rtl/prim_flop_2sync.sv
../prim/rtl/prim_onehot_check.sv
../prim/rtl/prim_secded_inv_64_57_enc.sv
../prim/rtl/prim_secded_inv_64_57_dec.sv
../prim/rtl/prim_secded_inv_39_32_dec.sv

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
../tb/top/tb_top.sv