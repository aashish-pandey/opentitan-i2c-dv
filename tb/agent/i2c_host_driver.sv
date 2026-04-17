import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_host_driver extends uvm_driver#(i2c_seq_item);

    `uvm_component_utils(i2c_host_driver)

    virtual i2c_if vif;

    function new(string name="i2c_host_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "No virtual interface found")
    endfunction

    task run_phase(uvm_phase phase);
        i2c_seq_item req;

        //release bus at start
        vif.driver_cb.scl_host_drive <= 1;
        vif.driver_cb.sda_host_drive <= 1;
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask

    task drive_transaction(i2c_seq_item req);
        send_start();
        send_byte({req.addr, req.rw});
        get_ack();
        foreach(req.data[i]) begin
            send_byte(req.data[i]);
            get_ack();
        end
        if(req.no_stop)send_repeated_start();
        else send_stop();

    endtask

    task send_start();

        //both high -idle
        vif.driver_cb.sda_host_drive <= 1;
        vif.driver_cb.scl_host_drive <= 1;
        repeat(10) @(vif.driver_cb);

        //SDA falls while SCL high - this is START condition
        vif.driver_cb.sda_host_drive <= 0;
        repeat(10) @(vif.driver_cb);

        //SCL falls - ready for first bit
        vif.driver_cb.scl_host_drive <= 0;
        repeat(10) @(vif.driver_cb);

    endtask

    task send_bit(logic val);
        vif.driver_cb.sda_host_drive <= val;
        repeat(10) @(vif.driver_cb);

        vif.driver_cb.scl_host_drive <= 1;
        repeat(10) @(vif.driver_cb);

        vif.driver_cb.scl_host_drive <= 0;
        repeat(10) @(vif.driver_cb);

    endtask

    task send_byte(logic [7:0] val);

        for(int i = 7; i >= 0; i--)begin
            send_bit(val[i]);
        end

    endtask

    task get_ack();

        vif.driver_cb.sda_host_drive <= 1;
        repeat(10) @(vif.driver_cb);

        vif.driver_cb.scl_host_drive <= 1;
        repeat(10) @(vif.driver_cb);

        // sample SDA - target should be pulling it low
        $display("[I2C_HOST @%0t] ACK sample: sda=%0b  scl=%0b  (expect sda=0 for ACK)",
                 $time, vif.monitor_cb.sda, vif.monitor_cb.scl);
        if(vif.monitor_cb.sda !== 1'b0)
            `uvm_warning("ACK", "NACK received or no response on SDA")

        vif.driver_cb.scl_host_drive <= 0;
        repeat(10) @(vif.driver_cb);

    endtask

    task send_stop();

        vif.driver_cb.sda_host_drive <= 0;
        repeat(10) @(vif.driver_cb);

        vif.driver_cb.scl_host_drive <= 1;
        repeat(10) @(vif.driver_cb);

        vif.driver_cb.sda_host_drive <= 1;
        repeat(10) @(vif.driver_cb);

    endtask

    task send_repeated_start();
        vif.driver_cb.sda_host_drive <= 1;
        repeat(10) @(vif.driver_cb);

        vif.driver_cb.scl_host_drive <= 1;
        repeat(10) @(vif.driver_cb);

        vif.driver_cb.sda_host_drive <= 0;
        repeat(10) @(vif.driver_cb);

        vif.driver_cb.scl_host_drive <= 0;
        repeat(10) @(vif.driver_cb);
    endtask

endclass