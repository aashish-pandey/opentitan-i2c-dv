
interface i2c_if (input logic clk, input logic rst_n);

    // Open-drain bus nets — wand resolves to 0 if any driver pulls low
    wand scl;
    wand sda;

    // Per-driver contributions to the open-drain bus
    logic scl_host_drive   = 1'b1;  // driven by host driver via driver_cb
    logic sda_host_drive   = 1'b1;
    logic sda_target_drive = 1'b1;  // driven by target driver directly

    assign scl = scl_host_drive;
    assign sda = sda_host_drive;
    assign sda = sda_target_drive;

    logic intr_fmt_threshold;
    logic intr_rx_threshold;
    logic intr_acq_threshold;
    logic intr_rx_overflow;
    logic intr_controller_halt;
    logic intr_scl_interference;
    logic intr_sda_interference;
    logic intr_stretch_timeout;
    logic intr_sda_unstable;
    logic intr_cmd_complete;
    logic intr_tx_stretch;
    logic intr_tx_threshold;
    logic intr_acq_stretch;
    logic intr_unexp_stop;
    logic intr_host_timeout;

    // driver clocking block — drives named per-driver logics, not the wand net directly
    clocking driver_cb @(posedge clk);
        default input #1step output #2ns;
        output scl_host_drive;
        output sda_host_drive;
    endclocking

    // monitor clocking block — samples the resolved wand net
    clocking monitor_cb @(posedge clk);
        default input #1step;
        input scl;
        input sda;
    endclocking

    modport driver_mp (clocking driver_cb, input clk, input rst_n);
    modport monitor_mp(clocking monitor_cb, input clk, input rst_n);

endinterface
