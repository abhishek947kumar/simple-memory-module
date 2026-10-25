#!/usr/bin/env bash
# ==============================================================================
# Simple Memory Module - Open Vivado GUI (Linux/macOS)
# ==============================================================================

set -e

# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJ_FILE="${SCRIPT_DIR}/vivado_proj/simple_memory_module.xpr"

# Check Vivado availability
if ! command -v vivado &> /dev/null; then
    echo "[ERROR] 'vivado' command not found in PATH."
    echo "Please source your Vivado settings script first, e.g.:"
    echo "  source /tools/Xilinx/Vivado/<version>/settings64.sh"
    exit 1
fi

if [ ! -f "$PROJ_FILE" ]; then
    echo "Project not found. Creating project first..."
    vivado -mode batch -source "${SCRIPT_DIR}/scripts/create_project.tcl" -nolog -nojournal
fi

echo "Opening project in Vivado GUI..."
vivado "$PROJ_FILE" &
