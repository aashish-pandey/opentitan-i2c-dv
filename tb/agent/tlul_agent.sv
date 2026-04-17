`ifndef TLUL_AGENT_SV
`define TLUL_AGENT_SV
class tlul_agent extends uvm_agent;

    `uvm_component_utils(tlul_agent);

    tlul_sequencer seq;
    tlul_driver drv;

    function new(string name="tlul_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);
        seq = tlul_sequencer::type_id::create("seq", this);
        drv = tlul_sequencer::type_id::create("drv", this);

    endfunction

    function void connect_phase(uvm_phase phase);
        drv.seq_item_port.connect(seq.seq_item_export);
    endfunction

endclass

`endif