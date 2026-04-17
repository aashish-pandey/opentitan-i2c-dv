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

        // Program timing registers before enabling the target.
        // Values match the host driver's repeat(10) phase granularity.
        // All fields must be > 2 for SCL transitions to propagate to the FSM.
        ral.timing0.thigh.set(10); ral.timing0.tlow.set(10);
        ral.timing0.update(status);

        ral.timing1.t_r.set(5); ral.timing1.t_f.set(3);
        ral.timing1.update(status);

        ral.timing2.tsu_sta.set(10); ral.timing2.thd_sta.set(10);
        ral.timing2.update(status);

        ral.timing3.tsu_dat.set(5); ral.timing3.thd_dat.set(5);
        ral.timing3.update(status);

        ral.timing4.tsu_sto.set(10); ral.timing4.t_buf.set(10);
        ral.timing4.update(status);

        read_reg_verbose("TIMING3 after config", ral.timing3, raw);
        `uvm_info("VSEQ", $sformatf("  -> tsu_dat=%0d  thd_dat=%0d",
                  raw[8:0], raw[28:16]), UVM_NONE)

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
        // thd_dat = bits [28:16] (13-bit), tsu_dat = bits [8:0] (9-bit) per spec.
        // If thd_dat=0 the counter wraps to 65k and the host raises SCL first
        // (in ~20 cycles) causing the "SCL too fast" abandon.
        read_reg_verbose("TIMING3 (offset 0x48)", ral.timing3, raw);
        `uvm_info("VSEQ", $sformatf("  -> tsu_dat (bits[8:0]) = %0d   thd_dat (bits[28:16]) = %0d",
                  raw[8:0], raw[28:16]), UVM_NONE)

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
            read_reg_verbose("STATUS post-txn", ral.status, raw);
            `uvm_info("VSEQ", $sformatf("  -> targetidle=%0b  acqempty=%0b  acqfull=%0b",
                      raw[4], raw[9], raw[7]), UVM_NONE)

            // acqlvl = bits [27:16] (12-bit), txlvl = bits [11:0] per spec.
            read_reg_verbose("TARGET_FIFO_STATUS post-txn", ral.target_fifo_status, raw);
            `uvm_info("VSEQ", $sformatf("  -> acqlvl (bits[27:16])=%0d   txlvl (bits[11:0])=%0d",
                      raw[27:16], raw[11:0]), UVM_NONE)

            // Drain ACQ FIFO so it never fills and forces NACKs on future transactions.
            begin
                uvm_reg_data_t acq_entry;
                int unsigned lvl = raw[27:16];
                repeat (lvl) begin
                    ral.acqdata.read(status, acq_entry, UVM_FRONTDOOR);
                    `uvm_info("VSEQ", $sformatf("  -> drained ACQDATA=0x%02h", acq_entry[7:0]), UVM_NONE)
                end
            end
        end

        `uvm_info("VSEQ", "=== All 5 transactions done ===", UVM_NONE)

    endtask

endclass
