import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_intr_checker extends uvm_component;

    `uvm_component_utils(i2c_intr_checker)

    virtual i2c_if vif;
    i2c_reg_block ral;

    function new(string name="i2c_intr_checker", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual i2c_if)::get(this, "", "vif", vif))
            `uvm_fatal("INTR", "No interface handler found")
        if(!uvm_config_db #(i2c_reg_block)::get(this, "", "ral", ral))
            `uvm_fatal("INTR", "No RAL handle found")
    endfunction

    task run_phase(uvm_phase phase);
        fork
            begin: fmt_threshold_Check
                forever begin
                    uvm_status_e status;
                    uvm_reg_data_t val;

                    //wait for interrupt to fire
                    @(posedge vif.intr_fmt_threshold);

                    //verify INTR_STATE bit is set via RAL
                    ral.intr_state.read(status, val);
                    if(val[0] != 1'b1)
                        `uvm_error("INTR", "fmt_threshold fired but INTR_STATE bit not set")
                    else
                        `uvm_info("INTR", "fmt_threshold interrupt verified", UVM_MEDIUM)
                    
                    //clear it via W1C write
                    ral.intr_state.fmt_threshold.write(status, 1'b1);

                    //verify it is cleared
                    ral.intr_state.read(status, val);
                    if(val[0] !== 1'b0)
                        `uvm_error("INTR", "fmt_threshold did not clear after W1C write")
                end 
            end
            begin: rx_threshold_check
                forever begin
                    uvm_status_e status;
                    uvm_reg_data_t val;


                    @(posedge vif.intr_rx_threshold);

                    ral.intr_state.read(status, val);

                    if(val[1] != 1'b1)
                        `uvm_error("INTR", "rx_threshold fired but INTR_STATE bit is not set")
                    else
                        `uvm_info("INTR", "rx_threshold interrupt verified", UVM_MEDIUM)

                    ral.intr_state.rx_threshold.write(status, 1'b1);

                    ral.intr_state.read(status, val);
                    if(val[1] !== 1'b0)
                        `uvm_error("INTR", "rx_threshold did not clear after W1C write")
                end
            end
            begin: rx_overflow_check
                forever begin
                    uvm_status_e status;
                    uvm_reg_data_t val;

                    @(posedge vif.intr_rx_overflow);

                    ral.intr_state.read(status, val);

                    if(val[3] !== 1'b1)
                        `uvm_error("INTR", "rx_overflow interrupt fired but INTR_STATE bit is not set")
                    else
                        `uvm_info("INTR", "rx_overflow interrupt verified", UVM_MEDIUM)

                    ral.intr_state.rx_overflow.write(status, 1'b1);

                    ral.intr_state.read(status, val);

                    if(val[3] !== 1'b0)
                        `uvm_error("INTR", "rx_overflow did not clear after W1C write")
                end
            end
            begin: cmd_complete_check
                forever begin
                    uvm_status_e status;
                    uvm_reg_data_t val;
                    @(posedge vif.intr_cmd_complete);

                    ral.intr_state.read(status, val);
                    if(val[9] !== 1'b1)
                        `uvm_error("INTR", "cmd_complete interrupt fired but INTR_STATE bit is not set")
                    else
                        `uvm_info("INTR", "cmd_complete interrupt verified", UVM_MEDIUM)
                    
                    ral.intr_state.cmd_complete.write(status, 1'b1);
                    ral.intr_state.read(status, val);

                    if(val[9] !== 1'b0)
                        `uvm_error("INTR", "cmd_complete did not clear after W1C write")


                end
            end
        join_none
        

    endtask



endclass