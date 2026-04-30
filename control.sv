typedef enum logic [5:0] {
    OP_RTYPE = 6'b000000,
    OP_LW    = 6'b100011,
    OP_SW    = 6'b101011,
    OP_BEQ   = 6'b000100,
    OP_J     = 6'b000010,
    OP_ADDI  = 6'b001000,
    OP_ORI   = 6'b001101
} opcode_t;

module control(
    input  logic [5:0] opcode,
    output logic [1:0] alu_op,
    output logic reg_dst, branch, mem_read, jump,
    output logic mem_to_reg, mem_write, alu_src, reg_write,
    output logic sign_zero   // 0=sign extend, 1=zero extend
);
    always_comb begin
        {reg_dst, alu_src, mem_to_reg, reg_write,
         mem_read, mem_write, branch, jump, sign_zero} = '0;
        alu_op = '0;

        case(opcode)
            OP_RTYPE: begin
                reg_dst = 1; reg_write = 1; alu_op = 2'b10;
            end
            OP_LW: begin
                alu_src = 1; mem_to_reg = 1;
                reg_write = 1; mem_read = 1; alu_op = 2'b00;
            end
            OP_SW: begin
                alu_src = 1; mem_write = 1; alu_op = 2'b00;
            end
            OP_BEQ: begin
                branch = 1; alu_op = 2'b01;
            end
            OP_J: begin
                jump = 1;
            end
            OP_ADDI: begin  // sign extend
                alu_src = 1; reg_write = 1; alu_op = 2'b00;
            end
            OP_ORI: begin   // zero extend
                alu_src = 1; reg_write = 1;
                alu_op = 2'b00; sign_zero = 1;
            end
        endcase
    end
endmodule