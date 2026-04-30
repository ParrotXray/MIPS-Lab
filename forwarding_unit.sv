// Forwarding unit: resolves EX and MEM data hazards by selecting
// the most recent value for ALU inputs A (rs) and B (rt).
//
// forward_a / forward_b encoding:
//   2'b00 = use register file value from ID/EX (no hazard)
//   2'b10 = forward from EX/MEM (1-cycle-old ALU result)
//   2'b01 = forward from MEM/WB (2-cycle-old result or load data)

module forwarding_unit(
    input  logic [4:0] id_ex_rs,
    input  logic [4:0] id_ex_rt,

    input  logic       ex_mem_reg_write,
    input  logic [4:0] ex_mem_rd,

    input  logic       mem_wb_reg_write,
    input  logic [4:0] mem_wb_rd,

    output logic [1:0] forward_a,
    output logic [1:0] forward_b
);
    always_comb begin
        // EX hazard takes priority over MEM hazard
        if (ex_mem_reg_write && ex_mem_rd != '0 && ex_mem_rd == id_ex_rs)
            forward_a = 2'b10;
        else if (mem_wb_reg_write && mem_wb_rd != '0 && mem_wb_rd == id_ex_rs)
            forward_a = 2'b01;
        else
            forward_a = 2'b00;

        if (ex_mem_reg_write && ex_mem_rd != '0 && ex_mem_rd == id_ex_rt)
            forward_b = 2'b10;
        else if (mem_wb_reg_write && mem_wb_rd != '0 && mem_wb_rd == id_ex_rt)
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end

endmodule
