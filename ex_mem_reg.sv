// EX/MEM pipeline register
// Branch/jump are resolved at the end of EX, so only memory and
// WB control signals need to flow past this boundary.

module ex_mem_reg(
    input  logic        clk, rst,

    // WB-stage control
    input  logic        ex_reg_write,
    input  logic        ex_mem_to_reg,
    // MEM-stage control
    input  logic        ex_mem_read,
    input  logic        ex_mem_write,
    // Data
    input  logic [31:0] ex_alu_result,
    input  logic [31:0] ex_write_data,   // forwarded rt value (for SW)
    input  logic [4:0]  ex_write_reg,

    // WB-stage control
    output logic        mem_reg_write,
    output logic        mem_mem_to_reg,
    // MEM-stage control
    output logic        mem_mem_read,
    output logic        mem_mem_write,
    // Data
    output logic [31:0] mem_alu_result,
    output logic [31:0] mem_write_data,
    output logic [4:0]  mem_write_reg
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            {mem_reg_write, mem_mem_to_reg,
             mem_mem_read,  mem_mem_write} <= '0;
            mem_alu_result <= '0;
            mem_write_data <= '0;
            mem_write_reg  <= '0;
        end else begin
            mem_reg_write  <= ex_reg_write;
            mem_mem_to_reg <= ex_mem_to_reg;
            mem_mem_read   <= ex_mem_read;
            mem_mem_write  <= ex_mem_write;
            mem_alu_result <= ex_alu_result;
            mem_write_data <= ex_write_data;
            mem_write_reg  <= ex_write_reg;
        end
    end

endmodule
