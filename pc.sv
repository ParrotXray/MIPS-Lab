module pc(
    input logic clk, rst,
    input logic [31:0] pc_next,
    output logic [31:0] pc
);
	always_ff @(posedge clk or posedge rst)
		if (rst) pc <= '0;
		else pc <= pc_next;
		  
endmodule 