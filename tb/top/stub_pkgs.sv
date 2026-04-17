package top_pkg;
    parameter int TL_AW = 32;
    parameter int TL_DW = 32;
endpackage

package top_racl_pkg;
    typedef logic [3:0] racl_policy_sel_t;
    typedef struct packed { logic [3:0] policy; } racl_policy_vec_t;
    typedef struct packed { 
        logic        valid;
        logic [31:0] request_address;
        logic [7:0]  ctn_uid;
        logic [3:0]  role;
        logic        read_access;
    } racl_error_log_t;
    typedef logic [3:0] racl_role_vec_t;
    typedef logic [3:0] racl_role_t;
    function automatic logic [3:0] tlul_extract_racl_role_bits(input logic [31:0] rsvd);
        return rsvd[3:0];
    endfunction
    function automatic logic [7:0] tlul_extract_ctn_uid_bits(input logic [31:0] rsvd);
        return rsvd[11:4];
    endfunction
endpackage

package prim_ram_1p_pkg;
    typedef struct packed { logic [3:0] cfg; } ram_1p_cfg_t;
    typedef struct packed { logic [3:0] cfg_rsp; } ram_1p_cfg_rsp_t;
endpackage