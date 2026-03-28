# I2C UVM Verification

A UVM-based functional verification environment for the I2C IP block.

---

## Table of Contents

- [Project Overview](#project-overview)
- [Design Preparation](#design-preparation)
- [Test Plan](#test-plan)
- [Repository Structure](#repository-structure)

---

## Project Overview

This project implements a UVM (Universal Verification Methodology) testbench to functionally verify the I2C IP block. The goal is to build a structured, reusable verification environment — covering directed and constrained-random test scenarios — and measure coverage against a concrete set of defined test points.

---

## Design Preparation

### Source

The RTL and data files in this repository originate from the [OpenTitan](https://github.com/lowRISC/opentitan) open-source silicon project, maintained by lowRISC contributors and licensed under the Apache License 2.0.

The I2C IP supports both **Host** and **Target** operating modes and communicates over the TileLink-UL (TLUL) bus fabric used throughout the OpenTitan platform.

### RTL Cleanup

The original OpenTitan RTL pulls in a large number of project-internal dependencies — most notably assertion header files that reference primitives specific to the OpenTitan build system. To make the design portable and simulatable in a standalone UVM environment, the following cleanup was done:

- Removed all assertion-related `include` directives and header files from the RTL sources.
- Removed references to OpenTitan-internal assertion macros that would otherwise require the full project tree to compile.

The RTL logic itself is unchanged. The files under [rtl/](rtl/) represent a clean, self-contained version of the design ready for simulation.

**RTL files included:**

| File | Description |
|---|---|
| [rtl/i2c.sv](rtl/i2c.sv) | Top-level I2C wrapper |
| [rtl/i2c_core.sv](rtl/i2c_core.sv) | Core I2C logic |
| [rtl/i2c_controller_fsm.sv](rtl/i2c_controller_fsm.sv) | Host-mode controller FSM |
| [rtl/i2c_target_fsm.sv](rtl/i2c_target_fsm.sv) | Target-mode FSM |
| [rtl/i2c_bus_monitor.sv](rtl/i2c_bus_monitor.sv) | Bus activity monitor |
| [rtl/i2c_fifos.sv](rtl/i2c_fifos.sv) | TX/RX FIFO logic |
| [rtl/i2c_fifo_sync_sram_adapter.sv](rtl/i2c_fifo_sync_sram_adapter.sv) | SRAM-backed FIFO adapter |
| [rtl/i2c_reg_top.sv](rtl/i2c_reg_top.sv) | Register file top |
| [rtl/i2c_reg_pkg.sv](rtl/i2c_reg_pkg.sv) | Register package |
| [rtl/i2c_pkg.sv](rtl/i2c_pkg.sv) | Top-level I2C package |

---

## Test Plan

The [data/](data/) folder contains the official test plan for the I2C IP, taken directly from the OpenTitan project:

| File | Description |
|---|---|
| [data/i2c_testplan.hjson](data/i2c_testplan.hjson) | Functional test plan — host and target mode test points |
| [data/i2c_sec_cm_testplan.hjson](data/i2c_sec_cm_testplan.hjson) | Security countermeasure test plan |
| [data/i2c.hjson](data/i2c.hjson) | IP descriptor and register map metadata |

### Why this matters

The test plan serves as the authoritative specification for what needs to be verified. Each entry defines a named test point (`host_smoke`, `host_error_intr`, `target_stress_all`, etc.) along with:

- The stimulus required to exercise that scenario
- The checking criteria that must pass
- The verification stage (V1, V2, V3) it belongs to

This gives a concrete baseline to measure the verification environment against. As tests are implemented, they can be mapped back to test plan entries to track **functional coverage** and identify gaps — the same way a senior engineer or project lead would review verification completeness on a real tapeout project.

---

## Repository Structure

```
i2c_uvm_verification/
├── rtl/          # Cleaned RTL from OpenTitan (assertions removed)
├── data/         # Official OpenTitan test plan (hjson)
└── README.md
```
