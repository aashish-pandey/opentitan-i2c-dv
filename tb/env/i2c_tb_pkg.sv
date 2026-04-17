package i2c_tb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "i2c_reg_block.sv"
    `include "i2c_seq_item.sv"
    `include "i2c_agent_cfg.sv"
    `include "i2c_sequencer.sv"
    `include "i2c_host_driver.sv"
    `include "i2c_target_driver.sv"
    `include "i2c_monitor.sv"
    `include "i2c_agent.sv"
    `include "i2c_scoreboard.sv"
    `include "i2c_intr_checker.sv"
    `include "i2c_env.sv"
    `include "i2c_coverage.sv"
    `include "i2c_host_smoke_vseq.sv"
    `include "i2c_base_test.sv"
    `include "i2c_smoke_test.sv"
endpackage