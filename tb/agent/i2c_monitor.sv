import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_monitor extends uvm_monitor;
    `uvm_component_utils(i2c_monitor)

    uvm_analysis_port #(i2c_seq_item) ap;

    virtual i2c_if vif;

    function new(string name="i2c_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "No interface handle found")
        ap = new("ap", this);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            observe_transaction();
        end
    endtask

    task observe_transaction();
        logic [7:0] address_rw;
        logic [6:0] addr;
        logic rw;
        logic [7:0] d1;
        logic [7:0] data[$];
        logic stop_detected;
        i2c_seq_item req;
        req = i2c_seq_item::type_id::create("req");
        stop_detected = 0;
        wait_for_start();

        receive_byte(address_rw);
        addr = address_rw[7:1];
        rw = address_rw[0];

        //sampling the ack bit
        @(posedge vif.scl);
        @(negedge vif.scl);

        req.addr = addr;
        req.rw = rw;

        forever begin
            fork 
                begin: stop_check
                    @(posedge vif.sda);
                    if(vif.scl == 1) stop_detected = 1;
                end
                begin : bit_check
                    @(negedge vif.scl);
                end
            join_any
            disable fork;

            if(stop_detected)
                break;
            receive_byte(d1);
            data.push_back(d1);

            //sample ack
            @(posedge vif.scl);
            @(negedge vif.scl);
        end

        req.data = data;
        ap.write(req);
        
    endtask



    task wait_for_start();
        forever begin
            @(negedge vif.sda);
            if(vif.scl == 1)
                return;
        end
    endtask
    task receive_bit(output logic val);
        @(posedge vif.scl);
        val = vif.sda;
        @(negedge vif.scl);

    endtask
    task receive_byte(output logic [7:0] val);
        for(int i = 7; i >= 0; i--)begin
            receive_bit(val[i]);
        end
    endtask

    task wait_for_stop();
        forever begin
            @(posedge vif.sda);
            if(vif.scl == 1)
                return;
        end
    endtask


endclass