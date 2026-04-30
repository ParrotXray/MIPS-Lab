typedef enum logic [5:0] {
    OP_RTYPE = 6'b000000,
    OP_LW    = 6'b100011,
    OP_SW    = 6'b101011,
    OP_BEQ   = 6'b000100,
    OP_BNE   = 6'b000101,
    OP_J     = 6'b000010,
    OP_ADDI  = 6'b001000,
    OP_SLTI  = 6'b001010,
    OP_ANDI  = 6'b001100,
    OP_ORI   = 6'b001101,
    OP_XORI  = 6'b001110,
    OP_LUI   = 6'b001111
} opcode_t;

module control(
    input  logic [5:0] opcode,
    output logic [2:0] alu_op,
    output logic reg_dst, branch, bne, mem_read, jump,
    output logic mem_to_reg, mem_write, alu_src, reg_write,
    output logic sign_zero   // 0=sign extend, 1=zero extend
);
    always_comb begin
        {reg_dst, alu_src, mem_to_reg, reg_write,
         mem_read, mem_write, branch, bne, jump, sign_zero} = '0;
        alu_op = '0;

        case(opcode)
            OP_RTYPE: begin
                reg_dst = 1; reg_write = 1; alu_op = 3'b010;
            end
            OP_LW: begin
                alu_src = 1; mem_to_reg = 1;
                reg_write = 1; mem_read = 1;
            end
            OP_SW: begin
                alu_src = 1; mem_write = 1;
            end
            OP_BEQ: begin
                branch = 1; alu_op = 3'b001;
            end
            OP_BNE: begin
                bne = 1; alu_op = 3'b001;
            end
            OP_J: begin
                jump = 1;
            end
            OP_ADDI: begin
                alu_src = 1; reg_write = 1;
            end
            OP_SLTI: begin
                alu_src = 1; reg_write = 1; alu_op = 3'b011;
            end
            OP_ANDI: begin
                alu_src = 1; reg_write = 1; sign_zero = 1; alu_op = 3'b101;
            end
            OP_ORI: begin
                alu_src = 1; reg_write = 1; sign_zero = 1; alu_op = 3'b100;
            end
            OP_XORI: begin
                alu_src = 1; reg_write = 1; sign_zero = 1; alu_op = 3'b110;
            end
            OP_LUI: begin
                alu_src = 1; reg_write = 1; sign_zero = 1; alu_op = 3'b111;
            end
        endcase
    end
endmodule
