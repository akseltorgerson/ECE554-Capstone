module memory_stage(
    //Inputs
    aluResult, read2Data, clk, rst, memWrite, memRead, halt, mcDataIn, mcDataValid, evictDone,
    //Outputs
    memoryOut, cacheMiss, aluResultMC, mcDataOut, cacheEvict, stallDMAMem
);

    input clk, rst;

    //Address to read into the memory
    input [31:0] aluResult;
    input [31:0] read2Data;

    input memWrite, memRead, halt;

    //Lets the data cache know that the data from the mc is valid data
    input mcDataValid;
    
    //Data from the mc to be written to the cache
    input [511:0] mcDataIn;

    // TODO added this signal to let the mem stage know that the evict has completed
    input evictDone;

    //Result of a memory read
    output [31:0] memoryOut;
    
    //Control signal for the mc if there is a miss in the cache
    //This will be when we are REQUESTING a block from host mem
    output cacheMiss;

    //Control signal for the mc if there is a block that needs to be evicted
    //This will be when we want to WRITE a block to host mem
    output cacheEvict;

    // Also an input, needs to be output to the mc on cache miss as the address
    output [31:0] aluResultMC;

    //Data to be output if there is a cache evict
    output [511:0] mcDataOut;
    
    output stallDMAMem;

    // control signals for cache state machine
    wire cacheHit;

    //Instantiate memory here
    dCache dCache(  .clk(clk), 
                    .rst(rst), 
                    .en(memWrite || memRead),
                    .addr(aluResult),  
                    .blkIn(mcDataIn), 
                    //TODO do we write read2Data or aluResult?
                    .dataIn(read2Data), 
                    .rd(memRead),
                    .wr(memWrite), 
                    .ld(mcDataValid), 
                    .dataOut(memoryOut), 
                    .hit(cacheHit), 
                    .miss(cacheMiss), 
                    .evict(cacheEvict), 
                    .blkOut(mcDataOut));

    // TODO might want to put this state machine in a dCacheController module
    



endmodule