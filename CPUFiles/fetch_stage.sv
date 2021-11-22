module fetch_stage(
    //Inputs
    clk, rst, halt, nextPC, stallDMAMem, mmuDataValid, blockInstruction, mmuDataIn,
    //Outputs
    instr, pcPlus4, cacheMiss, mmuDataOut, cacheEvictValid
);

    input clk, rst, halt;

    //Control signal from memory stage that stalls the PC if there is an ongoing DMA request
    input stallDMAMem;

    //Control signal from the decode stage that stalls the PC if there is an issue with the instruction order
    input blockInstruction;

    //Control signal from the memory controller to let the instruction cache know the data is valid for the cache
    input mmuDataValid;

    //Data from the memory controller via a DMA request to fill the instruction cache
    input [511:0] mmuDataIn;

    //The next address that the PC should point to
    input [31:0] nextPC;

    //The instruction to decode
    output [31:0] instr;

    //The current PC plus 4 (to get the next instruction if there is no branch or jump)
    output [31:0] pcPlus4;

    //Lets the mmu know there was a miss in the instruction cache and to start a DMA request
    output cacheMiss;

    //Data being evicted out of the cache, written back into the host memory
    output [511:0] mmuDataOut;

    //Control signal for the memory controller to let it know that the data bus is valid for eviction
    output cacheEvictValid;

    wire [31:0] currPC;

    wire stallPC;

    //These signals are not important (but can be used later if need be)
    wire cout, P, G;

    //The instruction memeory
    // Instantiate module here

    //The halt signal will be ~ inside PC so when it is 0, it writes on the next clk cycle
    prgoram_counter iPC(.clk(clk), .rst(rst), .halt(halt), .nextAddr(nextPC), .currAddr(currPC), .stallPC(stallPC));
    
    //Add four to the current PC (if there is no branch)
    cla_32bit iPCAdder(.A(currPC), .B(16'h4), .Cin(1'b0), .Sum(pcPlus4), .Cout(cout), .P(P), .G(G));

    //Control logic for if the PC needs to be stalled
    assign stallPC = stallDMAMem | blockInstruction | cacheMiss;
endmodule