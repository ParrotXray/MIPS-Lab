// FPGA top-level wrapper for the 5-stage pipelined MIPS processor.
// DE2-115 board:
//   LEDR[9:0]  — lower 10 bits of ALU result
//   HEX0/HEX1 — ALU result[4:0] displayed as decimal (0–19)

module pipeline_mips(
    input  logic        CLOCK_50,
    input  logic        KEY,          // active-low reset
    output logic [9:0]  LEDR,
    output logic [6:0]  HEX0,        // ones digit
    output logic [6:0]  HEX1         // tens digit
);
    logic [31:0] pc_out, alu_out;
    logic        rst;

    assign rst = ~KEY;

    pipeline_top CPU (
        .clk    (CLOCK_50),
        .rst    (rst),
        .pc_out (pc_out),
        .alu_out(alu_out)
    );

    assign LEDR = rst ? '0 : alu_out[9:0];

    // Display ALU result[4:0] (0–19) on 7-segment displays
    seg7_display SEG7 (
        .in  (rst ? 5'd0 : alu_out[4:0]),
        .hex0(HEX0),
        .hex1(HEX1)
    );

endmodule
