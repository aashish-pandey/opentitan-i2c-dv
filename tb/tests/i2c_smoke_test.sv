import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_smoke_test extends i2c_base_test;

    `uvm_component_utils(i2c_smoke_test)

    function new(string name="i2c_smoke_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        i2c_host_smoke_vseq vseq;
        phase.raise_objection(this);
        vseq = i2c_host_smoke_vseq::type_id::create("vseq");
        vseq.start(env.host_agent.seq);
        phase.drop_objection(this);
    endtask

endclass