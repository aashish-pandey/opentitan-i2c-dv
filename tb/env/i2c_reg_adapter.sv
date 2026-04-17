class i2c_reg_adapter extends uvm_reg_adapter;

    `uvm_object_utils(i2c_reg_adapter)

    function new(string name="i2c_reg_adapter");
        super.new(name);
    endfunction

    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

        i2c_seq_item item = i2c_seq_item::type_id::create("item");
        item.rw = (rw.kind == UVM_WRITE) ? 0 : 1;
        item.addr = rw.addr;
        item.data = new[1];
        item.data[0] = rw.data[7:0];
        return item;

    endfunction

    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

        i2c_seq_item item;
        $cast(item, bus_item);
        rw.kind = item.rw ? UVM_READ : UVM_WRITE;
        rw.addr = item.addr;
        rw.data = (item.data.size() > 0) ? item.data[0] : 0;
        rw.status = UVM_IS_OK;

    endfunction

endclass