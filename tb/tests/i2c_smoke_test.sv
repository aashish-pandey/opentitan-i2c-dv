import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_smoke_test extends i2c_base_test;

    `uvm_component_utils(i2c_smoke_test)

    function new(string name="i2c_smoke_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        i2c_host_smoke_vseq vseq;
        virtual i2c_if vif;
        phase.raise_objection(this);

        // Wait for reset to deassert before touching any bus.
        // Without this the TLUL driver fires ral.ctrl.update() while rst_ni=0,
        // the DUT never asserts a_ready, and the driver loops forever.
        void'(uvm_config_db #(virtual i2c_if)::get(null, "uvm_test_top.*", "vif", vif));
        @(posedge vif.rst_n);
        repeat(5) @(posedge vif.clk); // a few extra cycles for DUT to settle

        vseq = i2c_host_smoke_vseq::type_id::create("vseq");
        vseq.start(env.host_agent.seq);
        phase.drop_objection(this);
    endtask

endclass