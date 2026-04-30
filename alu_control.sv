module alu_control(
    input  logic [2:0] alu_op,
    input  logic [5:0] funct,
    output logic [3:0] alu_ctrl
);
    // alu_op encoding:
    //   000 = ADD  (LW, SW, ADDI)
    //   001 = SUB  (BEQ, BNE)
    //   010 = R-type (use funct)
    //   011 = SLT  (SLTI)
    //   100 = OR   (ORI)
    //   101 = AND  (ANDI)
    //   110 = XOR  (XORI)
    //   111 = LUI

    always_comb begin
        case(alu_op)
            3'b000: alu_ctrl = 4'b0010; // ADD
            3'b001: alu_ctrl = 4'b0110; // SUB
            3'b011: alu_ctrl = 4'b0111; // SLT  (SLTI)
            3'b100: alu_ctrl = 4'b0001; // OR   (ORI)
            3'b101: alu_ctrl = 4'b0000; // AND  (ANDI)
            3'b110: alu_ctrl = 4'b0011; // XOR  (XORI)
            3'b111: alu_ctrl = 4'b1011; // LUI

            3'b010: begin // R-type: decode funct
                case(funct)
                    6'b100000: alu_ctrl = 4'b0010; // ADD
                    6'b100010: alu_ctrl = 4'b0110; // SUB
                    6'b100100: alu_ctrl = 4'b0000; // AND
                    6'b100101: alu_ctrl = 4'b0001; // OR
                    6'b100110: alu_ctrl = 4'b0011; // XOR
                    6'b101010: alu_ctrl = 4'b0111; // SLT
                    6'b100111: alu_ctrl = 4'b1100; // NOR
                    6'b000000: alu_ctrl = 4'b1000; // SLL
                    6'b000010: alu_ctrl = 4'b1001; // SRL
                    6'b000011: alu_ctrl = 4'b1010; // SRA
                    default:   alu_ctrl = 4'b0010;
                endcase
            end

            default: alu_ctrl = 4'b0010;
        endcase
    end

endmodule
