module mips(
    input  logic CLOCK_50,
    input  logic KEY,
    output logic [9:0] LEDR
);
    logic clk, rst;
    logic [31:0] pc_out, alu_out;
    
    assign clk = CLOCK_50;
    assign rst = ~KEY;
    
    main CPU (
        .clk    (clk),
        .rst    (rst),
        .pc_out (pc_out),
        .alu_out(alu_out)
    );

    assign LEDR = rst ? '0 : alu_out[9:0];
    
endmodule 