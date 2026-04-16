class i2c_agent extends uvm_agent;

    i2c_host_driver h_drv;
    i2c_target_driver t_drv;
    i2c_sequencer seq;
    i2c_monitor mon;
    i2c_agent_cfg agt;

    `uvm_component_utils(i2c_agent)

    function new(string name="i2c_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon = i2c_monitor::type_id::create("mon", this);
        if(!uvm_config_db #(i2c_agent_cfg)::get(this, "", "cfg", agt))
            `uvm_fatal("NO_CFG", "No agent config found")
        if(get_is_active() == UVM_ACTIVE)begin
            if(agt.mode == HOST) begin
                h_drv = i2c_host_driver::type_id::create("h_drv", this);
            end
            else begin
                t_drv = i2c_target_driver::type_id::create("t_drv", this);
            end
            seq = i2c_sequencer::type_id::create("seq", this);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        if(get_is_active() == UVM_ACTIVE)begin
            if(agt.mode == HOST)begin
                h_drv.seq_item_port.connect(seq.seq_item_export);
            end
            else begin
                t_drv.seq_item_port.connect(seq.seq_item_export);
            end

        end
    endfunction

endclass