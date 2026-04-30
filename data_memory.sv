module data_memory(
input logic clk, write_enable, read_enable,
input logic [31:0] address, write_data,
output logic [31:0] read_data
);
	logic [31:0] mem [256];

	assign read_data = read_enable ? mem[address[9:2]] : 32'b0;

	always_ff @(posedge clk)
	if (write_enable) mem[address[9:2]] <= write_data;

endmodule 