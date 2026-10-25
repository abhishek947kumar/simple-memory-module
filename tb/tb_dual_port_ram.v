`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026-10-23
// Design Name: Simple Memory Module
// Module Name: tb_dual_port_ram
// Project Name: Parameterized Dual-Port RAM Testbench
// Target Devices: Vivado Simulator (XSim)
// Tool Versions: Vivado 2019.2+
// Description:
//   Self-checking behavioral testbench for dual_port_ram module.
//   Verifies concurrent independent operations on Port A and Port B.
//////////////////////////////////////////////////////////////////////////////////

module tb_dual_port_ram;

    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4;
    localparam RAM_DEPTH  = (1 << ADDR_WIDTH);
    localparam CLK_PERIOD = 10;

    // Port A signals
    reg                   clk_a;
    reg                   en_a;
    reg                   we_a;
    reg  [ADDR_WIDTH-1:0] addr_a;
    reg  [DATA_WIDTH-1:0] din_a;
    wire [DATA_WIDTH-1:0] dout_a;

    // Port B signals
    reg                   clk_b;
    reg                   en_b;
    reg                   we_b;
    reg  [ADDR_WIDTH-1:0] addr_b;
    reg  [DATA_WIDTH-1:0] din_b;
    wire [DATA_WIDTH-1:0] dout_b;

    integer errors = 0;
    integer tests  = 0;

    // Instantiate Dual-Port RAM
    dual_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .RAM_DEPTH(RAM_DEPTH),
        .RAM_STYLE("block")
    ) dut (
        .clk_a (clk_a),
        .en_a  (en_a),
        .we_a  (we_a),
        .addr_a(addr_a),
        .din_a (din_a),
        .dout_a(dout_a),

        .clk_b (clk_b),
        .en_b  (en_b),
        .we_b  (we_b),
        .addr_b(addr_b),
        .din_b (din_b),
        .dout_b(dout_b)
    );

    // Clock Generation
    always #(CLK_PERIOD / 2) clk_a = ~clk_a;
    always #(CLK_PERIOD / 2) clk_b = ~clk_b;

    initial begin
        clk_a = 0;
        clk_b = 0;
        en_a  = 0;
        we_a  = 0;
        addr_a = 0;
        din_a = 0;
        en_b  = 0;
        we_b  = 0;
        addr_b = 0;
        din_b = 0;
        #(CLK_PERIOD * 2);

        $display("==================================================");
        $display("Starting Dual-Port RAM Verification");
        $display("==================================================");

        // TEST 1: Write through Port A, then read back through Port B
        $display("\n--- TEST 1: Write Port A (Addr 0x2 -> 0x3C), Read Port B ---");
        @(posedge clk_a);
        en_a   <= 1'b1;
        we_a   <= 1'b1;
        addr_a <= 4'h2;
        din_a  <= 8'h3C;

        @(posedge clk_a);
        en_a   <= 1'b0;
        we_a   <= 1'b0;

        // Read via Port B
        @(posedge clk_b);
        en_b   <= 1'b1;
        we_b   <= 1'b0;
        addr_b <= 4'h2;

        @(posedge clk_b);
        #1;
        tests = tests + 1;
        if (dout_b !== 8'h3C) begin
            $display("[ERROR] Port B expected 0x3C, got 0x%02h", dout_b);
            errors = errors + 1;
        end else begin
            $display("[PASS]  Port B read correctly from Port A write: 0x%02h", dout_b);
        end

        // TEST 2: Simultaneous independent write on Port A & Port B to different addresses
        $display("\n--- TEST 2: Concurrent Writes: Port A (Addr 0x4 -> 0xAA) & Port B (Addr 0x5 -> 0x55) ---");
        @(posedge clk_a);
        en_a   <= 1'b1;
        we_a   <= 1'b1;
        addr_a <= 4'h4;
        din_a  <= 8'hAA;

        en_b   <= 1'b1;
        we_b   <= 1'b1;
        addr_b <= 4'h5;
        din_b  <= 8'h55;

        @(posedge clk_a);
        we_a   <= 1'b0;
        we_b   <= 1'b0;

        // Now read Port A from 0x5 and Port B from 0x4
        addr_a <= 4'h5;
        addr_b <= 4'h4;

        @(posedge clk_a);
        #1;
        tests = tests + 2;
        if (dout_a !== 8'h55) begin
            $display("[ERROR] Cross-read Port A expected 0x55, got 0x%02h", dout_a);
            errors = errors + 1;
        end else begin
            $display("[PASS]  Cross-read Port A got 0x55");
        end

        if (dout_b !== 8'hAA) begin
            $display("[ERROR] Cross-read Port B expected 0xAA, got 0x%02h", dout_b);
            errors = errors + 1;
        end else begin
            $display("[PASS]  Cross-read Port B got 0xAA");
        end

        $display("\n==================================================");
        $display("Dual-Port Tests Checked: %0d, Errors: %0d", tests, errors);
        if (errors == 0) begin
            $display(">>> DUAL-PORT RAM TESTS PASSED! <<<");
        end else begin
            $display(">>> DUAL-PORT RAM TESTS FAILED! <<<");
        end
        $display("==================================================");

        #(CLK_PERIOD * 2);
        $finish;
    end

endmodule
