// FPGA top-level wrapper for the 5-stage pipelined MIPS processor.
// Maps DE2-115 board signals: 50 MHz clock, KEY[0] as active-low reset,
// LEDR[9:0] displays the lower 10 bits of the current ALU result.

module pipeline_mips(
    input  logic        CLOCK_50,
    input  logic        KEY,         // active-low reset
    output logic [9:0]  LEDR
);
    logic [31:0] pc_out, alu_out;

    pipeline_top CPU (
        .clk    (CLOCK_50),
        .rst    (~KEY),
        .pc_out (pc_out),
        .alu_out(alu_out)
    );

    assign LEDR = (~KEY) ? '0 : alu_out[9:0];

endmodule
