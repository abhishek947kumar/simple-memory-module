`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026-10-23
// Design Name: Simple Memory Module
// Module Name: single_port_ram
// Project Name: Parameterized Single-Port RAM
// Target Devices: Xilinx 7-Series / UltraScale (Vivado)
// Tool Versions: Vivado 2019.2+
// Description:
//   A parameterized, synthesizable Single-Port Synchronous RAM in Verilog.
//   Supports configurable data width, address width, and read-during-write
//   behavior (Read-First vs Write-First).
//
// Key Concepts Demonstrated:
//   1. Memory Array Declaration: [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1]
//   2. Addressing: ADDR_WIDTH determines RAM_DEPTH = 2^ADDR_WIDTH
//   3. Synchronous Writes: Data written on clock positive edge when we=1
//   4. Synchronous Reads: Data output registered on clock positive edge
//   5. Synthesis Attributes: (* ram_style *) for Vivado BRAM vs LUTRAM inference
//////////////////////////////////////////////////////////////////////////////////

module single_port_ram #(
    parameter integer DATA_WIDTH = 8,                 // Word width in bits
    parameter integer ADDR_WIDTH = 6,                 // Address bus width (2^6 = 64 words)
    parameter integer RAM_DEPTH  = (1 << ADDR_WIDTH), // Total memory entries
    parameter         RAM_STYLE  = "auto",            // "auto", "block", or "distributed"
    parameter         WRITE_MODE = "READ_FIRST"       // "READ_FIRST", "WRITE_FIRST", "NO_CHANGE"
)(
    input  wire                  clk,   // System clock
    input  wire                  en,    // RAM enable (chip select)
    input  wire                  we,    // Write enable (1 = Write, 0 = Read)
    input  wire [ADDR_WIDTH-1:0] addr,  // Address bus input
    input  wire [DATA_WIDTH-1:0] din,   // Data bus input
    output reg  [DATA_WIDTH-1:0] dout   // Synchronous data bus output
);

    // =========================================================================
    // Vivado Synthesis Attribute:
    // "block"       -> Forces Vivado to infer dedicated Block RAM (BRAM)
    // "distributed" -> Forces Vivado to infer Slice LUTs (Distributed RAM)
    // "auto"        -> Allows Vivado synthesis engine to choose optimal resource
    // =========================================================================
    (* ram_style = RAM_STYLE *)
    reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

    // =========================================================================
    // Memory Behavior Implementation
    //
    // Mode 1: READ_FIRST (Xilinx BRAM Native/Default Mode)
    //   On a write cycle (we=1), the previous content of mem[addr] is presented
    //   at dout, while din is written into mem[addr].
    //
    // Mode 2: WRITE_FIRST (Transparent Mode)
    //   On a write cycle (we=1), din is written into mem[addr] and simultaneously
    //   reflected at dout on the same clock cycle.
    //
    // Mode 3: NO_CHANGE
    //   On a write cycle (we=1), dout retains its previous output value.
    // =========================================================================
    generate
        if (WRITE_MODE == "READ_FIRST") begin : gen_read_first
            always @(posedge clk) begin
                if (en) begin
                    if (we) begin
                        mem[addr] <= din;
                    end
                    dout <= mem[addr]; // Read previous memory content
                end
            end
        end
        else if (WRITE_MODE == "WRITE_FIRST") begin : gen_write_first
            always @(posedge clk) begin
                if (en) begin
                    if (we) begin
                        mem[addr] <= din;
                        dout      <= din; // Immediately output written data
                    end else begin
                        dout      <= mem[addr];
                    end
                end
            end
        end
        else if (WRITE_MODE == "NO_CHANGE") begin : gen_no_change
            always @(posedge clk) begin
                if (en) begin
                    if (we) begin
                        mem[addr] <= din; // dout does not update on writes
                    end else begin
                        dout      <= mem[addr];
                    end
                end
            end
        end
        else begin : gen_default
            // Fallback default: READ_FIRST
            always @(posedge clk) begin
                if (en) begin
                    if (we) begin
                        mem[addr] <= din;
                    end
                    dout <= mem[addr];
                end
            end
        end
    endgenerate

endmodule
