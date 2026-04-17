import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_host_smoke_vseq extends uvm_sequence #(i2c_seq_item);
    `uvm_object_utils(i2c_host_smoke_vseq)

    i2c_reg_block ral;

    function new(string name="i2c_host_smoke_vseq");
        super.new(name);
    endfunction

    // Fixed target address — must match what the DUT is configured with below
    // and must match the UVM target driver's default (7'h55).
    localparam logic [6:0] TARGET_ADDR = 7'h55;

    task body();

        i2c_seq_item item;
        uvm_status_e status;

        // Get the RAL handle that was put into config_db by the env.
        if (!uvm_config_db #(i2c_reg_block)::get(null, "", "ral", ral))
            `uvm_fatal("VSEQ", "No RAL found")

        // ----------------------------------------------------------------
        // Step 1 — Configure DUT as I2C TARGET via TLUL
        //
        // Previously this set enablehost=1 which made the DUT try to drive
        // SCL as an I2C master — fighting with our UVM host driver on the bus.
        //
        // Correct topology:
        //   UVM host driver  = external I2C master  (drives SCL/SDA)
        //   DUT              = I2C target (slave)    (responds with ACK)
        // ----------------------------------------------------------------

        // Enable target mode in the DUT.
        ral.ctrl.enabletarget.set(1);
        ral.ctrl.update(status);

        // Program the DUT's target address and mask.
        //   address0 = 7'h55  — the 7-bit I2C address the DUT will respond to
        //   mask0    = 7'h7F  — all 7 bits must match exactly (full address match)
        ral.target_id.address0.set(TARGET_ADDR);
        ral.target_id.mask0.set(7'h7F);
        ral.target_id.update(status);

        // ----------------------------------------------------------------
        // Step 2 — Send write transactions to the DUT's target address
        //
        // addr is constrained to TARGET_ADDR so the DUT actually ACKs.
        // Previously addr was fully random — almost never hit the DUT's
        // address — causing 81 NACK warnings.
        // ----------------------------------------------------------------
        repeat(5) begin
            item = i2c_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                item.rw   == 1'b0;          // write
                item.addr == TARGET_ADDR;   // must match DUT's target_id
            })
                `uvm_fatal("VSEQ", "Randomization failed")
            finish_item(item);
        end

    endtask

endclass