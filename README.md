# Pipelined SIMD Multimedia Processor (RTL, VHDL)
**A 4-stage pipelined multimedia processor core implemented in structural VHDL, featuring a SIMD-style register file, a reduced multimedia/MMU instruction subset, and a full IF → ID → EX → WB datapath with forwarding.**

<div align="center">

[![HDL - VHDL](https://img.shields.io/badge/HDL-VHDL-blue?style=for-the-badge)](https://en.wikipedia.org/wiki/VHDL)
[![Design - RTL](https://img.shields.io/badge/Design-RTL-purple?style=for-the-badge)](https://en.wikipedia.org/wiki/Register-transfer_level)
[![Pipeline - 4%20Stage](https://img.shields.io/badge/Pipeline-4%20Stage-teal?style=for-the-badge)](https://en.wikipedia.org/wiki/Instruction_pipelining)
[![Tool - Vivado](https://img.shields.io/badge/Tool-Vivado-orange?style=for-the-badge)](https://www.xilinx.com/products/design-tools/vivado.html)
[![FPGA - RTL%20Simulation](https://img.shields.io/badge/FPGA-RTL%20Simulation-gray?style=for-the-badge)](https://en.wikipedia.org/wiki/Logic_simulation)
[![Repo - GitHub](https://img.shields.io/badge/Repo-GitHub-black?style=for-the-badge)](https://github.com/)

**May 2026 | Jin Yuan Chen**

</div>

---

<p align="center">
  <img src="docs/diagrams/simple_mmu_rtl.png" alt="Simple MMU Structural RTL" style="max-width:100%; height:auto;"/>
</p>
<p align="center">
  <em>Figure 1: Structural RTL diagram of the 4-stage pipeline datapath (IF/ID/EX/WB) including inter-stage registers, forwarding path, and MMU execution block.</em>
</p>

## Overview

This repository contains an RTL implementation of a **four-stage pipelined multimedia processor** written in VHDL. The design models a compact, SIMD-inspired execution core (conceptually similar to subsets of Cell SPU / Intel SSE-style operations) where each instruction traverses:

- **IF**: instruction fetch
- **ID**: instruction decode + register file read
- **EX**: multimedia execution unit (MMU/ALU)
- **WB**: write-back to the register file

The emphasis is on **structural composition**, deterministic stage boundaries via **inter-stage registers**, and **module-level testbenches** so each block can be verified before full top-level integration.

---

## Architecture (RTL hierarchy)

The primary top-level entity is `Multimedia_Processor_Unit` (see `rtl/mmu_simple_v2/Multimedia_Processor_Unit_VHDL/Multimedia_Processor_Unit.vhd` and `rtl/mmu_simple_v1/...`).

At a high level, the core is built as a structural hierarchy:

```
Multimedia_Processor_Unit (top)
├── s1_instruction_fetch/
│   ├── instruction_file      — Instruction memory / BRAM interface (v2 supports external muxed BRAM)
│   └── pc / pc_count         — Program counter (present in v1 flow)
├── s2_instruction_decode/
│   ├── if_id                 — IF→ID inter-stage register
│   ├── decoder               — Opcode + operand pointer decode
│   └── register_file         — SIMD-style register file read/write + debug readout hooks
├── s3_execution/
│   ├── id_ex                 — ID→EX inter-stage register
│   ├── forward               — WB→EX bypass network for data hazards
│   ├── mmu                   — Multimedia execution core (opcode dispatch)
│   └── operation_package/    — Behavioral procedures implementing instruction groups
│       ├── load_immediate.vhd
│       ├── saturate_math.vhd
│       └── rest_instruction.vhd
└── s4_wback/
    └── ex_wb                 — EX→WB inter-stage register (dest reg pointer + data + write-enable)
```

---

## Diagrams

### Synthesis / RTL view (Synopsys)
![Synopsys RTL](docs/diagrams/synposis_rtl.png)
> Synthesis-oriented RTL hierarchy view showing the main instantiated blocks and top-level connectivity.

### Forwarding verification (waveforms)
![Forwarding waveform](docs/images/Forward_to_ALU.png)
> Simulation waveform showing WB→EX forwarding in action (operand matches `wb_rd_ptr`, forwarded data aligns with the write-back value).

![Write-back waveform](docs/images/Register_Write_Back.png)
> Simulation waveform illustrating write-back behavior and destination register updates across pipeline stages.

---

## RTL block notes (what each block does)

### `decoder` — Instruction field decode (ID stage)
Extracts the **opcode**, register pointers (`rs*`, `rd`), immediates, and control signals (notably **write-back enable**) from the fetched instruction word.

### `register_file` — SIMD register file (ID/WB boundary)
Implements the processor’s register storage and access patterns:

- **ID read**: supplies `rs1/rs2/rs3` operand vectors into the pipeline
- **WB write**: writes `rd` on `wb_wback`
- **Debug readout**: exposes a “probe” style interface (e.g., `reg_tog`, address/segment selection) for observing register contents

### `if_id`, `id_ex`, `ex_wb` — Inter-stage pipeline registers
Each stage boundary is captured by a dedicated register module to preserve deterministic timing and isolate combinational logic between stages.

### `forward` — WB→EX hazard bypass
Compares operand pointers in EX against the destination pointer in WB and, when `wb_wback = '1'`, forwards the newest `wb_rd` value into EX operands (e.g., `fw_rs*`).

### `mmu` — Multimedia execution core (EX stage)
Dispatches instruction behavior based on opcode groups. In `mmu_simple_v2`, the EX logic delegates to procedure packages such as:

- `operation_package/load_immediate.vhd`
- `operation_package/saturate_math.vhd`
- `operation_package/rest_instruction.vhd`

This keeps the EX datapath readable while allowing the instruction set to be extended by adding/adjusting procedures.

---

## RTL variants (`mmu_simple_v1` vs `mmu_simple_v2`)

Both variants implement the same high-level 4-stage pipeline concept, but differ in integration details.

- **`rtl/mmu_simple_v1/`**: includes a flow using an internal block memory primitive (`blk_mem_gen_0`) and a `pc`-driven instruction fetch model, plus some board-oriented debug display logic.
- **`rtl/mmu_simple_v2/`**: exposes a **unified BRAM interface** at the top-level (`bram_data`, `bram_addr`, `bram_we`, `reset_busy`) to support external multiplexing between an instruction loader and the CPU core.

If you’re starting fresh, `mmu_simple_v2` is generally the easier top-level to integrate into a larger system because the instruction source can be swapped without rewriting the core pipeline.

---

## Verification & simulation

The repo contains both **block-level testbenches** and a **top-level integration testbench**. Common locations:

- **Unit testbenches**: `rtl/mmu_simple_v*/Multimedia_Processor_Unit_VHDL/**/verification/*.vhd`
- **Top-level**: `rtl/mmu_simple_v*/Multimedia_Processor_Unit_VHDL/Multimedia_Processor_Unit_tb*.vhd`

In `mmu_simple_v2`, the top-level Vivado testbench (`Multimedia_Processor_Unit_tb_vivado.vhd`) includes an example of dumping register contents to a text file (e.g., `register_file.txt`) after a run.

---

## Repository layout (RTL-first)

```
rtl/
├── mmu_simple_v1/
│   ├── Multimedia_Processor_Unit_VHDL/   — Core RTL + verification
│   └── hardware_report/                  — Implementation reports (timing/power/utilization)
├── mmu_simple_v2/
│   ├── Multimedia_Processor_Unit_VHDL/   — Core RTL + verification + constraints.xdc
│   ├── USART_Unit_VHDL/                  — UART/USART support blocks + TB
│   ├── instruction_loader.vhd            — Loader-side integration (BRAM write path)
│   └── Processor_Controller.vhd          — Control integration logic
└── *.asm / assembler.cpp / tests         — Assembly tests and tooling
```

---

## Notes

- This project intentionally prioritizes **clarity and module boundaries** over micro-optimizations.
- The EX stage is structured so new operations can be added by extending the `operation_package/` procedures and wiring decode fields consistently.
