# Contributing to Simple Memory Module

Thank you for your interest in contributing to the **Simple Memory Module** project! Contributions from the community are warmly welcome.

## Ways to Contribute

1. **Reporting Bugs & Issues**:
   - Open an issue on GitHub detailing the problem.
   - Include Vivado version, operating system, and steps/logs to reproduce.

2. **Feature Additions**:
   - Additional RAM architectures (e.g., Simple Dual-Port RAM, ROM with initialization file `$readmemh`).
   - Alternative read-during-write modes or byte-write enable support (`we [DATA_WIDTH/8-1:0]`).
   - Extended testbenches and edge-case coverage.

3. **Documentation Improvements**:
   - Typos, clarifications, diagrams, or explanations of memory synthesis.

---

## Coding Standards

### Verilog (RTL & Testbenches)
- Use standard **Verilog-2001** constructs for broad synthesis and simulation tool compatibility.
- Ensure all modules are **fully parameterized** (`DATA_WIDTH`, `ADDR_WIDTH`, `RAM_DEPTH`).
- Maintain clear comments explaining memory behavior, clocking, and read/write semantics.
- For synthesis targeting, use standard Vivado attributes:
  ```verilog
  (* ram_style = RAM_STYLE *)
  ```
- Testbenches must be **self-checking**, tracking and reporting:
  - Total assertions checked (`tests`)
  - Total error count (`errors`)
  - Explicit pass/fail banner and `$finish`.

### TCL Scripts
- Use relative path resolution via `[file dirname [info script]]` so scripts are location-independent.
- Avoid machine-specific hardcoded absolute paths.

---

## Submitting a Pull Request (PR)

1. **Fork** the repository and create your feature branch:
   ```bash
   git checkout -b feature/my-new-memory-feature
   ```
2. **Run Simulations**:
   - Verify that all testbenches pass with zero errors:
     ```bash
     # Windows
     run_sim.bat
     # Or Linux / CLI
     vivado -mode batch -source scripts/run_sim.tcl
     ```
3. **Commit your changes**:
   - Follow clear and conventional commit messages:
     ```bash
     git commit -m "feat: add byte-enable write support to single_port_ram"
     ```
4. **Push to GitHub & Open a PR**:
   - Push to your fork and submit a PR to the `main` branch with a description of the changes.
