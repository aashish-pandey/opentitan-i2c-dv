//TL-UL is the register access bus used by opentitan IP blocks
//The testbench uses this interface to read and write the DUT's internal registers

/*
TL-UL uses two channel handshake. 
    A-Channel: host -> device (the request - "I want to read/write")
    D-Channel: device -> host (the response - "here is your data /write done")

Both channels uses ready/valid protocol:
    A transaction happens when Both valid and ready are high on the same clock edge


*/

`ifndef TLUL_IF_SV
`define TLUL_IF_SV

interface tlul_if (input logic clk);

    import tlul_pkg::*; //brings in tl_h2d_t, tl_d2h_t, opcodes, etc.

    tl_h2d_t h2d;
    tl_d2h_t d2h;

    clocking driver_cb @(posedge clk);
        output h2d; // driver writes the entire h2d struct
        input d2h;  //driver reads the entire d2h struct
    endclocking

    clocking monitor_cb @(posedge clk);
        input h2d;
        input d2h;
    endclocking

    //modports: modports restrict which signals each user of the interface can see.

    modport driver_mp (clocking driver_cb, input clk);
    modport monitor_mp(clocking monitor_cb, input clk);




endinterface

`endif


/*
NOTES:
1. h2d and d2h are packed structs from tlul_pkg - not individual signals. The driver writes the whole h2d struct at once.
2. h2d.d_ready sits inside the "host drives" struct - that's intensional in TL-UL. The host tells the dut it can accept a response.
3. d2h.a_ready sits inside the "device drives" struct. DUT tells host it can accept a request
4. The clocking blocks use the struct directly - the driver will access individual fields like driver_cb.h2d.a_valid <= 1
*/