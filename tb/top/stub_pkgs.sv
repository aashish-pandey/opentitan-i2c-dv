// Copyright lowRISC contributors (OpenTitan project).
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//

package top_pkg;

localparam int TL_AW=32;
localparam int TL_DW=32;    // = TL_DBW * 8; TL_DBW must be a power-of-two
localparam int TL_AIW=8;    // a_source, d_source
localparam int TL_DIW=1;    // d_sink
localparam int TL_AUW=23;   // a_user
localparam int TL_DUW=14;   // d_user
localparam int TL_DBW=(TL_DW>>3);
localparam int TL_SZW=$clog2($clog2(TL_DBW)+1);

// Number of cycles a differential skew is tolerated on the alert signal
localparam int unsigned AlertSkewCycles = 1;

// NOTE THAT THIS IS A FEATURE FOR TEST CHIPS ONLY TO MITIGATE
// THE RISK OF A BROKEN OTP MACRO. THIS WILL BE DISABLED FOR
// PRODUCTION DEVICES.
localparam int SecVolatileRawUnlockEn = 0;

endpackage

package prim_ram_1p_pkg;
  typedef struct packed {
    logic [3:0] unused;
  } ram_1p_cfg_t;

  typedef struct packed {
    logic [3:0] unused;
  } ram_1p_cfg_rsp_t;
endpackage

package top_racl_pkg;
  parameter int unsigned NrRaclPolicies = 1;
  typedef logic [3:0] racl_role_t;
  typedef logic [3:0] racl_policy_sel_t;
  typedef racl_role_t  [NrRaclPolicies-1:0] racl_role_vec_t;
  typedef racl_policy_sel_t [NrRaclPolicies-1:0] racl_policy_vec_t;

  typedef struct packed {
    logic        valid;
    logic [31:0] addr;
    logic [3:0]  role;
    logic [7:0]  ctn_uid;
  } racl_error_log_t;

  function automatic racl_role_t tlul_extract_racl_role_bits(input logic [top_pkg::TL_AUW-1:0] rsvd);
    return racl_role_t'(rsvd[3:0]);
  endfunction

  function automatic logic [7:0] tlul_extract_ctn_uid_bits(input logic [top_pkg::TL_AUW-1:0] rsvd);
    return rsvd[11:4];
  endfunction

endpackage