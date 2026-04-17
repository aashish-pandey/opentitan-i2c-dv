import uvm_pkg::*;
`include "uvm_macros.svh"
import i2c_tb_pkg::*;
`timescale 1ns/1ps

module tb_top;

    //clock and reset
    logic clk;
    logic rst_n;

    //clock generator -50MHZ
    initial clk = 0;
    always #10 clk = ~clk;

    //reset generation
    initial begin
        rst_n = 0;
        repeat(5) @(posedge clk);
        rst_n = 1;
    end

    //interface instantiation
    i2c_if dut_if (.clk(clk), .rst_n(rst_n));

    //others
    prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_i;
    prim_ram_1p_pkg::ram_1p_cfg_rsp_t ram_cfg_rsp_o;

    //tie-off signals : Bus Interface
    tlul_pkg::tl_h2d_t tl_i;
    tlul_pkg::tl_d2h_t tl_o;

    //Alerts
    prim_alert_pkg::alert_rx_t [i2c_reg_pkg::NumAlerts-1:0] alert_rx_i;
    prim_alert_pkg::alert_tx_t [i2c_reg_pkg::NumAlerts-1:0] alert_tx_o;

    //RACL interface
    top_racl_pkg::racl_policy_vec_t racl_policies_i;
    top_racl_pkg::racl_error_log_t racl_error_o;

    //Generic IO
    logic cio_scl_o;
    logic cio_scl_en_o;
    logic cio_sda_o;
    logic cio_sda_en_o;
    logic lsio_trigger_o;

    assign dut_if.scl = (cio_scl_en_o) ? cio_scl_o : 1'b1;
    assign dut_if.sda = (cio_sda_en_o) ? cio_sda_o : 1'b1;
    assign ram_cfg_i = 'b0;
    assign alert_rx_i = 'b0;
    assign racl_policies_i = 'b0;
    assign tl_i = 'b0;


    //DUT instantiation
    i2c dut(
        .clk_i                  (clk),
        .rst_ni                 (rst_n),
        .ram_cfg_i              (ram_cfg_i),
        .ram_cfg_rsp_o          (ram_cfg_rsp_o),

        .tl_i                   (tl_i),
        .tl_o                   (tl_o),

        .alert_rx_i             (alert_rx_i),
        .alert_tx_o             (alert_tx_o),

        .racl_policies_i        (racl_policies_i),
        .racl_error_o           (racl_error_o),

        .cio_scl_i              (dut_if.scl),
        .cio_scl_o              (cio_scl_o),
        .cio_scl_en_o           (cio_scl_en_o),
        .cio_sda_i              (dut_if.sda),
        .cio_sda_o              (cio_sda_o),
        .cio_sda_en_o           (cio_sda_en_o),

        .lsio_trigger_o         (lsio_trigger_o),

        .intr_fmt_threshold_o   (dut_if.intr_fmt_threshold),
        .intr_rx_threshold_o    (dut_if.intr_rx_threshold),
        .intr_acq_threshold_o   (dut_if.intr_acq_threshold),
        .intr_rx_overflow_o     (dut_if.intr_rx_overflow),
        .intr_controller_halt_o (dut_if.intr_controller_halt),
        .intr_scl_interference_o(dut_if.intr_scl_interference),
        .intr_sda_interference_o(dut_if.intr_sda_interference),
        .intr_stretch_timeout_o (dut_if.intr_stretch_timeout),
        .intr_sda_unstable_o    (dut_if.intr_sda_unstable),
        .intr_cmd_complete_o    (dut_if.intr_cmd_complete),
        .intr_tx_stretch_o      (dut_if.intr_tx_stretch),
        .intr_tx_threshold_o    (dut_if.intr_tx_threshold),
        .intr_acq_stretch_o     (dut_if.intr_acq_stretch),
        .intr_unexp_stop_o      (dut_if.intr_unexp_stop),
        .intr_host_timeout_o    (dut_if.intr_host_timeout)

    );



    //register interface in config_db and run test
    initial begin
        uvm_config_db #(virtual i2c_if)::set(null, "uvm_test_top.*", "vif", dut_if);
        run_test();
    end

endmodule