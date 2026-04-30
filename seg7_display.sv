// 7-segment display decoder for a 2-digit decimal value (0 – 19).
// Outputs use active-low encoding (0 = segment ON) matching DE2-115 HEX ports.
//
// Segment bit order: [6:0] = gfedcba
//
//      aaa
//     f   b
//     f   b
//      ggg
//     e   c
//     e   c
//      ddd
//
// hex0 = ones digit  (in %  10)
// hex1 = tens digit  (in / 10) — blank when 0, shows "1" when 1

module seg7_display(
    input  logic [4:0] in,     // value 0–19
    output logic [6:0] hex0,   // ones digit
    output logic [6:0] hex1    // tens digit
);
    always @(*) begin
        // ── ones digit ──────────────────────────────────────
        if      (in % 10 == 0) hex0 = 7'b1000000;  // 0
        else if (in % 10 == 1) hex0 = 7'b1111001;  // 1
        else if (in % 10 == 2) hex0 = 7'b0100100;  // 2
        else if (in % 10 == 3) hex0 = 7'b0110000;  // 3
        else if (in % 10 == 4) hex0 = 7'b0011001;  // 4
        else if (in % 10 == 5) hex0 = 7'b0010010;  // 5
        else if (in % 10 == 6) hex0 = 7'b0000010;  // 6
        else if (in % 10 == 7) hex0 = 7'b1111000;  // 7
        else if (in % 10 == 8) hex0 = 7'b0000000;  // 8
        else                   hex0 = 7'b0010000;  // 9

        // ── tens digit ──────────────────────────────────────
        if (in / 10 == 0) hex1 = 7'b1111111;  // blank
        else              hex1 = 7'b1111001;  // 1
    end

endmodule
