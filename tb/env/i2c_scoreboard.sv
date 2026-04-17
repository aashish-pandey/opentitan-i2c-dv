import uvm_pkg::*;
`include "uvm_macros.svh"
`uvm_analysis_imp_decl(_host)
`uvm_analysis_imp_decl(_target)
class i2c_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp_host #(i2c_seq_item, i2c_scoreboard) host_imp;
    uvm_analysis_imp_target #(i2c_seq_item, i2c_scoreboard) target_imp;

    `uvm_component_utils(i2c_scoreboard)
    i2c_seq_item host_values[$];
    i2c_seq_item target_values[$];

    int pass_count = 0;
    int fail_count = 0;


    function new(string name="i2c_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        host_imp = new("host_imp", this);
        target_imp = new("target_imp", this);
    endfunction

    function void write_host(i2c_seq_item txn);
        host_values.push_back(txn);
    endfunction

    function void write_target(i2c_seq_item txn);
        target_values.push_back(txn);
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            i2c_seq_item host_val;
            i2c_seq_item target_val;
            wait(host_values.size() > 0 && target_values.size() > 0);
            host_val = host_values.pop_front();
            target_val = target_values.pop_front();

            if(!host_val.compare(target_val))
                fail_count++;
            else 
                pass_count++;

        end
    endtask

    function void check_phase(uvm_phase phase);
        `uvm_info("SCB", $sformatf("PASS: %0d FAIL: %0d", pass_count, fail_count), UVM_NONE)
        if(fail_count > 0)
            `uvm_error("SCB", "Test Failed")
    endfunction

endclass