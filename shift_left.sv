module shift_left #(
    parameter SHIFT  = 2,
    parameter IN_W = 32,
    parameter OUT_W = IN_W + SHIFT
) (
    input  logic [IN_W-1:0] in,
    output logic [OUT_W-1:0] out
);
    assign out = in << SHIFT;
endmodule