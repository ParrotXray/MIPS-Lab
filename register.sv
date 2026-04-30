module register(
	input logic clk, write_enable,
	input logic [4:0] read_register_1, read_register_2, write_register,
   input logic [31:0] write_data,
   output logic [31:0] read_data_1, read_data_2
);
	logic [31:0] regs [32];
	
	assign read_data_1 = (read_register_1 == 0) ? '0 : regs[read_register_1];
	assign read_data_2 = (read_register_2 == 0) ? '0 : regs[read_register_2];
	
	always_ff @(posedge clk)
		if (write_enable && write_register != '0) regs[write_register] <= write_data;

endmodule 