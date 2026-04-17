
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
endpackage