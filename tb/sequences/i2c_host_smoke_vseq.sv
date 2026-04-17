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
        `uvm_info("VSEQ", "Writing CTRL.enabletarget=1 via TLUL...", UVM_NONE)
        ral.ctrl.enabletarget.set(1);
        ral.ctrl.update(status);
        `uvm_info("VSEQ", $sformatf("CTRL update done — status=%s  ctrl_mirror=0x%0h",
                  status.name(), ral.ctrl.get_mirrored_value()), UVM_NONE)

        // Program the DUT's target address and mask.
        //   address0 = 7'h55  — the 7-bit I2C address the DUT will respond to
        //   mask0    = 7'h7F  — all 7 bits must match exactly (full address match)
        `uvm_info("VSEQ", "Writing TARGET_ID.address0=0x55 mask0=0x7F via TLUL...", UVM_NONE)
        ral.target_id.address0.set(TARGET_ADDR);
        ral.target_id.mask0.set(7'h7F);
        ral.target_id.update(status);
        `uvm_info("VSEQ", $sformatf("TARGET_ID update done — status=%s  target_id_mirror=0x%0h",
                  status.name(), ral.target_id.get_mirrored_value()), UVM_NONE)

        // ----------------------------------------------------------------
        // Step 2 — Send write transactions to the DUT's target address
        //
        // addr is constrained to TARGET_ADDR so the DUT actually ACKs.
        // Previously addr was fully random — almost never hit the DUT's
        // address — causing 81 NACK warnings.
        // ----------------------------------------------------------------
        // Read FIFO status before transactions start — should show acqlvl=0
        ral.target_fifo_status.read(status, , UVM_FRONTDOOR);
        `uvm_info("VSEQ", $sformatf("PRE-TX target_fifo_status: acqlvl=%0d  txlvl=%0d",
                  ral.target_fifo_status.acqlvl.get_mirrored_value(),
                  ral.target_fifo_status.txlvl.get_mirrored_value()), UVM_NONE)

        `uvm_info("VSEQ", "Starting 5 I2C write transactions to address 0x55...", UVM_NONE)
        repeat(5) begin
            item = i2c_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                item.rw   == 1'b0;
                item.addr == TARGET_ADDR;
            })
                `uvm_fatal("VSEQ", "Randomization failed")
            `uvm_info("VSEQ", $sformatf("Sending I2C WRITE  addr=0x%0h  data=%0p",
                      item.addr, item.data), UVM_NONE)
            finish_item(item);

            // Read ACQ FIFO level after each transaction — if NACKs = FIFO full, acqlvl should grow
            ral.target_fifo_status.read(status, , UVM_FRONTDOOR);
            `uvm_info("VSEQ", $sformatf("POST-TX target_fifo_status: acqlvl=%0d  txlvl=%0d  (status=%s)",
                      ral.target_fifo_status.acqlvl.get_mirrored_value(),
                      ral.target_fifo_status.txlvl.get_mirrored_value(),
                      status.name()), UVM_NONE)
        end
        `uvm_info("VSEQ", "All 5 I2C transactions dispatched.", UVM_NONE)

    endtask

endclass