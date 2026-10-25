# Simple Memory Module (RAM in RTL with Vivado)

[![CI](https://github.com/abhishek947kumar/simple-memory-module/actions/workflows/ci.yml/badge.svg)](https://github.com/abhishek947kumar/simple-memory-module/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![HDL: Verilog-2001](https://img.shields.io/badge/HDL-Verilog--2001-brightgreen.svg)](#)
[![EDA: AMD Vivado](https://img.shields.io/badge/EDA-AMD%20Vivado-red.svg)](#)
[![Target: Xilinx 7--Series](https://img.shields.io/badge/FPGA-Xilinx%207--Series%20(Artix--7)-orange.svg)](#)

A complete, production-ready, synthesizable RAM module project developed for **AMD/Xilinx Vivado** and open-source simulators (**Icarus Verilog**).

This project demonstrates how semiconductor memories (Single-Port and True Dual-Port RAMs) are represented in RTL, addressed, written, read, parameterized, and synthesized into target FPGA primitives (**Block RAM / BRAM** and **Distributed LUT RAM**).

---

## 📌 Repository Structure

```
Simple Memory Module/
├── .github/
│   └── workflows/
│       └── ci.yml              # Automated GitHub Actions CI workflow (iverilog)
├── rtl/
│   ├── single_port_ram.v       # Parameterized Single-Port Synchronous RAM
│   └── dual_port_ram.v         # Parameterized True Dual-Port Synchronous RAM
├── tb/
│   ├── tb_single_port_ram.v    # Self-checking testbench for Single-Port RAM
│   └── tb_dual_port_ram.v      # Self-checking testbench for True Dual-Port RAM
├── scripts/
│   ├── create_project.tcl      # TCL script to build/rebuild Vivado project from scratch
│   ├── run_sim.tcl             # TCL script to execute behavioral simulation
│   └── run_synth.tcl           # TCL script to synthesize and report memory usage
├── reports/
│   ├── timing_synth.rpt        # Post-synthesis timing report
│   └── utilization_synth.rpt   # Post-synthesis FPGA resource utilization report
├── vivado_proj/
│   └── simple_memory_module.xpr # Portable Vivado project configuration
├── run_sim.bat                 # 1-click Windows batch script for Vivado simulation
├── run_synth.bat               # 1-click Windows batch script for Vivado synthesis
├── open_vivado_gui.bat         # 1-click Windows batch script to launch Vivado GUI
├── run_sim.sh                  # Linux/macOS shell script for Vivado simulation
├── run_synth.sh                # Linux/macOS shell script for Vivado synthesis
├── open_vivado_gui.sh          # Linux/macOS shell script to launch Vivado GUI
├── .gitattributes              # Cross-platform line endings and binary definitions
├── .gitignore                  # Comprehensive filter for Vivado & OS cache/temporary files
├── CONTRIBUTING.md             # Contribution guidelines & coding conventions
├── LICENSE                     # MIT License
└── README.md                   # Architectural guide & documentation
```

---

## 🧠 Architectural Concepts & RTL Design

### 1. Memory Arrays in Verilog
In Verilog, a hardware memory array is declared as a two-dimensional array of registers:
```verilog
reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];
```
- **Vector Dimension (`[DATA_WIDTH-1:0]`)**: Specifies the width of each memory word (e.g., 8-bit, 16-bit, 32-bit).
- **Array Dimension (`[0:RAM_DEPTH-1]`)**: Specifies the number of addressable locations (depth of the memory).

### 2. Addressing & Depth Relationship
The address bus width (`ADDR_WIDTH`) determines the maximum addressable memory locations:
$$\text{RAM\_DEPTH} = 2^{\text{ADDR\_WIDTH}}$$

| Address Width (`ADDR_WIDTH`) | Number of Words (`RAM_DEPTH`) | Example Capacity (`DATA_WIDTH = 8`) |
| :---: | :---: | :---: |
| 4 bits | 16 words | 16 Bytes |
| 6 bits | 64 words | 64 Bytes |
| 10 bits | 1,024 words | 1 KB |
| 12 bits | 4,096 words | 4 KB |

### 3. Synchronous Writes
In robust digital design, RAM writes are **synchronous** to avoid timing hazards and glitch propagation. Data is committed on the active clock edge when both `en` (RAM chip select) and `we` (write enable) are asserted:
```verilog
always @(posedge clk) begin
    if (en && we) begin
        mem[addr] <= din;
    end
end
```

### 4. Read Behaviors & Read-During-Write Modes
When reading and writing to the **same address simultaneously**, memory modules exhibit different behaviors depending on architecture:

| Read Mode | Verilog Implementation | Hardware Meaning |
| :--- | :--- | :--- |
| **READ_FIRST** (Default / Native BRAM) | `mem[addr] <= din; dout <= mem[addr];` | `dout` gets the **previous value** stored at `addr` before the write. |
| **WRITE_FIRST** (Transparent Mode) | `mem[addr] <= din; dout <= din;` | `dout` reflects the **new value** being written during the same cycle. |
| **NO_CHANGE** | `if (we) mem[addr] <= din; else dout <= mem[addr];` | `dout` holds its previous value during write cycles (power-saving). |

### 5. Synthesizable Memory Primitives in Vivado
Vivado targets two primary hardware structures on Xilinx FPGAs:
1. **Block RAM (BRAM)**: Dedicated, dual-port 18Kb/36Kb synchronous hard memory blocks (`RAMB18E1`, `RAMB36E1`).
   - Requires synchronous read and write operations.
   - Ideal for medium to large memory buffers.
   - Controlled via `(* ram_style = "block" *)`.
2. **Distributed RAM (LUTRAM)**: Built using LUTs within SLICEM logic slices (`RAM32X1S`, `RAM64X1S`).
   - Can support asynchronous or synchronous read.
   - Ideal for shallow FIFOs, register files, and small buffers (< 128 words).
   - Controlled via `(* ram_style = "distributed" *)`.

---

## 🚀 Quick Start Guide

### Option A: Using One-Click Scripts

#### On Windows:
- **Run Behavioral Simulation**: Double-click `run_sim.bat`
- **Run Synthesis**: Double-click `run_synth.bat`
- **Open Interactive Vivado GUI**: Double-click `open_vivado_gui.bat`

#### On Linux / macOS:
```bash
# Make scripts executable (if needed)
chmod +x *.sh

# Run behavioral simulation
./run_sim.sh

# Run synthesis
./run_synth.sh

# Open interactive Vivado GUI
./open_vivado_gui.sh
```

---

### Option B: Using Vivado Batch / TCL Mode

```bash
# Rebuild the Vivado project from scratch (works across any Vivado version)
vivado -mode batch -source scripts/create_project.tcl

# Run behavioral simulation
vivado -mode batch -source scripts/run_sim.tcl

# Run synthesis & produce resource reports
vivado -mode batch -source scripts/run_synth.tcl

# Open Vivado project
vivado vivado_proj/simple_memory_module.xpr
```

---

### Option C: Using Open-Source Tools (Icarus Verilog + VVP)

No Vivado installation required! You can simulate using open-source tools:

```bash
# Simulate Single-Port RAM
iverilog -g2001 -o sim_single_port.vvp rtl/single_port_ram.v tb/tb_single_port_ram.v
vvp sim_single_port.vvp

# Simulate True Dual-Port RAM
iverilog -g2001 -o sim_dual_port.vvp rtl/dual_port_ram.v tb/tb_dual_port_ram.v
vvp sim_dual_port.vvp
```

---

## 🧪 Simulation Output Verification

Both testbenches (`tb_single_port_ram.v` and `tb_dual_port_ram.v`) are **self-checking**, asserting and verifying values with pass/fail telemetry:

```text
==================================================
Starting Single-Port RAM Verification
Configuration: DATA_WIDTH = 8, ADDR_WIDTH = 4, DEPTH = 16
==================================================

--- TEST 1: Sequential Write to All 16 Addresses ---
--- TEST 2: Sequential Read and Verification ---
[PASS]  Addr 0x0 -> Data 0x05 (Match)
[PASS]  Addr 0x1 -> Data 0x16 (Match)
[PASS]  Addr 0x2 -> Data 0x27 (Match)
...
[PASS]  Addr 0xf -> Data 0x04 (Match)

--- TEST 3: Write Disable Check (we = 0) ---
[PASS]  Addr 0x3 -> Data 0x38 (Match)

--- TEST 4: Boundary Address Overwrites (Min & Max) ---
[PASS]  Addr 0x0 -> Data 0xaa (Match)
[PASS]  Addr 0xf -> Data 0x55 (Match)

--- TEST 5: Enable Gating Check (en = 0) ---
[PASS]  Addr 0x7 -> Data 0x7c (Match)

==================================================
Simulation Completed at 460000 ps
Total Assertions Checked: 20
Total Errors Encountered: 0
>>> TEST STATUS: ALL CHECKS PASSED SUCCESSFULLY! <<<
==================================================
```

---

## 📊 FPGA Synthesis & Resource Utilization

The design was synthesized targeting the **Xilinx Artix-7** (`xc7a35tcpg236-1`) FPGA. Full reports are available in the [`reports/`](reports/) directory:

- [Utilization Summary Report](reports/utilization_synth.rpt)
- [Timing Summary Report](reports/timing_synth.rpt)

Summary excerpt:
| Resource | Used | Available | Utilization % |
| :--- | :---: | :---: | :---: |
| **LUT as Memory (Distributed RAM)** | 8 | 9,600 | 0.08% |
| **Slice Registers** | 8 | 41,600 | 0.02% |
| **F7 Muxes** | 4 | 16,300 | 0.02% |
| **F8 Muxes** | 2 | 8,150 | 0.02% |

*(Note: Target resource automatically scales to Block RAM primitives when `RAM_DEPTH` or `DATA_WIDTH` increases or when parameterized with `RAM_STYLE="block"`).*

---

## 📤 Pushing to GitHub

To upload this repository to your GitHub account:

```bash
# 1. Initialize git (if not already initialized)
git init -b main

# 2. Add files and make initial commit
git add .
git commit -m "feat: initial commit for simple memory module"

# 3. Add your GitHub remote repository (replace repository name if different)
git remote add origin https://github.com/abhishek947kumar/simple-memory-module.git

# 4. Push to main branch
git push -u origin main
```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
