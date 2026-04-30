module jr_control(
    input  logic [5:0] instr_low,
    input  logic [2:0] alu_op,
    output logic       jr
);
    assign jr = (alu_op == 3'b010) && (instr_low == 6'b001000);

endmodule
