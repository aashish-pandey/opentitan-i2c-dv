`ifndef TLUL_DRIVER_SV
`define TLUL_DRIVER_SV

class tlul_driver extends uvm_driver #(tlul_seq_item);

    `uvm_component_utils(tlul_driver)

    virtual tlul_if vif;

    function new(string name="tlul_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual tlul_if)::get(this, "", "tlul_vif", vif))
            `uvm_fatal("NO_VIF", "tlul_driver: no tlul_vif in config_db")
    endfunction

    task run_phase(uvm_phase phase);
        vif.driver_cb.h2d <= '0;
        vif.driver_cb.h2d.d_ready <= 1'b1;

        forever begin
            tlul_seq_item req;

            seq_item_port.get_next_item(req);

            if(req.rw == 1'b0)
                do_write(req);
            else
                do_read(req);
            
            seq_item_port.item_done();
        end
    endtask

    task do_write(tlul_seq_item req);
        tlul_pkg::tl_h2d_t beat; //local copy we will fill in before driving

        //step 1: Fill the A-channel
        beat                = '0;
        beat.a_valid        = 1'b1;
        beat.a_opcode       = tlul_pkg::PutFullData; //write opcode
        beat.a_size         = 2'h2;
        beat.a_source       ='0;
        beat.a_address      = req.addr;
        beat.a_mask         = req.mask;
        beat.a_data         = req.data;
        beat.d_ready        = 1'b1;


        //step 2: Compute and check integrity
        beat.a_user.cmd_intg    = tlul_pkg::get_cmd_intg(beat);
        beat.a_user.data_intg   = tlul_pkg::get_data_intg(beat);
        beat.a_user.instr_type  = prim_mubi_pkg::MuBi4False;

        //step3: Drive the filled struct onto the bus
        vif.driver_cb.h2d <= beat;

        //step4: Wait for DUT to accept the request (a_ready goes high)
        @(vif.driver_cb);
        while(!vif.driver_cb.d2h.a_ready)
            @(vif.driver_cb);

        //step5: Request accepted - de-assert a_valid so bus goes idle
        vif.driver_cb.h2d <= '0;
        vif.driver_cb.h2d.d_ready <= 1'b1;

        //step6: Wait for DUT to send the write acknowledgement
        @(vif.driver_cb);
        while(!vif.driver_cb.d2h.d_valid)
            @(vif.driver_cb);

        //Response received - one more cycle then we're done
        @(vif.driver_cb);


    endtask

    task do_read(tlul_seq_item req);

        tlul_pkg::tl_h2d_t beat;

        //step 1: Fill the A channel request fields
        beat                = '0;
        beat.a_valid        = 1'b1;
        beat.a_opcode       = tlul_pkg::Get; //read opcode
        beat.a_size         = 2'h2;
        beat.a_source       = '0;
        beat.a_address      = req.addr;
        beat.a_mask         = 4'b1111;
        beat.a_data         = '0;
        beat.d_ready        = 1'b1;

        //step 2: Integrity 
        beat.a_user.cmd_intg    = tlul_pkg::get_cmd_intg(beat);
        beat.a_user.data_intg   = tlul_pkg::get_data_intg(beat);
        beat.a_user.instr_type  = prim_mubi_pkg::MuBi4False;

        //step3: Driver
        vif.driver_cb.h2d <= beat;

        //step4: Wait for a_ready
        @(vif.driver_cb);
        while(!vif.driver_cb.d2h.a_ready)
            @(vif.driver_cb);
        
        //step5: deassert a_valid
        vif.driver_cb.h2d <= '0;
        vif.driver_cb.h2d.d_ready <= 1'b1;

        //step6: Wait for d_valid
        @(vif.driver_cb);
        while(!vif.driver_cb.d2h.d_valid)
            @(vif.driver_cb);

        //step7: capture the read data back into seq_item
        req.data = vif.driver_cb.d2h.d_data;

        @(vif.driver_cb);


    endtask

endclass

`endif