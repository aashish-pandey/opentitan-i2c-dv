import uvm_pkg::*;
`include "uvm_macros.svh"
class i2c_env extends uvm_env;

    `uvm_component_utils(i2c_env)

    i2c_agent host_agent;
    i2c_agent target_agent;
    i2c_scoreboard scoreboard;
    i2c_intr_checker intr_checker;
    i2c_reg_block ral;

    function new(string name="i2c_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        i2c_agent_cfg host_cfg;
        i2c_agent_cfg target_cfg;
        super.build_phase(phase);

        //configure host agent
        host_cfg = i2c_agent_cfg::type_id::create("host_cfg");
        host_cfg.mode = HOST;
        host_cfg.is_active = UVM_ACTIVE;
        uvm_config_db #(i2c_agent_cfg)::set(this, "host_agent*", "cfg", host_cfg);

        //configure target agent
        target_cfg = i2c_agent_cfg::type_id::create("target_cfg");
        target_cfg.mode = TARGET;
        target_cfg.is_active = UVM_ACTIVE;
        uvm_config_db #(i2c_agent_cfg)::set(this, "target_agent*", "cfg", target_cfg);

        //create agents
        host_agent = i2c_agent::type_id::create("host_agent", this);
        target_agent = i2c_agent::type_id::create("target_agent", this);

        //create scoreboard
        scoreboard = i2c_scoreboard::type_id::create("scoreboard", this);

        //create intr checker
        intr_checker = i2c_intr_checker::type_id::create("intr_checker", this);

        //create ral
        ral = i2c_reg_block::type_id::create("ral");
        ral.build();
        uvm_config_db #(i2c_reg_block)::set(this, "intr_checker*", "ral", ral);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        host_agent.mon.ap.connect(scoreboard.host_imp);
        target_agent.mon.ap.connect(scoreboard.target_imp);

    endfunction


endclass