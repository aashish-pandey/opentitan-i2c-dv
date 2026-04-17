// i2c_reg_adapter.sv
//
// This adapter is the bridge between the UVM Register Abstraction Layer (RAL)
// and the TLUL agent that physically drives the bus.
//
// The RAL works at an abstract level — it just says "write value X to register Y".
// The adapter's job is to translate that abstract operation into a concrete
// tlul_seq_item that the tlul_driver knows how to put on the TL-UL bus.
//
// Two functions do this translation:
//   reg2bus  : RAL → tlul_seq_item   (called before the transaction)
//   bus2reg  : tlul_seq_item → RAL   (called after the transaction, updates the mirror)

class i2c_reg_adapter extends uvm_reg_adapter;

    `uvm_object_utils(i2c_reg_adapter)

    function new(string name = "i2c_reg_adapter");
        super.new(name);
    endfunction

    // -------------------------------------------------------------------------
    // reg2bus
    // -------------------------------------------------------------------------
    // The RAL calls this to convert an abstract register operation into a
    // bus transaction item. We create a tlul_seq_item and fill its fields
    // from the uvm_reg_bus_op struct that the RAL hands us.
    //
    // uvm_reg_bus_op fields we care about:
    //   rw.kind    : UVM_WRITE or UVM_READ
    //   rw.addr    : byte address of the register (comes from the reg map offset)
    //   rw.data    : 32-bit value to write (ignored for reads)
    //   rw.n_bits  : number of bits in the register (we always use 32)

    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

        tlul_seq_item item = tlul_seq_item::type_id::create("item");

        // rw = 0 means write, rw = 1 means read — matches our seq_item convention.
        item.rw   = (rw.kind == UVM_WRITE) ? 1'b0 : 1'b1;

        // The register byte address from the RAL map goes directly to a_address.
        // This is the fix — before, this was being used as an I2C device address!
        item.addr = rw.addr;

        // Full 32-bit write data from the RAL.
        // Before, only data[7:0] was used — that was also wrong.
        item.data = rw.data;

        // Full word access — all 4 bytes active.
        item.mask = 4'b1111;

        return item;

    endfunction

    // -------------------------------------------------------------------------
    // bus2reg
    // -------------------------------------------------------------------------
    // The RAL calls this after the driver completes the transaction to update
    // its internal mirror with the actual data that came back from the DUT.
    //
    // For writes: the DUT just sends an AccessAck with no data — we confirm OK.
    // For reads:  the driver captured d2h.d_data into item.data — we hand it back.

    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

        tlul_seq_item item;

        // Cast the generic bus_item back to our specific tlul_seq_item type.
        if (!$cast(item, bus_item))
            `uvm_fatal("REG_ADAPTER", "bus2reg: failed to cast to tlul_seq_item")

        rw.kind   = item.rw ? UVM_READ : UVM_WRITE;
        rw.addr   = item.addr;

        // For reads, item.data was populated by the driver from d2h.d_data.
        // For writes, the RAL ignores this value, so it doesn't matter.
        rw.data   = item.data;

        // Tell the RAL the transaction completed without a bus error.
        rw.status = UVM_IS_OK;

    endfunction

endclass