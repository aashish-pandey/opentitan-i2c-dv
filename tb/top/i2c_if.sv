
interface i2c_if (input logic clk, input logic rst_n);

    // wand scl;
    // wand sda;

    // pullup(scl); //Passive pullup - overridden by any driver asserting 0
    // pullup(sda); //Passive pullup - overridden by any driver asserting 0
    wire scl_pull = 1'b1;
    wire sda_pull = 1'b1;
    assign scl = scl_pull;
    assign sda = sda_pull;
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

    //driver clocking block
    clocking driver_cb @(posedge clk);

        default input #1step output #2ns;
        output scl;
        output sda;

    endclocking

    //monitor clocking block
    clocking monitor_cb @(posedge clk);
        default input #1step;

        input scl;
        input sda;

    endclocking

    //modports
    modport driver_mp (clocking driver_cb, input clk, input rst_n);
    modport monitor_mp(clocking monitor_cb, input clk, input rst_n);

endinterface