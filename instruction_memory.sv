module instruction_memory(
	input logic [31:0] read_address,
	output logic [31:0] instruction
);
	logic [31:0] mem [256];
	
	initial $readmemh("program.hex", mem);
	
	assign instruction = mem[read_address[9:2]];

endmodule 