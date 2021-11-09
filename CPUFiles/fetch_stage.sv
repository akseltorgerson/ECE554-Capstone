module fetch_stage(
    //Inputs
    clk, rst, nextPC, stallPC, srcPC, branchStallExe, branchStallDec, haltDec, haltExe, haltMem, haltWb,
    //Outputs
    halt, plus4PC, instr
);

    input clk, rst, stallPC, srcPC, branchStallExe, branchStallDec;
    input haltDec, haltExe, haltMem, haltWb;

    //The next instruction that the pc should point to
    input [31:0] nextPC;

    //This is the instruction to decode
    output [31:0] instr;

    //The current PC plus 4 (to get the next instruction if there was no branch/jump)
    output [31:0] plus4PC;

    output halt;

    wire [31:0] currPC;

    wire [31:0] plus4PcInternal;

    // Added for hazard detection because if nextPC was fed staright into thte register file
    // then every instruction would be a hazard
    wire [31:0] trueNextPC;

    wire[31:0] instrInternal;

    wire[31:0] branchPCPlus4;

    wire[31:0] instrMemInput;

    //These signals are not imporant (but can be used later if need be)
    wire cOut, P, G;
    wire halt_internal;
    /* Instantiate other modules here
    */
endmodule