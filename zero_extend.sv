module zero_extend(
	input  logic [15:0] in,
	output logic [31:0] out
);
	assign out = {16'b0, in};
endmodule 