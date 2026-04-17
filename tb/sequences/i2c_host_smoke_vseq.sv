class i2c_host_smoke_vseq extends uvm_sequence #(i2c_seq_item);
    `uvm_object_utils(i2c_host_smoke_vseq)

    i2c_reg_block ral;

    function new(string name="i2c_host_smoke_vseq");
        super.new(name);
    endfunction

    task body();

        i2c_seq_item item;
        uvm_status_e status;

        //get RAL from config_db
        if(!uvm_config_db #(i2c_reg_block)::get(null, "", "ral", ral))
            `uvm_fatal("VSEQ", "No RAL found")
        
        //step-1 : enable host mode
        ral.ctrl.enablehost.set(1);
        ral.ctrl.update(status);

        //step-2 : program timing
        ral.timing0.thigh.set(16);
        ral.timing0.tlow.set(16);
        ral.timing0.update(status);

        ral.timing1.t_r.set(16);
        ral.timing1.t_f.set(16);
        ral.timing1.update(status);

        ral.timing2.tsu_sta.set(16);
        ral.timing2.thd_sta.set(16);
        ral.timing2.update(status);

        ral.timing3.tsu_dat.set(16);
        ral.timing3.thd_dat.set(16);
        ral.timing3.update(status);

        ral.timing4.tsu_sto.set(16);
        ral.timing4.t_buf.set(16);
        ral.timing4.update(status);

        //step3 - send 5 write transactions
        repeat(5) begin
            item = i2c_seq_item::type_id::create("item");
            start_item(item);
            if(!item.randomize() with {item.rw == 0;})
                `uvm_fatal("VSEQ", "Randomization Failed")
            finish_item(item);
        end

        //step 4 - send 3 read transactions
        repeat(3) begin
            item = i2c_seq_item::type_id::create("item");
            start_item(item);
            if(!item.randomize() with {item.rw == 1;})
                `uvm_fatal("VSEQ", "Randomization failed")
            finish_item(item);
        end


    endtask

endclass