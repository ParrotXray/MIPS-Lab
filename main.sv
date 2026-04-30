module main(
	input logic clk, rst,
   output logic [31:0] pc_out,
   output logic [31:0] alu_out
);
	logic zero, take_branch, jr;
	logic [31:0] pc_reg, pc_next, pc_plus_4, pc_branch, pc_jump;
	logic [31:0] instruction;
	logic [31:0] read_data_1, read_data_2;
	logic [31:0] alu_result, read_data;
	logic [31:0] sign_extend_reg, zero_extend_reg;
	logic [31:0] branch_target, jump_target, branch_shift;
	logic [31:0] alu_branch, immediate, write_reg_data;
	
	logic [27:0] jump_shift;
	logic [4:0] write_register;
	logic [3:0] alu_ctrl;
	
	logic reg_dst, branch, mem_read, jump, mem_to_reg, mem_write, alu_src, reg_write, sign_zero;
	logic [1:0] alu_op;
	
	assign pc_out = pc_reg;
   assign alu_out = alu_result;
	
	pc PC (
		.clk(clk),
		.rst(rst),
		.pc_next(pc_next),
		.pc(pc_reg)
	);
	
	adder ADD_PC4 (
		 .a(pc_reg),
		 .b(32'd4),
		 .y(pc_plus_4)
	);
	
	instruction_memory IMEM (
		.read_address(pc_reg),
		.instruction(instruction)
	);
	
	control CTRL (
		.opcode(instruction[31:26]),
		.reg_dst(reg_dst),
		.branch(branch),
		.mem_read(mem_read),
		.mem_to_reg(mem_to_reg),
		.alu_op(alu_op),
		.mem_write(mem_write),
		.alu_src(alu_src),
		.reg_write(reg_write),
		.sign_zero(sign_zero),
		
		.jump(jump)
	);
	
	mux2 #(5) MUX_REGDST (
		.a(instruction[20:16]),  // rt（I-type）
		.b(instruction[15:11]),  // rd（R-type）
		.sel(reg_dst),
		.y(write_register)
	);
	
	register REG (
		.clk(clk),
		.write_enable(reg_write),
		.read_register_1(instruction[25:21]),
		.read_register_2(instruction[20:16]),
      .write_register(write_register),
      .write_data(write_reg_data),
		
      .read_data_1(read_data_1),
      .read_data_2(read_data_2)
	);
	
	jr_control JR_CTRL (
		.instr_low(instruction[5:0]),
		.alu_op(alu_op),
		.jr(jr)
	);

	sign_extend SE (
		.in(instruction[15:0]),
		.out(sign_extend_reg)
	);
	
	zero_extend ZE (
		.in(instruction[15:0]),
		.out(zero_extend_reg)
	);
	
	mux2 #(32) MUX_IMM (
		.a(sign_extend_reg),
		.b(zero_extend_reg),
		.sel(sign_zero),
		.y(immediate)
	);

	mux2 #(32) MUX_ALUSRC (
		.a(read_data_2),
		.b(immediate),
		.sel(alu_src),
		.y(alu_branch)
	);

	alu_control ALU_CTRL (
		.alu_op(alu_op),
		.funct(instruction[5:0]),
		.alu_ctrl(alu_ctrl)
	);
	
	alu ALU(
		.a(read_data_1),
		.b(alu_branch),
		.alu_ctrl(alu_ctrl),
		.result(alu_result),
		.zero(zero)
	);
	
	data_memory DMEM (
		.clk(clk),
		.write_enable(mem_write),
		.read_enable(mem_read),
		.address(alu_result),
		.write_data(read_data_2),
		.read_data(read_data)
	);
	
	mux2 #(32) MUX_MEMTOREG (
		.a(alu_result),
		.b(read_data),
		.sel(mem_to_reg),
		.y(write_reg_data)
	);
	
	shift_left #(.SHIFT(2), .IN_W(32), .OUT_W(32)) SL2_BRANCH  (
		.in(immediate),
		.out(branch_shift)
	);
	
	adder ADD_BRANCH (
		 .a(branch_shift),
		 .b(pc_plus_4),
		 .y(branch_target)
	);
	
	assign take_branch = zero & branch;
	
	mux2 #(32) MUX_BRANCH (
		.a(pc_plus_4),
		.b(branch_target),
		.sel(take_branch),
		.y(pc_branch)
	);
	
	shift_left #(.SHIFT(2), .IN_W(26), .OUT_W(28)) SL2_JUMP (
		.in(instruction[25:0]),
		.out(jump_shift)
	);
	
	assign jump_target = {pc_plus_4[31:28], jump_shift};
	
	mux2 #(32) MUX_JUMP (
		 .a(pc_branch), .b(jump_target),
		 .sel(jump), .y(pc_jump)
	);

	mux2 #(32) MUX_JR (
		 .a(pc_jump), .b(read_data_1),
		 .sel(jr), .y(pc_next)
	);
	
	

endmodule 