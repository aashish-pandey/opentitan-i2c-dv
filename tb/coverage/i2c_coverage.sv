import uvm_pkg::*;
`include "uvm_macros.svh"

covergroup i2c_operating_mode_cg(ref i2c_agent_cfg::i2c_mode_e _mode, ref logic _rw);
    cp_mode: coverpoint _mode {
        bins host   = {HOST};
        bins target = {TARGET};
    }
    cp_rw: coverpoint _rw {
        bins read  = {1};
        bins write = {0};
    }
    cx_mode_rw: cross cp_mode, cp_rw;
endgroup

covergroup i2c_rd_wr_cg(ref i2c_agent_cfg::i2c_mode_e _mode, ref logic _rw);
    cp_addr: coverpoint addr{
        option.auto_bin_max = 4;
    }
    cp_rw: coverpoint rw{
        bins read = {1};
        bins write = {0};

    }
    cx_addr_rw: cross cp_addr, cp_rw;
endgroup

covergroup i2c_interrupts_cg(virtual i2c_if vif, ref i2c_agent_cfg::i2c_mode_e _mode, ref logic _rw);

    cp_fmt_threshold: coverpoint vif.intr_fmt_threshold{
        bins fired = {1};
        bins not_fired = {0};
    }
    cp_rx_threshold: coverpoint vif.intr_rx_threshold{
        bins fired = {1};
        bins not_fired = {0};
    }   
    cp_cmd_complete: coverpoint vif.intr_cmd_complete{
        bins fired = {1};
        bins not_fired = {0};
    }   
    cp_rx_overflow: coverpoint vif.intr_rx_overflow{
        bins fired = {1};
        bins not_fired = {0};
    }
endgroup

covergroup i2c_fifo_level_cg(ref i2c_agent_cfg::i2c_mode_e _mode, ref logic _rw);

    cp_num_bytes: coverpoint num_bytes{
        bins one = {1};
        bins two = {2};
        bins four = {4};
        bins eight = {8};
        bins sixteen = {16};
    }

endgroup

class i2c_coverage extends uvm_subscriber #(i2c_seq_item);
    `uvm_component_utils(i2c_coverage)

    i2c_seq_item txn;
    virtual i2c_if vif;



    //covergroup instances
    i2c_operating_mode_cg   op_mode_cg;
    i2c_rd_wr_cg            rd_wr_cg;
    i2c_interrupts_cg       intr_cg;
    i2c_fifo_level_cg       fifo_cg;

    //local variables that covergroup samples
    i2c_agent_cfg::i2c_mode_e mode;
    logic rw;
    logic [6:0] addr;
    int num_bytes;

    function new(string name, uvm_component parent);
        super.new(name, parent);

    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif))
            `uvm_fatal("COV", "No interface found")
        
        op_mode_cg = new(mode, rw);
        rd_wr_cg = new(mode, rw);
        intr_cg = new(vif, mode, rw);
        fifo_cg = new(mode, rw);

    endfunction

    function void write(i2c_seq_item txn);
        //extract fields
        mode = HOST;
        rw = txn.rw;
        addr = txn.addr;
        num_bytes = txn.num_bytes;

        //sample all covergroups
        op_mode_cg.sample();
        rd_wr_cg.sample();
        fifo_cg.sample();
        intr_cg.sample();

    endfunction
    

endclass