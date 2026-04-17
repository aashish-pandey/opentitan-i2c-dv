`ifndef TLUL_SEQUENCER_SV
`define TLUL_SEQUENCER_SV

class tlul_sequencer extends uvm_sequencer #(tlul_seq_item);

    `uvm_component_utils(tlul_sequencer)

    function new(string name="tlul_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

    

endclass

`endif