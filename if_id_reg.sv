// IF/ID pipeline register
// write=0 : hold (stall — PC and IF/ID frozen together)
// flush=1 : insert NOP (branch/jump redirect; overrides write)

module if_id_reg(
    input  logic        clk, rst,
    input  logic        write,
    input  logic        flush,
    input  logic [31:0] if_pc4,
    input  logic [31:0] if_instr,
    output logic [31:0] id_pc4,
    output logic [31:0] id_instr
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst || flush) begin
            id_pc4   <= '0;
            id_instr <= '0;
        end else if (write) begin
            id_pc4   <= if_pc4;
            id_instr <= if_instr;
        end
        // else: hold (stall)
    end

endmodule
