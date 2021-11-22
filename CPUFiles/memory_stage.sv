module memory_stage(
    //Inputs
    aluResult, read2Data, clk, rst, memWrite, memRead, halt, mmuDataIn, mmuDataValid
    //Outputs
    memoryOut, cacheMiss, aluResultMMU, mmuDataOut, cacheEvictValid, stallDMAMem
);

    input clk, rst;

    //Address to read into the memory
    input [31:0] aluResult;
    input [31:0] read2Data;

    input memWrite, memRead, halt;

    //Lets the data cache know that the data from the mmu is valid data
    input mmuDataValid;
    
    //Data from the mmu to be written to the cache
    input [511:0] mmuDataIn;

    //Result of a memory read
    output [31:0] memoryOut;
    
    //Control signal for the mmu if there is a miss in the cache
    output cacheMiss;

    // Also an input, needs to be output to the mmu on cache miss as the address
    output [31:0] aluResultMMU;

    //Data to be output if there is a cache evict
    output [511:0] mmuDataOut;
    
    output cacheEvictValid;
    output stallDMAMem;

    //Instantiate memory here


endmodule