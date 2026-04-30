// Testbench for seg7_display.
// Checks every value 0–19: verifies both hex0 (ones) and hex1 (tens).
// Run with any simulator: iverilog / ModelSim / QuestaSim / VCS.
//
//   iverilog -g2012 -o sim seg7_display_tb.sv seg7_display.sv && vvp sim

`timescale 1ns/1ps

module seg7_display_tb;

    // ── DUT signals ──────────────────────────────────────────
    logic [4:0] in;
    logic [6:0] hex0, hex1;

    seg7_display dut (
        .in  (in),
        .hex0(hex0),
        .hex1(hex1)
    );

    // ── Expected 7-seg patterns (active-low, gfedcba) ────────
    localparam [6:0]
        D0     = 7'b1000000,
        D1     = 7'b1111001,
        D2     = 7'b0100100,
        D3     = 7'b0110000,
        D4     = 7'b0011001,
        D5     = 7'b0010010,
        D6     = 7'b0000010,
        D7     = 7'b1111000,
        D8     = 7'b0000000,
        D9     = 7'b0010000,
        BLANK  = 7'b1111111;

    // ── Test state ────────────────────────────────────────────
    int pass_cnt = 0, fail_cnt = 0;

    task automatic check(
        input [4:0] val,
        input [6:0] exp0, exp1
    );
        in = val;
        #5;  // let combinational logic settle
        if (hex0 === exp0 && hex1 === exp1) begin
            $display("PASS  in=%2d  HEX1=%7b  HEX0=%7b", val, hex1, hex0);
            pass_cnt++;
        end else begin
            $display("FAIL  in=%2d  HEX1=%7b (exp %7b)  HEX0=%7b (exp %7b)",
                     val, hex1, exp1, hex0, exp0);
            fail_cnt++;
        end
    endtask

    initial begin
        $display("=== seg7_display testbench ===");
        $display("     in   HEX1(tens)   HEX0(ones)");

        // ── 0–9 : tens digit should be blank ─────────────────
        check( 0, D0, BLANK);
        check( 1, D1, BLANK);
        check( 2, D2, BLANK);
        check( 3, D3, BLANK);
        check( 4, D4, BLANK);
        check( 5, D5, BLANK);
        check( 6, D6, BLANK);
        check( 7, D7, BLANK);
        check( 8, D8, BLANK);
        check( 9, D9, BLANK);

        // ── 10–19 : tens digit should show "1" ───────────────
        check(10, D0, D1);
        check(11, D1, D1);
        check(12, D2, D1);
        check(13, D3, D1);
        check(14, D4, D1);
        check(15, D5, D1);
        check(16, D6, D1);
        check(17, D7, D1);
        check(18, D8, D1);
        check(19, D9, D1);

        // ── Summary ───────────────────────────────────────────
        $display("==============================");
        $display("Result: %0d / %0d passed", pass_cnt, pass_cnt + fail_cnt);
        if (fail_cnt == 0) $display("All tests PASSED.");
        else               $display("%0d test(s) FAILED.", fail_cnt);
        $finish;
    end

endmodule
