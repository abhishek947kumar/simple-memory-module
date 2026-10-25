#!/usr/bin/env bash
# ==============================================================================
# Simple Memory Module - Behavioral Simulation Runner (Linux/macOS)
# ==============================================================================

set -e

# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check Vivado availability
if ! command -v vivado &> /dev/null; then
    echo "[ERROR] 'vivado' command not found in PATH."
    echo "Please source your Vivado settings script first, e.g.:"
    echo "  source /tools/Xilinx/Vivado/<version>/settings64.sh"
    exit 1
fi

echo "=============================================================="
echo "Running Simple Memory Module Behavioral Simulation in Vivado"
echo "=============================================================="

vivado -mode batch -source "${SCRIPT_DIR}/scripts/run_sim.tcl" -nolog -nojournal

echo "=============================================================="
echo "Simulation finished successfully."
echo "=============================================================="
