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

    wire [31:0] plus4PCInternal;

    // Added for hazard detection because if nextPC was fed staright into thte register file
    // then every instruction would be a hazard
    wire [31:0] trueNextPC;

    wire[31:0] instrInternal;

    wire[31:0] branchPCPlus4;

    wire[31:0] instrMemInput;

    //These signals are not imporant (but can be used later if need be)
    wire cOut1, cOut2, P1, G1, P2, G2;
    wire halt_internal;


    //TODO: remember why it is haltDec here
    //The halt signal will be ~ inside Pc so when it is 0, it writes on next clk cycle
    program_counter iPc(.clk(clk), .rst(rst), .halt(haltDec), .nextAddr(trueNextPC), .currAddr(currPC), .stallPC(stallPC));

    /*
        TODO: This is where the instruction mem will be instantiated but don't have that right now
    */

    // Add four to the current pc to get the next instruction (if there is no branch)
    cla_32bit iPCAdder(.A(currPC), .B(32'h00000002), .Cin(1'b0), .Sum(plus4PCInternal), .Cout(cOut1), .P(P1), .G(G1));

    // Add four to the pc however this is for the branch sum
    cla_32bit iBranchAdder(.A(nextPC, .B(32'h00000002), .Cin(1'b0), .Sum(branchPCPlus4), .Cout(cOut2), .P(P2), .G(G2));

    //TODO: Try to understand this logic (notes say understand why branchStallDec was added)
    assign haltInternal = ((instrInternal[31:27] == 5'b00000 & ~branchStallDec) | haltDec | haltExe | haltMem | haltWb) ? 1'b1 : 1'b0;

    assign halt = haltInternal;

    //TODO: Understand this logic again, forget why this is the case
    assign instrMemInput = branchStallExe ? nextPc : currPc;

    //TODO: Understand this logic again, forget why this is the case
    assign trueNextPC = branchStallExe ? branchPCPlus4 : plus4PCInternal;

    //TODO: Understand this logic again, forget why this is the case
    assign plus4PC = branchStallExe ? branchPCPlus4 : plus4PCInternal;

    //TODO: Notes say: Possibly need to add an isntr choice to send a Nop through, 
    //might want this to be based off of branchStall since only stall from fetch if branch and not RAW
    assign instr = instrInternal;

endmodule