import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_target_driver extends uvm_driver #(i2c_seq_item);

    `uvm_component_utils(i2c_target_driver)

    virtual i2c_if vif;
    logic [6:0] target_addr;

    function new(string name="i2c_target_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "No interface handler found")
        if(!uvm_config_db #(logic [6:0])::get(this, "", "target_addr", target_addr))
            target_addr = 7'h55; //default address
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            drive_transaction();
        end
    endtask

    task drive_transaction();
        logic [7:0] addr_bytes;
        logic [6:0] address;
        logic rw;
        logic got_stop;
        got_stop = 0;

        //wait for host to start
        wait_for_start();

        //receive address byte
        addr_bytes = receive_byte();
        address = addr_bytes[7:1];
        rw = addr_bytes[0];

        //check if addressed to this
        if(address != target_addr) begin
            send_nack();
            return;
        end
        
        send_ack();
        
        //handle read or write
        if(rw == 0)begin
            //write - host sends dataa, we ACK each byte
            //loop until stop detected
            while(!got_stop)begin
                receive_byte();
                send_ack();

                @(posedge vif.scl);
                if(vif.sda == 1)got_stop = 1;
            end
        end
        else begin
            //read - we send data, host acks
            // TODO Week 3 - read data driven via read_data_q
            wait_for_stop();
            return;
        end


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

        val <= vif.sda;

        @(negedge vif.scl);
        

    endtask

    task receive_byte(output logic [7:0] val);

        for(int i = 7; i >= 0; i--)begin
            receive_bit(val[i]);
        end

    endtask

    task send_ack();

        vif.sda <= 0;

        @(posedge vif.scl);

        @(negedge vif.scl);

        vif.sda <= 1;


    endtask

    task send_nack();
        vif.sda <= 1;
        @(posedge vif.scl);

        @(negedge vif.scl);
    endtask

    task send_bit_target(logic val);

        vif.sda <= val;

        @(posedge vif.scl);
        @(negedge vif.scl);


    endtask

    task wait_for_stop();
        forever begin
            @(posedge vif.sda);
            if(vif.scl == 1)
                return;
        end
    endtask


endclass