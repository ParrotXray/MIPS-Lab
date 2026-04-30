module alu(
    input  logic [31:0] a, b,
    input  logic [4:0]  shamt,
    input  logic [3:0]  alu_ctrl,
    output logic [31:0] result,
    output logic        zero
);
    // alu_ctrl encoding:
    //   0000 = AND
    //   0001 = OR
    //   0010 = ADD
    //   0011 = XOR
    //   0110 = SUB
    //   0111 = SLT  (signed)
    //   1000 = SLL  b << shamt
    //   1001 = SRL  b >> shamt  (logical)
    //   1010 = SRA  b >>> shamt (arithmetic)
    //   1011 = LUI  {b[15:0], 16'b0}
    //   1100 = NOR

    always_comb begin
        case(alu_ctrl)
            4'b0000: result = a & b;
            4'b0001: result = a | b;
            4'b0010: result = a + b;
            4'b0011: result = a ^ b;
            4'b0110: result = a - b;
            4'b0111: result = ($signed(a) < $signed(b)) ? 32'd1 : '0;
            4'b1000: result = b << shamt;
            4'b1001: result = b >> shamt;
            4'b1010: result = 32'($signed(b) >>> shamt);
            4'b1011: result = {b[15:0], 16'b0};
            4'b1100: result = ~(a | b);
            default: result = '0;
        endcase
    end

    assign zero = (result == '0);

endmodule
