module fetch_stage(
    //Inputs
    clk, rst, halt, nextPC, stallDMAMem, mcDataValid, blockInstruction, mcDataIn,
    //Outputs
    instr, pcPlus4, cacheMiss
);

    input clk, rst, halt;

    //Control signal from memory stage that stalls the PC if there is an ongoing DMA request
    input stallDMAMem;

    //Control signal from the decode stage that stalls the PC if there is an issue with the instruction order
    input blockInstruction;

    //Control signal from the memory controller to let the instruction cache know the data is valid for the cache
    input mcDataValid;

    //Data from the memory controller via a DMA request to fill the instruction cache
    input [511:0] mcDataIn;

    //The next address that the PC should point to
    input [31:0] nextPC;

    //The instruction to decode
    output [31:0] instr;

    //The current PC plus 4 (to get the next instruction if there is no branch or jump)
    output [31:0] pcPlus4;

    //Lets the mmu know there was a miss in the instruction cache and to start a DMA request
    output cacheMiss;

    wire [31:0] currPC;

    wire stallPC;

    // cache signals
    wire cacheHit;
    wire cacheMiss;

    //These signals are not important (but can be used later if need be)
    wire cout, P, G;

    //The instruction memeory
    iCache iCache(.clk(clk), .rst(rst), .addr(currPC), .blkIn(mcDataIn), .loadLine(mcDataValid), .instrOut(instr), .hit(cacheHit), .miss(cacheMiss));
    // TODO I think we're going to need some sort of state machine here to control this.

    //The halt signal will be ~ inside PC so when it is 0, it writes on the next clk cycle
    prgoram_counter iPC(.clk(clk), .rst(rst), .halt(halt), .nextAddr(nextPC), .currAddr(currPC), .stallPC(stallPC));
    
    //Add four to the current PC (if there is no branch)
    cla_32bit iPCAdder(.A(currPC), .B(16'h4), .Cin(1'b0), .Sum(pcPlus4), .Cout(cout), .P(P), .G(G));

    //Control logic for if the PC needs to be stalled
    assign stallPC = stallDMAMem | blockInstruction | cacheMiss;
endmodule