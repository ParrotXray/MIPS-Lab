// ID/EX pipeline register
// flush=1 : insert NOP bubble (stall or branch/jump redirect)
// Carries all control signals and data from ID stage into EX stage.

module id_ex_reg(
    input  logic        clk, rst, flush,

    // WB-stage control
    input  logic        id_reg_write,
    input  logic        id_mem_to_reg,
    // MEM-stage control
    input  logic        id_branch,
    input  logic        id_bne,
    input  logic        id_mem_read,
    input  logic        id_mem_write,
    input  logic        id_jump,
    input  logic        id_jr,
    // EX-stage control
    input  logic        id_reg_dst,
    input  logic        id_alu_src,
    input  logic        id_sign_zero,
    input  logic [2:0]  id_alu_op,
    // Data
    input  logic [31:0] id_pc4,
    input  logic [31:0] id_read_data_1,
    input  logic [31:0] id_read_data_2,
    input  logic [31:0] id_sign_imm,
    input  logic [31:0] id_zero_imm,
    input  logic [31:0] id_jump_target,
    input  logic [5:0]  id_funct,
    input  logic [4:0]  id_shamt,
    input  logic [4:0]  id_rs,
    input  logic [4:0]  id_rt,
    input  logic [4:0]  id_rd,

    // WB-stage control
    output logic        ex_reg_write,
    output logic        ex_mem_to_reg,
    // MEM-stage control
    output logic        ex_branch,
    output logic        ex_bne,
    output logic        ex_mem_read,
    output logic        ex_mem_write,
    output logic        ex_jump,
    output logic        ex_jr,
    // EX-stage control
    output logic        ex_reg_dst,
    output logic        ex_alu_src,
    output logic        ex_sign_zero,
    output logic [2:0]  ex_alu_op,
    // Data
    output logic [31:0] ex_pc4,
    output logic [31:0] ex_read_data_1,
    output logic [31:0] ex_read_data_2,
    output logic [31:0] ex_sign_imm,
    output logic [31:0] ex_zero_imm,
    output logic [31:0] ex_jump_target,
    output logic [5:0]  ex_funct,
    output logic [4:0]  ex_shamt,
    output logic [4:0]  ex_rs,
    output logic [4:0]  ex_rt,
    output logic [4:0]  ex_rd
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            // Zero all control signals → NOP bubble
            {ex_reg_write, ex_mem_to_reg,
             ex_branch, ex_bne, ex_mem_read, ex_mem_write,
             ex_jump, ex_jr,
             ex_reg_dst, ex_alu_src, ex_sign_zero} <= '0;
            ex_alu_op      <= '0;
            ex_pc4         <= '0;
            ex_read_data_1 <= '0;
            ex_read_data_2 <= '0;
            ex_sign_imm    <= '0;
            ex_zero_imm    <= '0;
            ex_jump_target <= '0;
            ex_funct       <= '0;
            ex_shamt       <= '0;
            ex_rs <= '0; ex_rt <= '0; ex_rd <= '0;
        end else begin
            ex_reg_write   <= id_reg_write;
            ex_mem_to_reg  <= id_mem_to_reg;
            ex_branch      <= id_branch;
            ex_bne         <= id_bne;
            ex_mem_read    <= id_mem_read;
            ex_mem_write   <= id_mem_write;
            ex_jump        <= id_jump;
            ex_jr          <= id_jr;
            ex_reg_dst     <= id_reg_dst;
            ex_alu_src     <= id_alu_src;
            ex_sign_zero   <= id_sign_zero;
            ex_alu_op      <= id_alu_op;
            ex_pc4         <= id_pc4;
            ex_read_data_1 <= id_read_data_1;
            ex_read_data_2 <= id_read_data_2;
            ex_sign_imm    <= id_sign_imm;
            ex_zero_imm    <= id_zero_imm;
            ex_jump_target <= id_jump_target;
            ex_funct       <= id_funct;
            ex_shamt       <= id_shamt;
            ex_rs          <= id_rs;
            ex_rt          <= id_rt;
            ex_rd          <= id_rd;
        end
    end

endmodule
