
`define ASSERT_INIT(name, cond) \
    initial begin \
        if (!(cond)) $error("Assertion failed: %s", `"name`"); \
    end
    
package tlul_pkg;
 
    typedef struct packed { logic [31:0] d_data; logic [1:0] d_opcode;
        logic d_valid; logic a_ready; logic d_error; } tl_d2h_t;
    // add to tlul_pkg:
    typedef enum logic [2:0] {
        PutFullData = 3'h0,
        PutPartialData = 3'h1,
        Get = 3'h4
    } tl_a_op_e;
    // also add a_user field to tl_h2d_t struct:
    typedef struct packed { 
        logic [31:0] rsvd; 
    } tl_a_user_t;
    typedef struct packed { 
        tl_a_op_e    a_opcode;
        logic [2:0]  a_param;
        logic [2:0]  a_size;
        logic [9:0]  a_source;
        logic [31:0] a_address;
        logic [3:0]  a_mask;
        logic [31:0] a_data;
        tl_a_user_t  a_user;
        logic        a_valid;
        logic        d_ready;
    } tl_h2d_t;
endpackage

package prim_ram_1p_pkg;
    typedef struct packed { logic [3:0] cfg; } ram_1p_cfg_t;
    typedef struct packed { logic [3:0] cfg_rsp; } ram_1p_cfg_rsp_t;
endpackage

package prim_alert_pkg;
    typedef struct packed { logic ping_p; logic ping_n; 
        logic ack_p; logic ack_n; } alert_rx_t;
    typedef struct packed { logic alert_p; logic alert_n; } alert_tx_t;
endpackage

package top_racl_pkg;
    typedef logic [3:0] racl_policy_sel_t;
    typedef struct packed { logic [3:0] policy; } racl_policy_vec_t;
    typedef struct packed { logic valid; logic [3:0] code; } racl_error_log_t;
    typedef logic [3:0] racl_role_vec_t;
    typedef logic [3:0] racl_role_t;
    // add to top_racl_pkg:
    function automatic logic [3:0] tlul_extract_racl_role_bits(input logic [31:0] rsvd);
        return rsvd[3:0];
    endfunction
    function automatic logic [7:0] tlul_extract_ctn_uid_bits(input logic [31:0] rsvd);
        return rsvd[11:4];
    endfunction
endpackage

package prim_mubi_pkg;
    typedef enum logic [3:0] {
        MuBi4True  = 4'h6,
        MuBi4False = 4'h9
    } mubi4_t;
endpackage

package prim_subreg_pkg;
    typedef enum logic [2:0] {
        SwAccessRW  = 3'h0,
        SwAccessRO  = 3'h1,
        SwAccessWO  = 3'h2,
        SwAccessW1C = 3'h3,
        SwAccessW1S = 3'h4,
        SwAccessW0C = 3'h5,
        SwAccessRC  = 3'h6
    } sw_access_e;
endpackage

package prim_util_pkg;
    function automatic integer vbits(input integer n);
        vbits = (n <= 1) ? 1 : $clog2(n);
    endfunction
endpackage
// new package needed:
package top_pkg;
    parameter int TL_AW = 32;
    parameter int TL_DW = 32;
endpackage


// Stub modules for OpenTitan primitives

module prim_subreg #(parameter int DW=1, parameter sw_access_e SwAccess=SwAccessRW, 
    parameter logic [DW-1:0] RESVAL=0, parameter bit Mubi=0) (
    input  logic          clk_i, rst_ni, we, de,
    input  logic [DW-1:0] wd, d,
    output logic          qs, err_update, err_storage
);
    logic [DW-1:0] q;
    always_ff @(posedge clk_i or negedge rst_ni)
        if (!rst_ni) q <= RESVAL;
        else if (we) q <= wd;
        else if (de) q <= d;
    assign qs = q;
    assign err_update = 0;
    assign err_storage = 0;
endmodule

module prim_flop_2sync #(parameter int Width=1, parameter logic [Width-1:0] ResetValue=0) (
    input  logic             clk_i, rst_ni,
    input  logic [Width-1:0] d_i,
    output logic [Width-1:0] q_o
);
    logic [Width-1:0] d_ff1;
    always_ff @(posedge clk_i or negedge rst_ni)
        if (!rst_ni) begin d_ff1 <= ResetValue; q_o <= ResetValue; end
        else begin d_ff1 <= d_i; q_o <= d_ff1; end
endmodule

module prim_intr_hw #(parameter int Width=1, parameter bit FlopOutput=1) (
    input  logic          clk_i, rst_ni,
    input  logic          event_intr_i,
    input  logic          reg2hw_intr_enable_q_i,
    input  logic          reg2hw_intr_test_q_i,
    input  logic          reg2hw_intr_test_qe_i,
    input  logic          reg2hw_intr_state_q_i,
    input  logic          hw2reg_intr_state_de_o,
    output logic          hw2reg_intr_state_d_o,
    output logic          intr_o
);
    logic state;
    always_ff @(posedge clk_i or negedge rst_ni)
        if (!rst_ni) state <= 0;
        else if (reg2hw_intr_test_qe_i) state <= reg2hw_intr_test_q_i;
        else if (event_intr_i) state <= 1;
        else if (hw2reg_intr_state_de_o) state <= hw2reg_intr_state_d_o;
    assign intr_o = state & reg2hw_intr_enable_q_i;
    assign hw2reg_intr_state_d_o = state;
    assign hw2reg_intr_state_de_o = 0;
endmodule

module prim_fifo_sync #(parameter int Width=1, parameter int Depth=4, 
    parameter bit Pass=1) (
    input  logic             clk_i, rst_ni, clr_i, wvalid_i, rready_i,
    input  logic [Width-1:0] wdata_i,
    output logic             wready_o, rvalid_o, full_o, empty_o,
    output logic [Width-1:0] rdata_o,
    output logic [$clog2(Depth+1)-1:0] depth_o
);
    logic [Width-1:0] mem[Depth];
    logic [$clog2(Depth+1)-1:0] count;
    logic [$clog2(Depth)-1:0] wptr, rptr;
    assign full_o = (count == Depth);
    assign empty_o = (count == 0);
    assign wready_o = !full_o;
    assign rvalid_o = !empty_o;
    assign rdata_o = mem[rptr];
    assign depth_o = count;
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin count <= 0; wptr <= 0; rptr <= 0; end
        else if (clr_i) begin count <= 0; wptr <= 0; rptr <= 0; end
        else begin
            if (wvalid_i && wready_o) begin mem[wptr] <= wdata_i; wptr <= wptr+1; count <= count+1; end
            if (rvalid_o && rready_i) begin rptr <= rptr+1; count <= count-1; end
        end
    end
endmodule

module prim_fifo_sync_cnt #(parameter int Width=1, parameter int Depth=4) (
    input  logic clk_i, rst_ni, clr_i, incr_i, decr_i,
    output logic [$clog2(Depth+1)-1:0] cnt_o,
    output logic empty_o, full_o
);
    logic [$clog2(Depth+1)-1:0] cnt;
    assign cnt_o = cnt; assign empty_o = (cnt==0); assign full_o = (cnt==Depth);
    always_ff @(posedge clk_i or negedge rst_ni)
        if (!rst_ni) cnt <= 0;
        else if (clr_i) cnt <= 0;
        else if (incr_i && !decr_i && !full_o) cnt <= cnt+1;
        else if (decr_i && !incr_i && !empty_o) cnt <= cnt-1;
endmodule

module prim_arbiter_tree #(parameter int N=2, parameter int DW=1) (
    input  logic         clk_i, rst_ni,
    input  logic [N-1:0] req_i,
    input  logic [DW-1:0] data_i [N],
    output logic [N-1:0] gnt_o,
    output logic [$clog2(N)-1:0] idx_o,
    output logic [DW-1:0] data_o,
    output logic         valid_o
);
    assign valid_o = |req_i;
    assign idx_o = 0;
    assign gnt_o = req_i & ~(req_i-1);
    assign data_o = data_i[0];
endmodule

module prim_ram_1p_adv #(parameter int Width=32, parameter int Depth=512,
    parameter int DataBitsPerMask=1) (
    input  logic                    clk_i, rst_ni,
    input  logic                    req_i, write_i,
    input  logic [$clog2(Depth)-1:0] addr_i,
    input  logic [Width-1:0]        wdata_i, wmask_i,
    output logic [Width-1:0]        rdata_o,
    output logic                    rvalid_o, rerror_o,
    input  prim_ram_1p_pkg::ram_1p_cfg_t     cfg_i,
    output prim_ram_1p_pkg::ram_1p_cfg_rsp_t cfg_rsp_o
);
    logic [Width-1:0] mem[Depth];
    always_ff @(posedge clk_i) begin
        if (req_i && write_i) mem[addr_i] <= wdata_i & wmask_i;
        rdata_o <= req_i && !write_i ? mem[addr_i] : 0;
        rvalid_o <= req_i && !write_i;
    end
    assign rerror_o = 0;
    assign cfg_rsp_o = '0;
endmodule

module tlul_cmd_intg_chk (
    input  tlul_pkg::tl_h2d_t tl_i,
    output logic err_o
);
    assign err_o = 0;
endmodule

module tlul_rsp_intg_gen (
    input  tlul_pkg::tl_d2h_t tl_i,
    output tlul_pkg::tl_d2h_t tl_o
);
    assign tl_o = tl_i;
endmodule

module tlul_adapter_reg #(parameter int RegAw=8, parameter int RegDw=32) (
    input  logic clk_i, rst_ni,
    input  tlul_pkg::tl_h2d_t tl_i,
    output tlul_pkg::tl_d2h_t tl_o,
    output logic re_o, we_o,
    output logic [RegAw-1:0] addr_o,
    output logic [RegDw-1:0] wdata_o, wmask_o,
    input  logic [RegDw-1:0] rdata_i,
    input  logic error_i, intg_error_i
);
    assign re_o = 0; assign we_o = 0; assign addr_o = 0;
    assign wdata_o = 0; assign wmask_o = 0;
    assign tl_o = '0;
endmodule

module prim_reg_we_check #(parameter int DW=1) (
    input  logic clk_i, rst_ni,
    input  logic [DW-1:0] we_i,
    output logic err_o
);
    assign err_o = 0;
endmodule