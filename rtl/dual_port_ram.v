`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026-10-23
// Design Name: Simple Memory Module
// Module Name: dual_port_ram
// Project Name: Parameterized True Dual-Port RAM
// Target Devices: Xilinx 7-Series / UltraScale (Vivado)
// Tool Versions: Vivado 2019.2+
// Description:
//   A parameterized, synthesizable True Dual-Port Synchronous RAM in Verilog.
//   Provides two fully independent ports (Port A and Port B), capable of 
//   simultaneous read and write operations at independent addresses and clocks.
//
// Key Concepts Demonstrated:
//   1. Multi-port memory representation in RTL
//   2. Independent address decoders and data buses
//   3. Synthesis into dual-port Xilinx Block RAM (BRAM primitives)
//////////////////////////////////////////////////////////////////////////////////

module dual_port_ram #(
    parameter integer DATA_WIDTH = 8,                 // Word width in bits
    parameter integer ADDR_WIDTH = 6,                 // Address bus width (2^6 = 64 words)
    parameter integer RAM_DEPTH  = (1 << ADDR_WIDTH), // Total memory entries
    parameter         RAM_STYLE  = "block"            // "block" or "distributed"
)(
    // Port A Interface
    input  wire                  clk_a,
    input  wire                  en_a,
    input  wire                  we_a,
    input  wire [ADDR_WIDTH-1:0] addr_a,
    input  wire [DATA_WIDTH-1:0] din_a,
    output reg  [DATA_WIDTH-1:0] dout_a,

    // Port B Interface
    input  wire                  clk_b,
    input  wire                  en_b,
    input  wire                  we_b,
    input  wire [ADDR_WIDTH-1:0] addr_b,
    input  wire [DATA_WIDTH-1:0] din_b,
    output reg  [DATA_WIDTH-1:0] dout_b
);

    // Shared Memory Array
    (* ram_style = RAM_STYLE *)
    reg [DATA_WIDTH-1:0] mem [0:RAM_DEPTH-1];

    // Port A Operation (Read-First)
    always @(posedge clk_a) begin
        if (en_a) begin
            if (we_a) begin
                mem[addr_a] <= din_a;
            end
            dout_a <= mem[addr_a];
        end
    end

    // Port B Operation (Read-First)
    always @(posedge clk_b) begin
        if (en_b) begin
            if (we_b) begin
                mem[addr_b] <= din_b;
            end
            dout_b <= mem[addr_b];
        end
    end

endmodule
