import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_host_smoke_vseq extends uvm_sequence #(i2c_seq_item);
    `uvm_object_utils(i2c_host_smoke_vseq)

    i2c_reg_block ral;

    function new(string name="i2c_host_smoke_vseq");
        super.new(name);
    endfunction

    localparam logic [6:0] TARGET_ADDR = 7'h55;

    // Helper: read one register and print a labelled line.
    // Also prints the raw 32-bit value so field-position bugs are visible.
    task read_reg_verbose(string label, uvm_reg reg_h, output uvm_reg_data_t raw);
        uvm_status_e st;
        reg_h.read(st, raw, UVM_FRONTDOOR);
        `uvm_info("VSEQ", $sformatf("[%s] raw=0x%08h  status=%s", label, raw, st.name()), UVM_NONE)
    endtask

    task body();

        i2c_seq_item   item;
        uvm_status_e   status;
        uvm_reg_data_t raw;
        int            txn_num;

        // Get the RAL handle.
        if (!uvm_config_db #(i2c_reg_block)::get(null, "", "ral", ral))
            `uvm_fatal("VSEQ", "No RAL found")

        // ----------------------------------------------------------------
        // Step 1 -- Configure DUT as I2C TARGET via TLUL
        // ----------------------------------------------------------------
        `uvm_info("VSEQ", "=== PHASE 1: TLUL register setup ===", UVM_NONE)

        ral.ctrl.enabletarget.set(1);
        ral.ctrl.update(status);
        read_reg_verbose("CTRL readback", ral.ctrl, raw);
        // enabletarget is bit 1; if bit 1 is set, DUT is in target mode
        `uvm_info("VSEQ", $sformatf("  -> enabletarget (bit1) = %0b", raw[1]), UVM_NONE)

        ral.target_id.address0.set(TARGET_ADDR);
        ral.target_id.mask0.set(7'h7F);
        ral.target_id.update(status);
        read_reg_verbose("TARGET_ID readback", ral.target_id, raw);
        // address0 = bits[6:0], mask0 = bits[13:7]
        `uvm_info("VSEQ", $sformatf("  -> address0 (bits[6:0]) = 0x%0h  mask0 (bits[13:7]) = 0x%0h",
                  raw[6:0], raw[13:7]), UVM_NONE)

        // Read TIMING3 to confirm thd_dat -- this is the hold timer the DUT
        // uses in AcquireAckWait/AddrAckWait.
        // thd_dat = bits [21:9] (13-bit) per RAL model.
        // If thd_dat=0 the counter wraps to 65k and the host raises SCL first
        // (in ~20 cycles) causing the "SCL too fast" abandon.
        read_reg_verbose("TIMING3 (offset 0x48)", ral.timing3, raw);
        `uvm_info("VSEQ", $sformatf("  -> tsu_dat (bits[8:0]) = %0d   thd_dat (bits[21:9]) = %0d",
                  raw[8:0], raw[21:9]), UVM_NONE)

        // Read STATUS to confirm DUT is idle and ACQ FIFO is empty before start.
        read_reg_verbose("STATUS pre-tx", ral.status, raw);
        `uvm_info("VSEQ", $sformatf("  -> targetidle=%0b  acqempty=%0b  acqfull=%0b",
                  raw[4], raw[9], raw[7]), UVM_NONE)

        // ----------------------------------------------------------------
        // Step 2 -- Send write transactions
        // ----------------------------------------------------------------
        `uvm_info("VSEQ", "=== PHASE 2: I2C write transactions ===", UVM_NONE)

        txn_num = 0;
        repeat(5) begin
            txn_num++;
            item = i2c_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with {
                item.rw   == 1'b0;
                item.addr == TARGET_ADDR;
            })
                `uvm_fatal("VSEQ", "Randomization failed")
            `uvm_info("VSEQ", $sformatf("--- TXN %0d: WRITE addr=0x%0h  data=%0p",
                      txn_num, item.addr, item.data), UVM_NONE)
            finish_item(item);

            // After each I2C transaction: read STATUS and FIFO status.
            // STATUS.targetidle should be 1 (DUT went back to idle after NACK/WaitForStop).
            // FIFO status raw value: acqlvl is at bits [24:16] in hardware (9-bit field),
            // NOT at bits [23:12] as the hand-written RAL says.
            // Decoding from raw manually to get the true count.
            read_reg_verbose("STATUS post-txn", ral.status, raw);
            `uvm_info("VSEQ", $sformatf("  -> targetidle=%0b  acqempty=%0b  acqfull=%0b",
                      raw[4], raw[9], raw[7]), UVM_NONE)

            read_reg_verbose("TARGET_FIFO_STATUS post-txn", ral.target_fifo_status, raw);
            `uvm_info("VSEQ", $sformatf("  -> RAL acqlvl (bits[23:12])=%0d   RAW acqlvl (bits[24:16])=%0d",
                      raw[23:12], raw[24:16]), UVM_NONE)
        end

        `uvm_info("VSEQ", "=== All 5 transactions done ===", UVM_NONE)

    endtask

endclass
