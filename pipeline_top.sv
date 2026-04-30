// 5-stage pipelined MIPS processor: IF → ID → EX → MEM → WB
//
// Hazard handling:
//   • Load-use stall  : hazard_unit freezes PC + IF/ID, inserts NOP into ID/EX
//   • Data forwarding : forwarding_unit handles EX-EX and MEM-EX paths
//   • WB→ID forward  : inline bypass when WB writes while ID reads same register
//   • Branch / Jump / JR resolved at end of EX; flush IF/ID and ID/EX

module pipeline_top(
    input  logic        clk, rst,
    output logic [31:0] pc_out,
    output logic [31:0] alu_out
);
    // =========================================================
    // IF STAGE SIGNALS
    // =========================================================
    logic [31:0] pc_reg, pc_next, pc_plus_4;
    logic [31:0] if_instr;

    // =========================================================
    // IF/ID REGISTER OUTPUTS  (= ID stage inputs)
    // =========================================================
    logic [31:0] id_pc4, id_instr;

    // =========================================================
    // ID STAGE SIGNALS
    // =========================================================
    logic [4:0]  id_rs, id_rt, id_rd, id_shamt;
    logic [5:0]  id_funct;
    logic [15:0] id_imm16;

    // control signals
    logic [2:0]  id_alu_op;
    logic        id_reg_dst, id_alu_src, id_sign_zero;
    logic        id_branch, id_bne, id_mem_read, id_mem_write, id_jump, id_jr;
    logic        id_reg_write, id_mem_to_reg;

    // data
    logic [31:0] id_read_data_1_raw, id_read_data_2_raw;
    logic [31:0] id_read_data_1, id_read_data_2; // after WB→ID bypass
    logic [31:0] id_sign_imm, id_zero_imm;
    logic [31:0] id_jump_target;

    // hazard
    logic        stall;

    // =========================================================
    // ID/EX REGISTER OUTPUTS  (= EX stage inputs)
    // =========================================================
    logic        ex_reg_write, ex_mem_to_reg;
    logic        ex_branch, ex_bne, ex_mem_read, ex_mem_write, ex_jump, ex_jr;
    logic        ex_reg_dst, ex_alu_src, ex_sign_zero;
    logic [2:0]  ex_alu_op;
    logic [31:0] ex_pc4;
    logic [31:0] ex_read_data_1, ex_read_data_2;
    logic [31:0] ex_sign_imm, ex_zero_imm;
    logic [31:0] ex_jump_target;
    logic [5:0]  ex_funct;
    logic [4:0]  ex_shamt, ex_rs, ex_rt, ex_rd;

    // =========================================================
    // EX STAGE SIGNALS
    // =========================================================
    logic [1:0]  forward_a, forward_b;
    logic [31:0] fwd_a, fwd_b;       // forwarded ALU operands
    logic [31:0] ex_imm;             // selected immediate
    logic [31:0] alu_src_b;          // final ALU B input
    logic [3:0]  ex_alu_ctrl;
    logic [31:0] alu_result;
    logic        alu_zero;
    logic [4:0]  ex_write_reg;       // after RegDst mux
    logic [31:0] ex_write_data;      // forwarded rt for SW
    logic [31:0] ex_branch_target;

    logic        ex_take_branch, ex_take_jump, ex_take_jr;
    logic        take_redirect;      // any non-sequential PC update

    // =========================================================
    // EX/MEM REGISTER OUTPUTS  (= MEM stage inputs)
    // =========================================================
    logic        mem_reg_write, mem_mem_to_reg;
    logic        mem_mem_read, mem_mem_write;
    logic [31:0] mem_alu_result;
    logic [31:0] mem_write_data;
    logic [4:0]  mem_write_reg;

    // =========================================================
    // MEM STAGE SIGNALS
    // =========================================================
    logic [31:0] mem_read_data;

    // =========================================================
    // MEM/WB REGISTER OUTPUTS  (= WB stage inputs)
    // =========================================================
    logic        wb_reg_write, wb_mem_to_reg;
    logic [31:0] wb_read_data, wb_alu_result;
    logic [4:0]  wb_write_reg;

    // =========================================================
    // WB STAGE SIGNALS
    // =========================================================
    logic [31:0] wb_write_data;

    // =========================================================
    // TOP-LEVEL OUTPUTS
    // =========================================================
    assign pc_out  = pc_reg;
    assign alu_out = alu_result;

    // =========================================================
    // IF STAGE
    // =========================================================
    assign pc_plus_4 = pc_reg + 32'd4;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)        pc_reg <= '0;
        else if (!stall) pc_reg <= pc_next;
        // stall: hold PC
    end

    instruction_memory IMEM (
        .read_address(pc_reg),
        .instruction(if_instr)
    );

    // =========================================================
    // IF/ID REGISTER
    // =========================================================
    if_id_reg IF_ID (
        .clk(clk), .rst(rst),
        .write(~stall),
        .flush(take_redirect),
        .if_pc4(pc_plus_4),
        .if_instr(if_instr),
        .id_pc4(id_pc4),
        .id_instr(id_instr)
    );

    // =========================================================
    // ID STAGE
    // =========================================================
    assign id_rs    = id_instr[25:21];
    assign id_rt    = id_instr[20:16];
    assign id_rd    = id_instr[15:11];
    assign id_shamt = id_instr[10:6];
    assign id_funct = id_instr[5:0];
    assign id_imm16 = id_instr[15:0];

    control CTRL (
        .opcode    (id_instr[31:26]),
        .alu_op    (id_alu_op),
        .reg_dst   (id_reg_dst),
        .branch    (id_branch),
        .bne       (id_bne),
        .mem_read  (id_mem_read),
        .mem_to_reg(id_mem_to_reg),
        .mem_write (id_mem_write),
        .alu_src   (id_alu_src),
        .reg_write (id_reg_write),
        .sign_zero (id_sign_zero),
        .jump      (id_jump)
    );

    assign id_jr = (id_alu_op == 3'b010) && (id_funct == 6'b001000);

    // Jump target computed in ID (needs only PC+4 upper bits + imm26)
    assign id_jump_target = {id_pc4[31:28], id_instr[25:0], 2'b00};

    sign_extend ID_SE (.in(id_imm16), .out(id_sign_imm));
    zero_extend ID_ZE (.in(id_imm16), .out(id_zero_imm));

    // Register file — WB writes back here
    register REG (
        .clk            (clk),
        .write_enable   (wb_reg_write),
        .read_register_1(id_rs),
        .read_register_2(id_rt),
        .write_register (wb_write_reg),
        .write_data     (wb_write_data),
        .read_data_1    (id_read_data_1_raw),
        .read_data_2    (id_read_data_2_raw)
    );

    // WB→ID bypass: when WB is writing in the same cycle that ID reads,
    // the synchronous register file would return the stale value without
    // this combinational bypass.
    assign id_read_data_1 = (wb_reg_write && wb_write_reg != '0
                              && wb_write_reg == id_rs)
                             ? wb_write_data : id_read_data_1_raw;
    assign id_read_data_2 = (wb_reg_write && wb_write_reg != '0
                              && wb_write_reg == id_rt)
                             ? wb_write_data : id_read_data_2_raw;

    // Load-use hazard detection
    hazard_unit HAZARD (
        .id_ex_mem_read(ex_mem_read),
        .id_ex_rt      (ex_rt),
        .if_id_rs      (id_rs),
        .if_id_rt      (id_rt),
        .stall         (stall)
    );

    // =========================================================
    // ID/EX REGISTER
    // =========================================================
    id_ex_reg ID_EX (
        .clk(clk), .rst(rst),
        .flush(take_redirect | stall),

        .id_reg_write  (id_reg_write),   .id_mem_to_reg(id_mem_to_reg),
        .id_branch     (id_branch),      .id_bne       (id_bne),
        .id_mem_read   (id_mem_read),    .id_mem_write (id_mem_write),
        .id_jump       (id_jump),        .id_jr        (id_jr),
        .id_reg_dst    (id_reg_dst),     .id_alu_src   (id_alu_src),
        .id_sign_zero  (id_sign_zero),   .id_alu_op    (id_alu_op),
        .id_pc4        (id_pc4),
        .id_read_data_1(id_read_data_1), .id_read_data_2(id_read_data_2),
        .id_sign_imm   (id_sign_imm),    .id_zero_imm  (id_zero_imm),
        .id_jump_target(id_jump_target),
        .id_funct      (id_funct),       .id_shamt     (id_shamt),
        .id_rs         (id_rs),          .id_rt        (id_rt),
        .id_rd         (id_rd),

        .ex_reg_write  (ex_reg_write),   .ex_mem_to_reg(ex_mem_to_reg),
        .ex_branch     (ex_branch),      .ex_bne       (ex_bne),
        .ex_mem_read   (ex_mem_read),    .ex_mem_write (ex_mem_write),
        .ex_jump       (ex_jump),        .ex_jr        (ex_jr),
        .ex_reg_dst    (ex_reg_dst),     .ex_alu_src   (ex_alu_src),
        .ex_sign_zero  (ex_sign_zero),   .ex_alu_op    (ex_alu_op),
        .ex_pc4        (ex_pc4),
        .ex_read_data_1(ex_read_data_1), .ex_read_data_2(ex_read_data_2),
        .ex_sign_imm   (ex_sign_imm),    .ex_zero_imm  (ex_zero_imm),
        .ex_jump_target(ex_jump_target),
        .ex_funct      (ex_funct),       .ex_shamt     (ex_shamt),
        .ex_rs         (ex_rs),          .ex_rt        (ex_rt),
        .ex_rd         (ex_rd)
    );

    // =========================================================
    // EX STAGE
    // =========================================================

    // Forwarding unit
    forwarding_unit FWD (
        .id_ex_rs       (ex_rs),
        .id_ex_rt       (ex_rt),
        .ex_mem_reg_write(mem_reg_write),
        .ex_mem_rd      (mem_write_reg),
        .mem_wb_reg_write(wb_reg_write),
        .mem_wb_rd      (wb_write_reg),
        .forward_a      (forward_a),
        .forward_b      (forward_b)
    );

    // Forwarding muxes (3-way)
    always_comb begin
        case (forward_a)
            2'b10:   fwd_a = mem_alu_result;  // EX/MEM → EX
            2'b01:   fwd_a = wb_write_data;   // MEM/WB → EX
            default: fwd_a = ex_read_data_1;
        endcase
        case (forward_b)
            2'b10:   fwd_b = mem_alu_result;
            2'b01:   fwd_b = wb_write_data;
            default: fwd_b = ex_read_data_2;
        endcase
    end

    // Immediate selection and ALU source B
    assign ex_imm    = ex_sign_zero ? ex_zero_imm : ex_sign_imm;
    assign alu_src_b = ex_alu_src   ? ex_imm      : fwd_b;

    // SW write data uses forwarded rt (not the immediate path)
    assign ex_write_data = fwd_b;

    // Destination register (RegDst mux)
    assign ex_write_reg = ex_reg_dst ? ex_rd : ex_rt;

    // ALU control
    alu_control ALU_CTRL (
        .alu_op  (ex_alu_op),
        .funct   (ex_funct),
        .alu_ctrl(ex_alu_ctrl)
    );

    // ALU
    alu ALU (
        .a       (fwd_a),
        .b       (alu_src_b),
        .shamt   (ex_shamt),
        .alu_ctrl(ex_alu_ctrl),
        .result  (alu_result),
        .zero    (alu_zero)
    );

    // Branch target: PC+4 + (sign_imm << 2)
    assign ex_branch_target = ex_pc4 + {ex_sign_imm[29:0], 2'b00};

    // Control-flow decisions (resolved at end of EX)
    assign ex_take_branch = (ex_branch & alu_zero) | (ex_bne & ~alu_zero);
    assign ex_take_jump   = ex_jump;
    assign ex_take_jr     = ex_jr;
    assign take_redirect  = ex_take_jr | ex_take_jump | ex_take_branch;

    // Next PC
    always_comb begin
        if      (ex_take_jr)     pc_next = fwd_a;             // JR: rs value
        else if (ex_take_jump)   pc_next = ex_jump_target;
        else if (ex_take_branch) pc_next = ex_branch_target;
        else                     pc_next = pc_plus_4;
    end

    // =========================================================
    // EX/MEM REGISTER
    // =========================================================
    ex_mem_reg EX_MEM (
        .clk(clk), .rst(rst),

        .ex_reg_write  (ex_reg_write),  .ex_mem_to_reg(ex_mem_to_reg),
        .ex_mem_read   (ex_mem_read),   .ex_mem_write (ex_mem_write),
        .ex_alu_result (alu_result),
        .ex_write_data (ex_write_data),
        .ex_write_reg  (ex_write_reg),

        .mem_reg_write (mem_reg_write), .mem_mem_to_reg(mem_mem_to_reg),
        .mem_mem_read  (mem_mem_read),  .mem_mem_write (mem_mem_write),
        .mem_alu_result(mem_alu_result),
        .mem_write_data(mem_write_data),
        .mem_write_reg (mem_write_reg)
    );

    // =========================================================
    // MEM STAGE
    // =========================================================
    data_memory DMEM (
        .clk        (clk),
        .write_enable(mem_mem_write),
        .read_enable (mem_mem_read),
        .address    (mem_alu_result),
        .write_data (mem_write_data),
        .read_data  (mem_read_data)
    );

    // =========================================================
    // MEM/WB REGISTER
    // =========================================================
    mem_wb_reg MEM_WB (
        .clk(clk), .rst(rst),

        .mem_reg_write  (mem_reg_write),  .mem_mem_to_reg(mem_mem_to_reg),
        .mem_read_data  (mem_read_data),
        .mem_alu_result (mem_alu_result),
        .mem_write_reg  (mem_write_reg),

        .wb_reg_write   (wb_reg_write),   .wb_mem_to_reg(wb_mem_to_reg),
        .wb_read_data   (wb_read_data),
        .wb_alu_result  (wb_alu_result),
        .wb_write_reg   (wb_write_reg)
    );

    // =========================================================
    // WB STAGE
    // =========================================================
    assign wb_write_data = wb_mem_to_reg ? wb_read_data : wb_alu_result;

    // wb_write_data and wb_reg_write feed back to the register file
    // (already connected in the ID stage instantiation above)

endmodule
