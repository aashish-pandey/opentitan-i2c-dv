`ifndef TLUL_SEQ_ITEM_SV
`define TLUL_SEQ_ITEM_SV

class tlul_seq_item extends uvm_sequence_item;

    `uvm_object_utils(tlul_seq_item);

    rand logic [31:0] addr;

    rand logic rw;

    rand logic [31:0] data;
    rand logic [3:0] mask;

    constraint c_full_word (mask == 4'b1111; )

    function new(string name="tlul_seq_item");
        super.new(name);
    endfunction



endclass


`endif


/*
NOTE
1. The reg adapter will create this item when the RAL calls reg2bus. It fills in addre form the 
register offset and data from the value to write
2. mask = 4'b1111 is the constraint for now because all your registers are 32 bit and we always do full word writes

*/