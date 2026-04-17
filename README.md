# I2C UVM Verification Environment

A fully functional UVM 1.2 verification environment for the OpenTitan I2C IP block, built from scratch. The testbench models the complete I2C protocol in both Host and Target roles, implements a TileLink-UL (TLUL) register bus agent, and verifies the DUT through constrained-random stimulus, a scoreboard, interrupt monitoring, and functional coverage.

---

## Table of Contents

- [What This Project Does](#what-this-project-does)
- [Background: OpenTitan and TLUL](#background-opentitan-and-tlul)
- [Design Preparation](#design-preparation)
- [Testbench Architecture](#testbench-architecture)
- [Component Reference](#component-reference)
- [Simulation Results](#simulation-results)
- [Running the Simulation](#running-the-simulation)
- [Repository Structure](#repository-structure)

---

## What This Project Does

We took the **I2C IP block from the OpenTitan open-source chip project** and built a complete UVM verification environment for it ourselves. The goal was to learn professional verification methodology end-to-end — from understanding the DUT's register interface, to modeling the physical I2C bus, to building the scoreboard infrastructure that proves correctness.

The environment verifies the I2C IP operating in **Target (Slave) mode**: our UVM testbench acts as the I2C Host driving transactions onto the bus, while the DUT responds as the Target. Register access to configure the DUT goes through a **TileLink-UL agent** — because that is how all registers in OpenTitan IP blocks are accessed.

**What we were able to simulate and verify:**

- Full I2C write transactions (START → address byte → N data bytes → STOP) at the physical signal level
- DUT acknowledging each byte correctly (hardware ACK/NACK sampled from the bus)
- TLUL register configuration of timing parameters, target address, and control registers
- Independent host-side and target-side bus monitors observing and reconstructing transactions
- Scoreboard comparing host-sent transactions against target-observed transactions: **5/5 PASS, 0 failures**
- ACQ FIFO drain after each transaction to prevent overflow on the DUT side

---

## Background: OpenTitan and TLUL

### OpenTitan

[OpenTitan](https://github.com/lowRISC/opentitan) is an open-source silicon project run by lowRISC that produces a complete, production-quality secure microcontroller design. Its IP blocks are real, production-grade RTL — not toy examples. Using one of its peripheral IPs as a verification target gives realistic complexity.

### TileLink-UL (TLUL)

One of the first things we had to learn is that OpenTitan IP blocks do **not** have simple register I/O ports. Every register is accessed over the **TileLink-UL (TL-UL) bus** — a lightweight, formally verified on-chip interconnect protocol used throughout the OpenTitan platform.

TLUL is a split transaction bus with two channels:

- **A-channel (Host → Device):** the requester drives `a_valid`, `a_opcode` (Get/PutFullData), `a_address`, `a_data`, `a_mask`, and integrity fields (`a_user`). The device responds with `a_ready` when it can accept the request.
- **D-channel (Device → Host):** the device drives `d_valid` with `d_opcode`, `d_data` (for reads), and `d_error`. The requester acknowledges with `d_ready`.

To write or read any I2C register, we had to implement a proper TLUL driver and sequence item. This meant understanding packed struct types (`tl_h2d_t`, `tl_d2h_t`), computing command and data integrity fields via `tlul_pkg` functions, and handling the handshake protocol correctly. We also ran into a simulator quirk: Xcelium does not allow assigning packed struct members through a clocking block, so the TLUL driver accesses the interface signals directly rather than through a clocking block.

This TLUL layer is entirely our own work — it is not provided by the OpenTitan project.

---

## Design Preparation

### RTL Source

The I2C RTL originates from the [OpenTitan](https://github.com/lowRISC/opentitan) project, maintained by lowRISC contributors and licensed under Apache 2.0.

The I2C IP supports both **Host** and **Target** operating modes. Configuration, status, FIFO access, and timing parameters are all controlled through the TLUL register bus.

### RTL Cleanup

The OpenTitan build system pulls in a large number of project-internal dependencies, most notably assertion header files that reference primitives specific to the OpenTitan build toolchain. To make the design compilable in a standalone Xcelium environment:

- Removed all `include` directives for assertion headers from RTL source files
- Removed references to OpenTitan-internal assertion macros
- The RTL logic itself is unchanged

**RTL files:**

| File | Description |
|---|---|
| [rtl/i2c.sv](rtl/i2c.sv) | Top-level I2C wrapper |
| [rtl/i2c_core.sv](rtl/i2c_core.sv) | Core I2C control logic |
| [rtl/i2c_controller_fsm.sv](rtl/i2c_controller_fsm.sv) | Host-mode controller FSM |
| [rtl/i2c_target_fsm.sv](rtl/i2c_target_fsm.sv) | Target-mode FSM |
| [rtl/i2c_bus_monitor.sv](rtl/i2c_bus_monitor.sv) | Bus activity monitor |
| [rtl/i2c_fifos.sv](rtl/i2c_fifos.sv) | TX/RX FIFO logic |
| [rtl/i2c_fifo_sync_sram_adapter.sv](rtl/i2c_fifo_sync_sram_adapter.sv) | SRAM-backed FIFO adapter |
| [rtl/i2c_reg_top.sv](rtl/i2c_reg_top.sv) | Register file top (TLUL slave) |
| [rtl/i2c_reg_pkg.sv](rtl/i2c_reg_pkg.sv) | Register package (fields and offsets) |
| [rtl/i2c_pkg.sv](rtl/i2c_pkg.sv) | Top-level I2C package |

---

## Testbench Architecture

```
uvm_test_top (i2c_smoke_test)
└── env (i2c_env)
    ├── host_agent     (i2c_agent — HOST mode, ACTIVE)
    │   ├── h_drv      (i2c_host_driver)   ──[I2C bus]──→ DUT physical pins
    │   ├── seq        (i2c_sequencer)
    │   └── mon        (i2c_monitor) ──ap──→ scoreboard.host_imp
    │
    ├── target_agent   (i2c_agent — TARGET mode, PASSIVE)
    │   └── mon        (i2c_monitor) ──ap──→ scoreboard.target_imp
    │        (no driver — DUT is the target; monitor only observes)
    │
    ├── tlul_agt       (tlul_agent — ACTIVE)
    │   ├── drv        (tlul_driver)   ──[TLUL bus]──→ DUT register interface
    │   └── seq        (tlul_sequencer)
    │
    ├── scoreboard     (i2c_scoreboard)
    │   ├── host_imp   ← i2c_seq_item from host monitor
    │   └── target_imp ← i2c_seq_item from target monitor
    │   └── compare() in run_phase
    │
    ├── intr_checker   (i2c_intr_checker)
    │   └── monitors fmt_threshold, rx_threshold, rx_overflow, cmd_complete
    │
    ├── ral            (i2c_reg_block)  — RAL model of all I2C registers
    └── adapter        (i2c_reg_adapter) — bridges RAL ↔ TLUL agent
```

**Data flow for an I2C write transaction:**

```
Sequence item (randomized address + data)
  → i2c_host_driver drives START, ADDR+RW, DATA[0..N-1], STOP onto I2C bus
      → DUT (target FSM) receives bytes, ACKs each, stores in ACQ FIFO
          → host monitor observes bus → reconstructs i2c_seq_item → scoreboard.host_imp
          → target monitor observes bus → reconstructs i2c_seq_item → scoreboard.target_imp
              → scoreboard.compare() → PASS or FAIL
```

**Register configuration flow:**

```
ral.timing0.update() (or any RAL method)
  → i2c_reg_adapter.reg2bus() → tlul_seq_item
      → tlul_sequencer → tlul_driver
          → drives A-channel on TLUL bus → DUT register file
              → D-channel response → tlul_driver captures d_data
                  → i2c_reg_adapter.bus2reg() → RAL mirror updated
```

### Open-Drain Bus Modeling

I2C is an open-drain bus: any participant can pull the line low; the line is high only when everyone releases it. We modeled this with `wand` (wired-AND) nets in the interface:

```systemverilog
wand scl, sda;
assign scl = scl_host_drive;              // host drives SCL
assign sda = sda_host_drive & sda_target_drive;  // both contribute to SDA
```

The host driver pulls SDA/SCL low to drive a `0` bit and releases (drives `1`) for a `1` bit. The target driver pulls SDA low for an ACK and releases for a NACK. The `wand` resolution means either participant can pull the line low, which correctly models the physical open-drain topology.

---

## Component Reference

### tb/agent/

| File | Class | Role |
|---|---|---|
| [tb/agent/i2c_seq_item.sv](tb/agent/i2c_seq_item.sv) | `i2c_seq_item` | I2C transaction: 7-bit addr, R/W, 1–16 data bytes |
| [tb/agent/i2c_agent_cfg.sv](tb/agent/i2c_agent_cfg.sv) | `i2c_agent_cfg` | Mode (HOST/TARGET), target address (0x55 default), active/passive |
| [tb/agent/i2c_sequencer.sv](tb/agent/i2c_sequencer.sv) | `i2c_sequencer` | Standard UVM sequencer for `i2c_seq_item` |
| [tb/agent/i2c_host_driver.sv](tb/agent/i2c_host_driver.sv) | `i2c_host_driver` | Drives I2C as master: START/STOP/bit/byte primitives, samples ACK |
| [tb/agent/i2c_target_driver.sv](tb/agent/i2c_target_driver.sv) | `i2c_target_driver` | Drives I2C as slave: address match, ACK/NACK, receives data bytes |
| [tb/agent/i2c_monitor.sv](tb/agent/i2c_monitor.sv) | `i2c_monitor` | Passive bus observer: detects START, captures addr+data until STOP |
| [tb/agent/i2c_agent.sv](tb/agent/i2c_agent.sv) | `i2c_agent` | Assembles driver + sequencer + monitor based on config mode |
| [tb/agent/tlul_seq_item.sv](tb/agent/tlul_seq_item.sv) | `tlul_seq_item` | TLUL transaction: 32-bit addr, R/W, 32-bit data, 4-bit mask |
| [tb/agent/tlul_sequencer.sv](tb/agent/tlul_sequencer.sv) | `tlul_sequencer` | Standard UVM sequencer for `tlul_seq_item` |
| [tb/agent/tlul_driver.sv](tb/agent/tlul_driver.sv) | `tlul_driver` | Drives TLUL A-channel request, waits for D-channel response, computes integrity fields |
| [tb/agent/tlul_agent.sv](tb/agent/tlul_agent.sv) | `tlul_agent` | Assembles TLUL sequencer + driver |

**Key implementation notes:**

- `i2c_host_driver`: each bit phase is `repeat(10) @(vif.driver_cb)` — timing registers are programmed to 10 to match.
- `i2c_monitor`: uses `fork/join_any` to race `receive_byte()` against `wait_for_stop()` — this prevents the monitor from hanging if the host issues a STOP before sending all expected data bytes.
- `tlul_driver`: accesses `vif.h2d`/`vif.d2h` directly (not through clocking block) due to Xcelium's restriction on packed struct members in clocking blocks.

### tb/env/

| File | Class | Role |
|---|---|---|
| [tb/env/i2c_reg_block.sv](tb/env/i2c_reg_block.sv) | `i2c_reg_block` | RAL model: all I2C registers with correct offsets, fields, and access types |
| [tb/env/i2c_reg_adapter.sv](tb/env/i2c_reg_adapter.sv) | `i2c_reg_adapter` | Converts RAL ops ↔ `tlul_seq_item`; bridges RAL to TLUL agent |
| [tb/env/i2c_scoreboard.sv](tb/env/i2c_scoreboard.sv) | `i2c_scoreboard` | Collects host and target monitor transactions, compares them, reports PASS/FAIL |
| [tb/env/i2c_intr_checker.sv](tb/env/i2c_intr_checker.sv) | `i2c_intr_checker` | Monitors 4 interrupt signals; reads/verifies interrupt state and W1C clear via RAL |
| [tb/env/i2c_env.sv](tb/env/i2c_env.sv) | `i2c_env` | Top-level env: instantiates and connects all agents, scoreboard, RAL, adapter |

**RAL model covers:** `intr_state`, `intr_enable`, `intr_test`, `ctrl`, `status`, `timing0–4`, `fdata`, `rdata`, `fifo_ctrl`, `host_fifo_config`, `target_fifo_config`, `host_fifo_status`, `target_fifo_status`, `acqdata`, `target_id`, `timeout_ctrl`, `host_timeout_ctrl` — mapped to offsets `0x0–0x60`.

**Key fix during development:** The RAL map sequencer must be wired to the **TLUL agent's sequencer**, not the I2C agent's sequencer. Wiring it to the I2C sequencer caused RAL register writes to be sent to the I2C physical bus driver instead of the register bus driver.

### tb/coverage/

| File | Class | Role |
|---|---|---|
| [tb/coverage/i2c_coverage.sv](tb/coverage/i2c_coverage.sv) | `i2c_coverage` | Functional coverage subscriber |

**Covergroups:**
- `i2c_operating_mode_cg` — HOST/TARGET mode crossed with READ/WRITE
- `i2c_rd_wr_cg` — I2C address (auto-binned, 4 bins) crossed with R/W direction
- `i2c_interrupts_cg` — whether each of 4 key interrupts fired
- `i2c_fifo_level_cg` — transaction data length: {1, 2, 4, 8, 16} bytes

### tb/sequences/

| File | Class | Role |
|---|---|---|
| [tb/sequences/i2c_host_smoke_vseq.sv](tb/sequences/i2c_host_smoke_vseq.sv) | `i2c_host_smoke_vseq` | Virtual sequence: configures DUT via TLUL, then runs 5 randomized I2C write transactions |

**Sequence body:**

1. **TLUL register setup** — programs all 5 timing registers (tlow=10, thigh=10, t_r=5, t_f=5, tsu/thd values), enables target mode (`ctrl.enabletarget=1`), sets target address to `0x55` with mask `0x7F`, reads back registers to verify.
2. **5 I2C write transactions** — each randomized (address fixed to 0x55, data bytes randomized, 1–16 bytes). After each transaction, reads `status` and `target_fifo_status`, then drains the DUT's ACQ FIFO by reading `acqdata` until empty. Draining is required to prevent FIFO overflow which would cause the DUT to NACK future transactions.

### tb/tests/

| File | Class | Role |
|---|---|---|
| [tb/tests/i2c_base_test.sv](tb/tests/i2c_base_test.sv) | `i2c_base_test` | Creates `i2c_env`; base class for all tests |
| [tb/tests/i2c_smoke_test.sv](tb/tests/i2c_smoke_test.sv) | `i2c_smoke_test` | Waits for reset to deassert + 5 extra clocks, then starts `i2c_host_smoke_vseq` |

**Why wait after reset?** The TLUL driver stalls in a loop waiting for `a_ready`. The DUT only asserts `a_ready` after reset deasserts. If the RAL attempts a register write while `rst_ni=0`, the driver will wait forever. The extra clock cycles give the DUT's internal reset synchronizers time to settle.

### tb/top/

| File | Role |
|---|---|
| [tb/top/tb_top.sv](tb/top/tb_top.sv) | Top-level testbench: clock (50 MHz), reset (active-low, 5-cycle), DUT instantiation, interface binding, config_db setup |
| [tb/top/i2c_if.sv](tb/top/i2c_if.sv) | I2C bus interface: `wand` nets for open-drain SCL/SDA, clocking blocks for driver and monitor, 14 interrupt signal ports |
| [tb/top/tlul_if.sv](tb/top/tlul_if.sv) | TLUL register bus interface: `tl_h2d_t` and `tl_d2h_t` packed structs, clocking blocks |
| [tb/top/stub_pkgs.sv](tb/top/stub_pkgs.sv) | Stub packages for `top_pkg` (TL-UL widths) and `top_racl_pkg` (RACL policy types) — minimal stubs replacing OpenTitan platform packages |

---

## Simulation Results

**Simulator:** Cadence Xcelium 23.09-s012  
**Test:** `i2c_smoke_test` (seed 1)  
**Date:** April 17, 2026  
**Simulation time:** 243.89 µs

### What ran

**Phase 1 — TLUL register configuration:**

| Register | Address | Value Written | Purpose |
|---|---|---|---|
| `timing0` | 0x3C | `0x000A000A` | thigh=10, tlow=10 |
| `timing1` | 0x40 | `0x00050005` | t_r=5, t_f=5 |
| `timing2` | 0x44 | `0x00050005` | tsu_sta=5, thd_sta=5 |
| `timing3` | 0x48 | `0x00050005` | tsu_dat=5, thd_dat=5 |
| `timing4` | 0x4C | `0x00050005` | tsu_sto=5, t_buf=5 |
| `ctrl` | 0x10 | `0x2` | enabletarget=1 |
| `target_id` | 0x58 | addr0=0x55, mask0=0x7F | target address |

**Phase 2 — 5 I2C write transactions (all PASS):**

| TXN | Data bytes | ACKs sampled | ACQ FIFO entries | Result |
|---|---|---|---|---|
| 1 | 6 (0xeb, 0xec, 0xc2, 0x36, 0xbe, 0xc3) | 7 | 8 | PASS |
| 2 | 8 (0xc2, 0xed, 0xdf, 0xbe, 0x40, 0xcb, 0x13, 0x56) | 9 | 10 | PASS |
| 3 | 13 (longest transaction) | 14 | 15 | PASS |
| 4 | 6 | 7 | 8 | PASS |
| 5 | 5 | 6 | 7 | PASS |

**Scoreboard final result:** PASS: 5, FAIL: 0

**UVM report summary:**
```
UVM_INFO    : 91
UVM_WARNING : 0
UVM_ERROR   : 0
UVM_FATAL   : 0
```

---

## Running the Simulation

```bash
cd sim
make run TEST=i2c_smoke_test
```

The Makefile uses Xcelium (`xrun`) with UVM 1.2 and `+define+ASSERT_OFF`. Include directories cover `rtl/`, `prim/`, `tlul/`, and `tb/`.

To run with a different seed:
```bash
make run TEST=i2c_smoke_test SEED=42
```

---

## Repository Structure

```
i2c_uvm_verification/
├── rtl/                          # OpenTitan I2C RTL (assertions removed)
├── prim/                         # OpenTitan primitive cells
├── prim_generic/                 # Generic technology-independent primitives
├── tlul/                         # TileLink-UL bus infrastructure RTL
├── data/                         # OpenTitan test plan (hjson)
├── sim/                          # Makefile and simulation working directory
└── tb/
    ├── agent/                    # I2C + TLUL UVM agents (seq items, drivers, monitors)
    ├── env/                      # RAL model, adapter, scoreboard, interrupt checker, env
    ├── coverage/                 # Functional coverage collector
    ├── sequences/                # Virtual sequences (stimulus)
    ├── tests/                    # UVM test classes
    └── top/                      # tb_top, interfaces, stub packages
```

---

## Test Plan

The [data/](data/) directory contains the official OpenTitan test plan:

| File | Description |
|---|---|
| [data/i2c_testplan.hjson](data/i2c_testplan.hjson) | Functional test points for host and target modes |
| [data/i2c_sec_cm_testplan.hjson](data/i2c_sec_cm_testplan.hjson) | Security countermeasure test points |
| [data/i2c.hjson](data/i2c.hjson) | IP descriptor and register map metadata |

The test plan defines named test points (`host_smoke`, `host_error_intr`, `target_stress_all`, etc.) with stimulus, checking criteria, and verification stage (V1/V2/V3). The smoke test implemented here corresponds to the `host_smoke` entry — a foundational V1 test demonstrating that basic I2C write transactions work end-to-end.