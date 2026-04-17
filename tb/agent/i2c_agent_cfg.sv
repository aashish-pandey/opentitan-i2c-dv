import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_agent_cfg extends uvm_object;

    `uvm_object_utils(i2c_agent_cfg)

    uvm_active_passive_enum is_active = UVM_ACTIVE;
    logic [6:0] target_addr = 7'h55;
    typedef enum {HOST, TARGET} i2c_mode_e;
    i2c_mode_e mode = HOST;

    function new(string name="i2c_agent_cfg");
        super.new(name);
    endfunction

endclass