// Hazard detection unit: detects load-use hazard and issues a stall.
// When LW is in EX and the immediately following instruction (in ID)
// reads the loaded register, we must stall for 1 cycle.
// Stall effect: freeze PC and IF/ID, insert NOP bubble into ID/EX.

module hazard_unit(
    input  logic       id_ex_mem_read,  // EX-stage instruction is a load
    input  logic [4:0] id_ex_rt,        // EX-stage load destination register

    input  logic [4:0] if_id_rs,        // ID-stage instruction rs
    input  logic [4:0] if_id_rt,        // ID-stage instruction rt

    output logic       stall
);
    assign stall = id_ex_mem_read &&
                   ((id_ex_rt == if_id_rs) || (id_ex_rt == if_id_rt));

endmodule
