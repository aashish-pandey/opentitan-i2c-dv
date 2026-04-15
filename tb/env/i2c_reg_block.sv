//CTRL register
class i2c_ctrl_reg extends uvm_reg;

    `uvm_object_utils(i2c_ctrl_reg)

    uvm_reg_field enablehost;
    uvm_reg_field enabletarget;
    uvm_reg_field llpbk;
    uvm_reg_field nack_addr_after_timeout;
    uvm_reg_field ack_ctrl_en;
    uvm_reg_field multi_controller_monitor_en;
    uvm_reg_field tx_stretch_ctrl_en;


    function new(string name = "i2c_ctrl_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        enablehost = uvm_reg_field::type_id::create("enablehost");
        enabletarget = uvm_reg_field::type_id::create("enabletarget");
        llpbk = uvm_reg_field::type_id::create("llpbk");
        nack_addr_after_timeout = uvm_reg_field::type_id::create("nack_addr_after_timeout");
        ack_ctrl_en = uvm_reg_field::type_id::create("ack_ctrl_en");
        multi_controller_monitor_en = uvm_reg_field::type_id::create("multi_controller_monitor_en");
        tx_stretch_ctrl_en = uvm_reg_field::type_id::create("tx_stretch_ctrl_en");

        //configure(this, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
        enablehost.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        enabletarget.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
        llpbk.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 0);
        nack_addr_after_timeout.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 0);
        ack_ctrl_en.configure(this, 1, 4, "RW", 0, 1'b0, 1, 1, 0);
        multi_controller_monitor_en.configure(this, 1, 5, "RW", 0, 1'b0, 1, 1, 0);
        tx_stretch_ctrl_en.configure(this, 1, 6, "RW", 0, 1'b0, 1, 1, 0);

    endfunction

endclass

class i2c_intr_state_reg extends uvm_reg;

    `uvm_object_utils(i2c_intr_state_reg)

    uvm_reg_field fmt_threshold;
    uvm_reg_field rx_threshold;
    uvm_reg_field acq_threshold;
    uvm_reg_field rx_overflow;
    uvm_reg_field controller_halt;
    uvm_reg_field scl_interference;
    uvm_reg_field sda_interference;
    uvm_reg_field stretch_timeout;
    uvm_reg_field sda_unstable;
    uvm_reg_field cmd_complete;
    uvm_reg_field tx_stretch;
    uvm_reg_field tx_threshold;
    uvm_reg_field acq_stretch;
    uvm_reg_field unexp_stop;
    uvm_reg_field host_timeout;

    function new(string name="i2c_intr_state_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();
        fmt_threshold = uvm_reg_field::type_id::create("fmt_threshold");
        rx_threshold = uvm_reg_field::type_id::create("rx_threshold");
        acq_threshold = uvm_reg_field::type_id::create("acq_threshold");
        rx_overflow = uvm_reg_field::type_id::create("rx_overflow");
        controller_halt = uvm_reg_field::type_id::create("controller_halt");
        scl_interference = uvm_reg_field::type_id::create("scl_interference");
        sda_interference = uvm_reg_field::type_id::create("sda_interference");
        stretch_timeout = uvm_reg_field::type_id::create("stretch_timeout");
        sda_unstable = uvm_reg_field::type_id::create("sda_unstable");
        cmd_complete = uvm_reg_field::type_id::create("cmd_complete");
        tx_stretch = uvm_reg_field::type_id::create("tx_stretch");
        tx_threshold = uvm_reg_field::type_id::create("tx_threshold");
        acq_stretch = uvm_reg_field::type_id::create("acq_stretch");
        unexp_stop = uvm_reg_field::type_id::create("unexp_stop");
        host_timeout = uvm_reg_field::type_id::create("host_timeout");


        //configure(this, size, lsb_pos, access, volatile, reset, has_reset, is_rand, individually_accessible)
        fmt_threshold.configure(this, 1, 0, "W1C", 0, 1'b0, 1, 1, 0);
        rx_threshold.configure(this, 1, 1, "W1C", 0, 1'b0, 1, 1, 0);
        acq_threshold.configure(this, 1, 2, "W1C", 0, 1'b0, 1, 1, 0);
        rx_overflow.configure(this, 1, 3, "W1C", 0, 1'b0, 1, 1, 0);
        controller_halt.configure(this, 1, 4, "W1C", 0, 1'b0, 1, 1, 0);
        scl_interference.configure(this, 1, 5, "W1C", 0, 1'b0, 1, 1, 0);
        sda_interference.configure(this, 1, 6, "W1C", 0, 1'b0, 1, 1, 0);
        stretch_timeout.configure(this, 1, 7, "W1C", 0, 1'b0, 1, 1, 0);
        sda_unstable.configure(this, 1, 8, "W1C", 0, 1'b0, 1, 1, 0);
        cmd_complete.configure(this, 1, 9, "W1C", 0, 1'b0, 1, 1, 0);
        tx_stretch.configure(this, 1, 10, "W1C", 0, 1'b0, 1, 1, 0);
        tx_threshold.configure(this, 1, 11, "W1C", 0, 1'b0, 1, 1, 0);
        acq_stretch.configure(this, 1, 12, "W1C", 0, 1'b0, 1, 1, 0);
        unexp_stop.configure(this, 1, 13, "W1C", 0, 1'b0, 1, 1, 0);
        host_timeout.configure(this, 1, 14, "W1C", 0, 1'b0, 1, 1, 0);

    endfunction

endclass

class i2c_intr_enable_reg extends uvm_reg;

    `uvm_object_utils(i2c_intr_enable_reg)

    uvm_reg_field fmt_threshold;
    uvm_reg_field rx_threshold;
    uvm_reg_field acq_threshold;
    uvm_reg_field rx_overflow;
    uvm_reg_field controller_halt;
    uvm_reg_field scl_interference;
    uvm_reg_field sda_interference;
    uvm_reg_field stretch_timeout;
    uvm_reg_field sda_unstable;
    uvm_reg_field cmd_complete;
    uvm_reg_field tx_stretch;
    uvm_reg_field tx_threshold;
    uvm_reg_field acq_stretch;
    uvm_reg_field unexp_stop;
    uvm_reg_field host_timeout;

    function new(string name="i2c_intr_enable_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();
        fmt_threshold = uvm_reg_field::type_id::create("fmt_threshold");
        rx_threshold = uvm_reg_field::type_id::create("rx_threshold");
        acq_threshold = uvm_reg_field::type_id::create("acq_threshold");
        rx_overflow = uvm_reg_field::type_id::create("rx_overflow");
        controller_halt = uvm_reg_field::type_id::create("controller_halt");
        scl_interference = uvm_reg_field::type_id::create("scl_interference");
        sda_interference = uvm_reg_field::type_id::create("sda_interference");
        stretch_timeout = uvm_reg_field::type_id::create("stretch_timeout");
        sda_unstable = uvm_reg_field::type_id::create("sda_unstable");
        cmd_complete = uvm_reg_field::type_id::create("cmd_complete");
        tx_stretch = uvm_reg_field::type_id::create("tx_stretch");
        tx_threshold = uvm_reg_field::type_id::create("tx_threshold");
        acq_stretch = uvm_reg_field::type_id::create("acq_stretch");
        unexp_stop = uvm_reg_field::type_id::create("unexp_stop");
        host_timeout = uvm_reg_field::type_id::create("host_timeout");


        fmt_threshold.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        rx_threshold.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
        acq_threshold.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 0);
        rx_overflow.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 0);
        controller_halt.configure(this, 1, 4, "RW", 0, 1'b0, 1, 1, 0);
        scl_interference.configure(this, 1, 5, "RW", 0, 1'b0, 1, 1, 0);
        sda_interference.configure(this, 1, 6, "RW", 0, 1'b0, 1, 1, 0);
        stretch_timeout.configure(this, 1, 7, "RW", 0, 1'b0, 1, 1, 0);
        sda_unstable.configure(this, 1, 8, "RW", 0, 1'b0, 1, 1, 0);
        cmd_complete.configure(this, 1, 9, "RW", 0, 1'b0, 1, 1, 0);
        tx_stretch.configure(this, 1, 10, "RW", 0, 1'b0, 1, 1, 0);
        tx_threshold.configure(this, 1, 11, "RW", 0, 1'b0, 1, 1, 0);
        acq_stretch.configure(this, 1, 12, "RW", 0, 1'b0, 1, 1, 0);
        unexp_stop.configure(this, 1, 13, "RW", 0, 1'b0, 1, 1, 0);
        host_timeout.configure(this, 1, 14, "RW", 0, 1'b0, 1, 1, 0);
    endfunction
    

endclass

class i2c_intr_test_reg extends uvm_reg;
    `uvm_object_utils(i2c_intr_test_reg)

    uvm_reg_field fmt_threshold;
    uvm_reg_field rx_threshold;
    uvm_reg_field acq_threshold;
    uvm_reg_field rx_overflow;
    uvm_reg_field controller_halt;
    uvm_reg_field scl_interference;
    uvm_reg_field sda_interference;
    uvm_reg_field stretch_timeout;
    uvm_reg_field sda_unstable;
    uvm_reg_field cmd_complete;
    uvm_reg_field tx_stretch;
    uvm_reg_field tx_threshold;
    uvm_reg_field acq_stretch;
    uvm_reg_field unexp_stop;
    uvm_reg_field host_timeout;

    function new(string name="i2c_intr_test_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        fmt_threshold = uvm_reg_field::type_id::create("fmt_threshold");
        rx_threshold = uvm_reg_field::type_id::create("rx_threshold");
        acq_threshold = uvm_reg_field::type_id::create("acq_threshold");
        rx_overflow = uvm_reg_field::type_id::create("rx_overflow");
        controller_halt = uvm_reg_field::type_id::create("controller_halt");
        scl_interference = uvm_reg_field::type_id::create("scl_interference");
        sda_interference = uvm_reg_field::type_id::create("sda_interference");
        stretch_timeout = uvm_reg_field::type_id::create("stretch_timeout");
        sda_unstable = uvm_reg_field::type_id::create("sda_unstable");
        cmd_complete = uvm_reg_field::type_id::create("cmd_complete");
        tx_stretch = uvm_reg_field::type_id::create("tx_stretch");
        tx_threshold = uvm_reg_field::type_id::create("tx_threshold");
        acq_stretch = uvm_reg_field::type_id::create("acq_stretch");
        unexp_stop = uvm_reg_field::type_id::create("unexp_stop");
        host_timeout = uvm_reg_field::type_id::create("host_timeout");

        fmt_threshold.configure(this, 1, 0, "WO", 0, 1'b0, 1, 1, 0);
        rx_threshold.configure(this, 1, 1, "WO", 0, 1'b0, 1, 1, 0);
        acq_threshold.configure(this, 1, 2, "WO", 0, 1'b0, 1, 1, 0);
        rx_overflow.configure(this,  1, 3, "WO", 0, 1'b0, 1, 1, 0);
        controller_halt.configure(this, 1, 4, "WO", 0, 1'b0, 1, 1, 0);
        scl_interference.configure(this, 1, 5, "WO", 0, 1'b0, 1, 1, 0);
        sda_interference.configure(this, 1, 6, "WO", 0, 1'b0, 1, 1, 0);
        stretch_timeout.configure(this, 1, 7, "WO", 0, 1'b0, 1, 1, 0);
        sda_unstable.configure(this, 1, 8, "WO", 0, 1'b0, 1, 1, 0);
        cmd_complete.configure(this, 1, 9, "WO", 0, 1'b0, 1, 1, 0);
        tx_stretch.configure(this, 1, 10, "WO", 0, 1'b0, 1, 1, 0);
        tx_threshold.configure(this, 1, 11, "WO", 0, 1'b0, 1, 1, 0);
        acq_stretch.configure(this, 1, 12, "WO", 0, 1'b0, 1, 1, 0);
        unexp_stop.configure(this, 1, 13, "WO", 0, 1'b0, 1, 1, 0);
        host_timeout.configure(this, 1, 14, "WO", 0, 1'b0, 1, 1, 0);

    endfunction


endclass

class i2c_status_reg extends uvm_reg;
    `uvm_object_utils(i2c_status_reg)

    uvm_reg_field fmtfull;
    uvm_reg_field rxfull;
    uvm_reg_field fmtempty;
    uvm_reg_field hostidle;
    uvm_reg_field targetidle;
    uvm_reg_field rxempty;
    uvm_reg_field txfull;
    uvm_reg_field acqfull;
    uvm_reg_field txempty;
    uvm_reg_field acqempty;
    uvm_reg_field ack_ctrl_stretch;

    function new(string name="i2c_status_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        fmtfull = uvm_reg_field::type_id::create("fmtfull");
        rxfull = uvm_reg_field::type_id::create("rxfull");
        fmtempty = uvm_reg_field::type_id::create("fmtempty");
        hostidle = uvm_reg_field::type_id::create("hostidle");
        targetidle = uvm_reg_field::type_id::create("targetidle");
        rxempty = uvm_reg_field::type_id::create("rxempty");
        txfull = uvm_reg_field::type_id::create("txfull");
        acqfull = uvm_reg_field::type_id::create("acqfull");
        txempty = uvm_reg_field::type_id::create("txempty");
        acqempty = uvm_reg_field::type_id::create("acqempty");
        ack_ctrl_stretch = uvm_reg_field::type_id::create("ack_ctrl_stretch");

        fmtfull.configure(this, 1, 0, "RO", 0, 1'b0, 1, 1, 0);
        rxfull.configure(this, 1, 1, "RO", 0, 1'b0, 1, 1, 0);
        fmtempty.configure(this, 1, 2, "RO", 0, 1'b1, 1, 1, 0);
        hostidle.configure(this, 1, 3, "RO", 0, 1'b1, 1, 1, 0);
        targetidle.configure(this, 1, 4, "RO", 0, 1'b1, 1, 1, 0);
        rxempty.configure(this, 1, 5, "RO", 0, 1'b1, 1, 1, 0);
        txfull.configure(this, 1, 6, "RO", 0, 1'b0, 1, 1, 0);
        acqfull.configure(this, 1, 7, "RO", 0, 1'b0, 1, 1, 0);
        txempty.configure(this, 1, 8, "RO", 0, 1'b1, 1, 1, 0);
        acqempty.configure(this, 1, 9, "RO", 0, 1'b1, 1, 1, 0);
        ack_ctrl_stretch.configure(this, 1, 10, "RO", 0, 1'b0, 1, 1, 0);

    endfunction

endclass

class i2c_timing0_reg extends uvm_reg;

    `uvm_object_utils(i2c_timing0_reg)

    uvm_reg_field thigh;
    uvm_reg_field tlow;

    function new(string name="i2c_timing0_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        thigh = uvm_reg_field::type_id::create("thigh");
        tlow = uvm_reg_field::type_id::create("tlow");

        thigh.configure(this, 13, 0, "RW", 0, 13'b0, 1, 1, 0);
        tlow.configure(this, 13, 13, "RW", 0, 13'b0, 1, 1, 0);

    endfunction

endclass

class i2c_timing1_reg extends uvm_reg;

    `uvm_object_utils(i2c_timing1_reg)

    uvm_reg_field t_r;
    uvm_reg_field t_f;

    function new(string name="i2c_timing1_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        t_r = uvm_reg_field::type_id::create("t_r");
        t_f = uvm_reg_field::type_id::create("t_f");

        t_r.configure(this, 10, 0, "RW", 0, 10'b0, 1, 1, 0);
        t_f.configure(this, 9, 10, "RW", 0, 9'b0, 1, 1, 0);

    endfunction

endclass

class i2c_timing2_reg extends uvm_reg;

    `uvm_object_utils(i2c_timing2_reg)

    uvm_reg_field tsu_sta;
    uvm_reg_field thd_sta;

    function new(string name="i2c_timing2_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();
        tsu_sta = uvm_reg_field::type_id::create("tsu_sta");
        thd_sta = uvm_reg_field::type_id::create("thd_sta");

        tsu_sta.configure(this, 13, 0, "RW", 0, 13'b0, 1, 1, 0);
        thd_sta.configure(this, 13, 13, "RW", 0, 13'b0, 1, 1, 0);

    endfunction

endclass

class i2c_timing3_reg extends uvm_reg;

    `uvm_object_utils(i2c_timing3_reg)

    uvm_reg_field tsu_dat;
    uvm_reg_field thd_dat;

    function new(string name="i2c_timing3_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        tsu_dat = uvm_reg_field::type_id::create("tsu_dat");
        thd_dat = uvm_reg_field::type_id::create("thd_dat");

        tsu_dat.configure(this, 9, 0, "RW", 0, 9'b0, 1, 1, 0);
        thd_dat.configure(this, 13, 9, "RW", 0, 13'b0, 1, 1, 0);

    endfunction

endclass

class i2c_timing4_reg extends uvm_reg;

    `uvm_object_utils(i2c_timing4_reg)

    uvm_reg_field tsu_sto;
    uvm_reg_field t_buf;

    function new(string name="i2c_timing4_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        tsu_sto = uvm_reg_field::type_id::create("tsu_sto");
        t_buf = uvm_reg_field::type_id::create("t_buf");

        tsu_sto.configure(this, 13, 0, "RW", 0, 13'b0, 1, 1, 0);
        t_buf.configure(this, 13, 13, "RW", 0, 13'b0, 1, 1, 0);

    endfunction

endclass

class i2c_fdata_reg extends uvm_reg;

    `uvm_object_utils(i2c_fdata_reg)

    uvm_reg_field fbyte;
    uvm_reg_field start;
    uvm_reg_field stop;
    uvm_reg_field readb;
    uvm_reg_field rcont;
    uvm_reg_field nakok;

    function new(string name="i2c_fdata_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        fbyte = uvm_reg_field::type_id::create("fbyte");
        start = uvm_reg_field::type_id::create("start");
        stop = uvm_reg_field::type_id::create("stop");
        readb = uvm_reg_field::type_id::create("readb");
        rcont = uvm_reg_field::type_id::create("rcont");
        nakok = uvm_reg_field::type_id::create("nakok");

        fbyte.configure(this, 8, 0, "RW", 0, 8'b0, 1, 1, 0);
        start.configure(this, 1, 8, "RW", 0, 1'b0, 1, 1, 0);
        stop.configure(this, 1, 9, "RW", 0, 1'b0, 1, 1, 0);
        readb.configure(this, 1, 10, "RW", 0, 1'b0, 1, 1, 0);
        rcont.configure(this, 1, 11, "RW", 0, 1'b0, 1, 1, 0);
        nakok.configure(this, 1, 12, "RW", 0, 1'b0, 1, 1, 0);

    endfunction

endclass

class i2c_rdata_reg extends uvm_reg;

    `uvm_object_utils(i2c_rdata_reg)

    uvm_reg_field rdata;

    function new(string name="i2c_rdata_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        rdata = uvm_reg_field::type_id::create("rdata");
        rdata.configure(this, 8, 0, "RO", 0, 8'b0, 1, 1, 0);

    endfunction 

endclass

class i2c_fifo_ctrl_reg extends uvm_reg;

    `uvm_object_utils(i2c_fifo_ctrl_reg)

    uvm_reg_field rxrst;
    uvm_reg_field fmtrst;
    uvm_reg_field acqrst;
    uvm_reg_field txrst;

    function new(string name="i2c_fifo_ctrl_reg");

        super.new(name, 32, UVM_NO_COVERAGE);

    endfunction

    function void build();

        rxrst = uvm_reg_field::type_id::create("rxrst");
        fmtrst = uvm_reg_field::type_id::create("fmtrst");
        acqrst = uvm_reg_field::type_id::create("acqrst");
        txrst = uvm_reg_field::type_id::create("txrst");

        rxrst.configure(this, 1, 0, "RW", 0, 1'b0, 1, 1, 0);
        fmtrst.configure(this, 1, 1, "RW", 0, 1'b0, 1, 1, 0);
        acqrst.configure(this, 1, 2, "RW", 0, 1'b0, 1, 1, 0);
        txrst.configure(this, 1, 3, "RW", 0, 1'b0, 1, 1, 0);

    endfunction

endclass

class i2c_host_fifo_config_reg extends uvm_reg;

    `uvm_object_utils(i2c_host_fifo_config_reg)

    uvm_reg_field rx_thresh;
    uvm_reg_field fmt_thresh;

    function new(string name="i2c_host_fifo_config_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        rx_thresh = uvm_reg_field::type_id::create("rx_thresh");
        fmt_thresh = uvm_reg_field::type_id::create("fmt_thresh");

        rx_thresh.configure(this, 12, 0, "RW", 0, 12'b0, 1, 1, 0);
        fmt_thresh.configure(this, 12, 12, "RW", 0, 12'b0, 1, 1, 0);

    endfunction

endclass

class i2c_target_fifo_config_reg extends uvm_reg;

    `uvm_object_utils(i2c_target_fifo_config_reg)

    uvm_reg_field tx_thresh;
    uvm_reg_field acq_thresh;

    function new(string name="i2c_target_fifo_config_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        tx_thresh = uvm_reg_field::type_id::create("tx_thresh");
        acq_thresh = uvm_reg_field::type_id::create("acq_thresh");

        tx_thresh.configure(this, 12, 0, "RW", 0, 12'b0, 1, 1, 0);
        acq_thresh.configure(this, 12, 12, "RW", 0, 12'b0, 1, 1, 0);

    endfunction

endclass

class i2c_host_fifo_status_reg extends uvm_reg;

    `uvm_object_utils(i2c_host_fifo_status_reg)

    uvm_reg_field fmtlvl;
    uvm_reg_field rxlvl;

    function new(string name="i2c_host_fifo_status_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        fmtlvl = uvm_reg_field::type_id::create("fmtlvl");
        rxlvl = uvm_reg_field::type_id::create("rxlvl");

        fmtlvl.configure(this, 12, 0, "RO", 0, 12'b0, 1, 1, 0);
        rxlvl.configure(this, 12, 12, "RO", 0, 12'b0, 1, 1, 0);


    endfunction

endclass

class i2c_target_fifo_status_reg extends uvm_reg;

    `uvm_object_utils(i2c_target_fifo_status_reg)

    uvm_reg_field txlvl;
    uvm_reg_field acqlvl;

    function new(string name="i2c_target_fifo_status_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();

        txlvl = uvm_reg_field::type_id::create("txlvl");
        acqlvl = uvm_reg_field::type_id::create("acqlvl");

        txlvl.configure(this, 12, 0, "RO", 0, 12'b0, 1, 1, 0);
        acqlvl.configure(this, 12, 12, "RO", 0, 12'b0, 1, 1, 0);


    endfunction

endclass

class i2c_target_id_reg extends uvm_reg;

    `uvm_object_utils(i2c_target_id_reg)

    uvm_reg_field address0;
    uvm_reg_field mask0;
    uvm_reg_field address1;
    uvm_reg_field mask1;

    function new(string name="i2c_target_id_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();
        address0 = uvm_reg_field::type_id::create("address0");
        mask0 = uvm_reg_field::type_id::create("mask0");
        address1 = uvm_reg_field::type_id::create("address1");
        mask1 = uvm_reg_field::type_id::create("mask1");

        address0.configure(this, 7, 0, "RW", 0, 7'b0, 1, 1, 0);
        mask0.configure(this, 7, 7, "RW", 0, 7'b0, 1, 1, 0);
        address1.configure(this, 7, 14, "RW", 0, 7'b0, 1, 1, 0);
        mask1.configure(this, 7, 21, "RW", 0, 7'b0, 1, 1, 0);

    endfunction

endclass


class i2c_timeout_ctrl_reg extends uvm_reg;

    `uvm_object_utils(i2c_timeout_ctrl_reg)

    uvm_reg_field val;
    uvm_reg_field mode;
    uvm_reg_field en;

    function new(string name="i2c_timeout_ctrl_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();
        val = uvm_reg_field::type_id::create("val");
        mode = uvm_reg_field::type_id::create("mode");
        en = uvm_reg_field::type_id::create("en");

        val.configure(this, 30, 0, "RW", 0, 30'b0, 1, 1, 0);
        mode.configure(this, 1, 30, "RW", 0, 1'b0, 1, 1, 0);
        en.configure(this, 1, 31, "RW", 0, 1'b0, 1, 1, 0);

    endfunction

endclass


class i2c_host_timeout_ctrl_reg extends uvm_reg;

    `uvm_object_utils(i2c_host_timeout_ctrl_reg)

    uvm_reg_field val;

    function new(string name="i2c_host_timeout_ctrl_reg");
        super.new(name, 32, UVM_NO_COVERAGE);
    endfunction

    function void build();
        val = uvm_reg_field::type_id::create("val");

        val.configure(this, 20, 0, "RW", 0, 20'b0, 1, 1, 0);

    endfunction

endclass

class i2c_reg_block extends uvm_reg_block;

    `uvm_object_utils(i2c_reg_block)

    i2c_ctrl_reg ctrl;
    i2c_intr_state_reg intr_state;
    i2c_intr_enable_reg intr_enable;
    i2c_intr_test_reg intr_test;
    i2c_status_reg status;
    i2c_timing0_reg timing0;
    i2c_timing1_reg timing1;
    i2c_timing2_reg timing2;
    i2c_timing3_reg timing3;
    i2c_timing4_reg timing4;
    i2c_fdata_reg fdata;
    i2c_rdata_reg rdata;
    i2c_fifo_ctrl_reg fifo_ctrl;
    i2c_host_fifo_config_reg host_fifo_config;
    i2c_target_fifo_config_reg target_fifo_config;
    i2c_host_fifo_status_reg host_fifo_status;
    i2c_target_fifo_status_reg target_fifo_status;
    i2c_target_id_reg target_id;
    i2c_timeout_ctrl_reg timeout_ctrl;
    i2c_host_timeout_ctrl_reg host_timeout_ctrl;

    uvm_reg_map default_map;

    function new(string name="i2c_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    function void build();

        default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN);

        ctrl = i2c_ctrl_reg::type_id::create("ctrl");
        ctrl.configure(this, null, "");
        ctrl.build();
        default_map.add_reg(ctrl, 32'h10, "RW");

        intr_state = i2c_intr_state_reg::type_id::create("intr_state");
        intr_state.configure(this, null, "");
        intr_state.build();
        default_map.add_reg(intr_state, 32'h0, "RW");

        intr_enable = i2c_intr_enable_reg::type_id::create("intr_enable");
        intr_enable.configure(this, null, "");
        intr_enable.build();
        default_map.add_reg(intr_enable, 32'h4, "RW");

        intr_test = i2c_intr_test_reg::type_id::create("intr_test");
        intr_test.configure(this, null, "");
        intr_test.build();
        default_map.add_reg(intr_test, 32'h8, "RW");

        status = i2c_status_reg::type_id::create("status");
        status.configure(this, null, "");
        status.build();
        default_map.add_reg(status, 32'h14, "RW");

        timing0 = i2c_timing0_reg::type_id::create("timing0");
        timing0.configure(this, null, "");
        timing0.build();
        default_map.add_reg(timing0, 32'h3c, "RW");

        timing1 = i2c_timing1_reg::type_id::create("timing1");
        timing1.configure(this, null, "");
        timing1.build();
        default_map.add_reg(timing1, 32'h40, "RW");

        timing2 = i2c_timing2_reg::type_id::create("timing2");
        timing2.configure(this, null, "");
        timing2.build();
        default_map.add_reg(timing2, 32'h44, "RW");

        timing3 = i2c_timing3_reg::type_id::create("timing3");
        timing3.configure(this, null, "");
        timing3.build();
        default_map.add_reg(timing3, 32'h48, "RW");

        timing4 = i2c_timing4_reg::type_id::create("timing4");
        timing4.configure(this, null, "");
        timing4.build();
        default_map.add_reg(timing4, 32'h4c, "RW");

        fdata = i2c_fdata_reg::type_id::create("fdata");
        fdata.configure(this, null, "");
        fdata.build();
        default_map.add_reg(fdata, 32'h1c, "RW");

        rdata = i2c_rdata_reg::type_id::create("rdata");
        rdata.configure(this, null, "");
        rdata.build();
        default_map.add_reg(rdata, 32'h18, "RW");

        fifo_ctrl = i2c_fifo_ctrl_reg::type_id::create("fifo_ctrl");
        fifo_ctrl.configure(this, null, "");
        fifo_ctrl.build();
        default_map.add_reg(fifo_ctrl, 32'h20, "RW");

        host_fifo_config = i2c_host_fifo_config_reg::type_id::create("host_fifo_config");
        host_fifo_config.configure(this, null, "");
        host_fifo_config.build();
        default_map.add_reg(host_fifo_config, 32'h24, "RW");

        target_fifo_config = i2c_target_fifo_config_reg::type_id::create("target_fifo_config");
        target_fifo_config.configure(this, null, "");
        target_fifo_config.build();
        default_map.add_reg(target_fifo_config, 32'h28, "RW");

        host_fifo_status = i2c_host_fifo_status_reg::type_id::create("host_fifo_status");
        host_fifo_status.configure(this, null, "");
        host_fifo_status.build();
        default_map.add_reg(host_fifo_status, 32'h2c, "RW");

        target_fifo_status = i2c_target_fifo_status_reg::type_id::create("target_fifo_status");
        target_fifo_status.configure(this, null, "");
        target_fifo_status.build();
        default_map.add_reg(target_fifo_status, 32'h30, "RW");

        target_id = i2c_target_id_reg::type_id::create("target_id");
        target_id.configure(this, null, "");
        target_id.build();
        default_map.add_reg(target_id, 32'h54, "RW");

        timeout_ctrl = i2c_timeout_ctrl_reg::type_id::create("timeout_ctrl");
        timeout_ctrl.configure(this, null, "");
        timeout_ctrl.build();
        default_map.add_reg(timeout_ctrl, 32'h50, "RW");

        host_timeout_ctrl = i2c_host_timeout_ctrl_reg::type_id::create("host_timeout_ctrl");
        host_timeout_ctrl.configure(this, null, "");
        host_timeout_ctrl.build();
        default_map.add_reg(host_timeout_ctrl, 32'h60, "RW");


    endfunction

endclass