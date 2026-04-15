class i2c_seq_item extends uvm_sequence_item;

    rand logic [6:0] addr;
    rand logic rw;
    rand logic [7:0] data[];
    rand int unsigned num_bytes;
    rand logic no_stop;

    `uvm_object_utils_begin(i2c_seq_item)
        `uvm_field_int(addr, UVM_ALL_ON)
        `uvm_field_int(rw, UVM_ALL_ON)
        `uvm_field_array_int(data, UVM_ALL_ON)
        `uvm_field_int(num_bytes, UVM_ALL_ON)
        `uvm_field_int(no_stop, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="i2c_seq_item");
        super.new(name);
    endfunction

    constraint c_data_size {
        num_bytes inside {[1:16]};
        data.size() == num_bytes;
    }




endclass