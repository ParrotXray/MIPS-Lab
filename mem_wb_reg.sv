// MEM/WB pipeline register

module mem_wb_reg(
    input  logic        clk, rst,

    // WB-stage control
    input  logic        mem_reg_write,
    input  logic        mem_mem_to_reg,
    // Data
    input  logic [31:0] mem_read_data,
    input  logic [31:0] mem_alu_result,
    input  logic [4:0]  mem_write_reg,

    output logic        wb_reg_write,
    output logic        wb_mem_to_reg,
    output logic [31:0] wb_read_data,
    output logic [31:0] wb_alu_result,
    output logic [4:0]  wb_write_reg
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            {wb_reg_write, wb_mem_to_reg} <= '0;
            wb_read_data  <= '0;
            wb_alu_result <= '0;
            wb_write_reg  <= '0;
        end else begin
            wb_reg_write  <= mem_reg_write;
            wb_mem_to_reg <= mem_mem_to_reg;
            wb_read_data  <= mem_read_data;
            wb_alu_result <= mem_alu_result;
            wb_write_reg  <= mem_write_reg;
        end
    end

endmodule
