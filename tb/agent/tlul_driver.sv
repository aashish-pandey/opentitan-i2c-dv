`ifndef TLUL_DRIVER_SV
`define TLUL_DRIVER_SV

class tlul_driver extends uvm_driver #(tlul_seq_item);

    `uvm_component_utils(tlul_driver)

    virtual tlul_if vif;

    function new(string name = "tlul_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual tlul_if)::get(this, "", "tlul_vif", vif))
            `uvm_fatal("NO_VIF", "tlul_driver: no tlul_vif in config_db")
    endfunction

    // -------------------------------------------------------------------------
    // run_phase
    // -------------------------------------------------------------------------
    // NOTE: We drive vif.h2d and sample vif.d2h DIRECTLY (not through the
    // clocking block). Xcelium does not reliably support packed struct member
    // access through clocking block variables (e.g. vif.driver_cb.d2h.a_ready).
    // Using direct access + @(posedge vif.clk) is equivalent and always works.
    // -------------------------------------------------------------------------
    task run_phase(uvm_phase phase);

        // Idle state: no request pending, always ready to accept a response.
        vif.h2d <= '0;
        vif.h2d.d_ready <= 1'b1;

        forever begin
            tlul_seq_item req;
            seq_item_port.get_next_item(req);

            if (req.rw == 1'b0)
                do_write(req);
            else
                do_read(req);

            seq_item_port.item_done();
        end

    endtask

    // -------------------------------------------------------------------------
    // do_write
    // -------------------------------------------------------------------------
    task do_write(tlul_seq_item req);
        tlul_pkg::tl_h2d_t beat;

        // Step 1: Fill A-channel fields.
        beat           = '0;
        beat.a_valid   = 1'b1;
        beat.a_opcode  = tlul_pkg::PutFullData;
        beat.a_size    = 2'h2;          // 4 bytes
        beat.a_source  = '0;
        beat.a_address = req.addr;
        beat.a_mask    = req.mask;
        beat.a_data    = req.data;
        beat.d_ready   = 1'b1;

        // Step 2: Set instr_type FIRST, then compute integrity.
        // get_cmd_intg hashes instr_type — if it's wrong the DUT flags an
        // integrity error and may block a_ready.
        beat.a_user.instr_type = prim_mubi_pkg::MuBi4False;
        beat.a_user.cmd_intg   = tlul_pkg::get_cmd_intg(beat);
        beat.a_user.data_intg  = tlul_pkg::get_data_intg(beat.a_data); // pass data, not the whole struct

        // Step 3: Drive onto the bus.
        @(posedge vif.clk);
        vif.h2d <= beat;

        // Step 4: Wait for DUT to assert a_ready (handshake on A-channel).
        @(posedge vif.clk);
        while (!vif.d2h.a_ready)
            @(posedge vif.clk);

        // Step 5: De-assert a_valid — request was accepted.
        vif.h2d       <= '0;
        vif.h2d.d_ready <= 1'b1;

        // Step 6: Wait for DUT to assert d_valid (write acknowledgement).
        @(posedge vif.clk);
        while (!vif.d2h.d_valid)
            @(posedge vif.clk);

        @(posedge vif.clk);

    endtask

    // -------------------------------------------------------------------------
    // do_read
    // -------------------------------------------------------------------------
    task do_read(tlul_seq_item req);
        tlul_pkg::tl_h2d_t beat;

        beat           = '0;
        beat.a_valid   = 1'b1;
        beat.a_opcode  = tlul_pkg::Get;
        beat.a_size    = 2'h2;
        beat.a_source  = '0;
        beat.a_address = req.addr;
        beat.a_mask    = 4'b1111;
        beat.a_data    = '0;
        beat.d_ready   = 1'b1;

        beat.a_user.instr_type = prim_mubi_pkg::MuBi4False;
        beat.a_user.cmd_intg   = tlul_pkg::get_cmd_intg(beat);
        beat.a_user.data_intg  = tlul_pkg::get_data_intg(beat.a_data);

        @(posedge vif.clk);
        vif.h2d <= beat;

        @(posedge vif.clk);
        while (!vif.d2h.a_ready)
            @(posedge vif.clk);

        vif.h2d         <= '0;
        vif.h2d.d_ready <= 1'b1;

        @(posedge vif.clk);
        while (!vif.d2h.d_valid)
            @(posedge vif.clk);

        // Capture read data back into the item so bus2reg can update the RAL mirror.
        req.data = vif.d2h.d_data;

        @(posedge vif.clk);

    endtask

endclass

`endif