`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026-10-23
// Design Name: Simple Memory Module
// Module Name: tb_single_port_ram
// Project Name: Parameterized Single-Port RAM Testbench
// Target Devices: Vivado Simulator (XSim)
// Tool Versions: Vivado 2019.2+
// Description:
//   Self-checking behavioral testbench for single_port_ram module.
//   Verifies:
//     - Full memory address write and read verification
//     - Data retention when write_enable = 0
//     - Enable gating (en = 0)
//     - Overwrite capabilities at min and max boundary addresses
//////////////////////////////////////////////////////////////////////////////////

module tb_single_port_ram;

    // Parameters for DUT
    localparam DATA_WIDTH = 8;
    localparam ADDR_WIDTH = 4; // 16 memory locations for quick thorough test
    localparam RAM_DEPTH  = (1 << ADDR_WIDTH);
    localparam CLK_PERIOD = 10; // 100 MHz clock

    // DUT Interface Signals
    reg                   clk;
    reg                   en;
    reg                   we;
    reg  [ADDR_WIDTH-1:0] addr;
    reg  [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;

    // Test tracking
    integer errors = 0;
    integer tests  = 0;
    integer i;

    // Shadow memory array for verification
    reg [DATA_WIDTH-1:0] shadow_mem [0:RAM_DEPTH-1];

    // Instantiate Device Under Test (DUT)
    single_port_ram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH),
        .RAM_DEPTH(RAM_DEPTH),
        .RAM_STYLE("auto"),
        .WRITE_MODE("READ_FIRST")
    ) dut (
        .clk (clk),
        .en  (en),
        .we  (we),
        .addr(addr),
        .din (din),
        .dout(dout)
    );

    // Clock Generation: 100 MHz (5ns High, 5ns Low)
    always #(CLK_PERIOD / 2) clk = ~clk;

    // Helper task to write data to an address
    task write_mem(input [ADDR_WIDTH-1:0] target_addr, input [DATA_WIDTH-1:0] target_data);
    begin
        @(posedge clk);
        en   <= 1'b1;
        we   <= 1'b1;
        addr <= target_addr;
        din  <= target_data;
        shadow_mem[target_addr] = target_data;
    end
    endtask

    // Helper task to read data from an address and verify against expected
    task read_and_check(input [ADDR_WIDTH-1:0] target_addr, input [DATA_WIDTH-1:0] expected_data);
    begin
        @(posedge clk);
        en   <= 1'b1;
        we   <= 1'b0;
        addr <= target_addr;
        din  <= {DATA_WIDTH{1'bx}}; // Garbage on data input
        
        // Wait 1 cycle for synchronous read output
        @(posedge clk);
        #1; // Sample shortly after clock edge
        tests = tests + 1;
        if (dout !== expected_data) begin
            $display("[ERROR] Time %0t ps: Addr 0x%0h - Expected 0x%0h, Got 0x%0h", 
                     $time, target_addr, expected_data, dout);
            errors = errors + 1;
        end else begin
            $display("[PASS]  Addr 0x%0h -> Data 0x%02h (Match)", target_addr, dout);
        end
    end
    endtask

    // Main Test Stimulus
    initial begin
        $display("==================================================");
        $display("Starting Single-Port RAM Verification");
        $display("Configuration: DATA_WIDTH = %0d, ADDR_WIDTH = %0d, DEPTH = %0d", 
                 DATA_WIDTH, ADDR_WIDTH, RAM_DEPTH);
        $display("==================================================");

        // 1. Initial Reset / Idle State
        clk  = 1'b0;
        en   = 1'b0;
        we   = 1'b0;
        addr = 0;
        din  = 0;
        #(CLK_PERIOD * 2);

        // -----------------------------------------------------------------
        // TEST 1: Full Range Memory Write
        // -----------------------------------------------------------------
        $display("\n--- TEST 1: Sequential Write to All %0d Addresses ---", RAM_DEPTH);
        for (i = 0; i < RAM_DEPTH; i = i + 1) begin
            write_mem(i[ADDR_WIDTH-1:0], (i * 8'h11 + 8'h05) & 8'hFF);
        end

        // Return to idle
        @(posedge clk);
        en <= 1'b0;
        we <= 1'b0;
        #(CLK_PERIOD);

        // -----------------------------------------------------------------
        // TEST 2: Full Range Memory Read & Self-Check
        // -----------------------------------------------------------------
        $display("\n--- TEST 2: Sequential Read and Verification ---");
        for (i = 0; i < RAM_DEPTH; i = i + 1) begin
            read_and_check(i[ADDR_WIDTH-1:0], shadow_mem[i]);
        end

        // -----------------------------------------------------------------
        // TEST 3: Non-destructive Read (we = 0 retains memory)
        // -----------------------------------------------------------------
        $display("\n--- TEST 3: Write Disable Check (we = 0) ---");
        @(posedge clk);
        en   <= 1'b1;
        we   <= 1'b0;       // Write disabled
        addr <= 4'h3;
        din  <= 8'hFF;      // Attempt to overwrite with 0xFF
        @(posedge clk);
        #1;
        // Verify address 3 still holds original shadow value
        read_and_check(4'h3, shadow_mem[3]);

        // -----------------------------------------------------------------
        // TEST 4: Boundary Address Overwrite
        // -----------------------------------------------------------------
        $display("\n--- TEST 4: Boundary Address Overwrites (Min & Max) ---");
        // Overwrite Address 0
        write_mem(4'h0, 8'hAA);
        read_and_check(4'h0, 8'hAA);

        // Overwrite Address (RAM_DEPTH - 1)
        write_mem(RAM_DEPTH - 1, 8'h55);
        read_and_check(RAM_DEPTH - 1, 8'h55);

        // -----------------------------------------------------------------
        // TEST 5: Chip Enable Gating (en = 0)
        // -----------------------------------------------------------------
        $display("\n--- TEST 5: Enable Gating Check (en = 0) ---");
        @(posedge clk);
        en   <= 1'b0; // Disabled
        we   <= 1'b1;
        addr <= 4'h7;
        din  <= 8'hEE; // Should NOT be written
        @(posedge clk);
        
        // Re-enable and verify address 7 is unchanged
        read_and_check(4'h7, shadow_mem[7]);

        // -----------------------------------------------------------------
        // Summary
        // -----------------------------------------------------------------
        $display("\n==================================================");
        $display("Simulation Completed at %0t ps", $time);
        $display("Total Assertions Checked: %0d", tests);
        $display("Total Errors Encountered: %0d", errors);
        if (errors == 0) begin
            $display(">>> TEST STATUS: ALL CHECKS PASSED SUCCESSFULLY! <<<");
        end else begin
            $display(">>> TEST STATUS: FAILED WITH %0d ERROR(S) <<<", errors);
        end
        $display("==================================================");

        #(CLK_PERIOD * 2);
        $finish;
    end

endmodule
