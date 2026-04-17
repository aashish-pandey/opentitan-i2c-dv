class i2c_base_test extends uvm_test;

    `uvm_component_utils(i2c_base_test)

    i2c_env env;

    function new(string name="i2c_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = i2c_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        //base-test does nothing - child test will override this
        phase.drop_objection(this);
    endtask

endclass