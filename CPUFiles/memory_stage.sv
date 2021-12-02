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

    // state variables
    typedef enum logic [3:0] {  IDLE = 2'b0,
                                READ = 2'b1, EVICT_RD = 2'b10, LOAD_RD = 2'b11, WAIT_RD = 2'b100,
                                WRITE = 2'b101, EVICT_WR = 2'b110, LOAD_WR = 2'b111, WAIT_WR = 2'b1000} state;
    state currState;
    state nextState;

    //Intermediate signals for the state machine
    wire [31:0] memoryOutCache;
    wire cacheMissInternal;
    wire cacheEvictInternal;
    wire cacheBlkOut;

    //Instantiate memory here
    dCache dCache(  .clk(clk), 
                    .rst(rst), 
                    .en(memWrite || memRead),
                    .addr(aluResult),  
                    .blkIn(mcDataIn), 
                    .dataIn(read2Data), 
                    .rd(memRead),
                    .wr(memWrite), 
                    .ld(mcDataValid),
                    //Outputs 
                    .dataOut(memoryOutCache), 
                    .hit(cacheHit), 
                    .miss(cacheMissInternal), 
                    .evict(cacheEvictInternal), 
                    .blkOut(cacheBlkOut));

    always_ff @(posedge rst) begin
        currState <= IDLE;
        nextState <= IDLE;
    end

    always_ff @(posedge clk) begin
        currState <= nextState;
    end
    
    // TODO might want to put this state machine in a dCacheController module
    always_comb begin
        nextState = IDLE;
        memoryOut = 32'h00000000;
        cacheMiss = 1'b0;
        cacheEvict = 1'b0;
        //TODO: Need to figure out where to set this
        aluResultMC = 32'h00000000;
        stallDMAMem = 1'b0;
        mcDataOut = 512'b0;
        case(currState) begin
            IDLE: begin
                nextState = (memRead) ? READ : (memWrite) ? : WRITE : IDLE;
            end
            READ: begin
                nextState = (cacheHit) ? IDLE : (cacheEvict) ? EVICT_RD : LOAD_RD;
                memoryOut = memoryOutCache;
            end
            EVICT_RD: begin
                nextState = (evictDone) ? LOAD_RD : EVICT_RD;
                cacheMiss = cacheMissInternal;
                cacheEvict = cacheEvictInternal;
                //TODO: Is this right?
                mcDataOut = cacheBlkOut;
                stallDMAMem = 1'b1;
            end
            LOAD_RD: begin
                nextState = (mcDataValid) ? WAIT_RD : LOAD_RD;
                cacheMiss = cacheMissInternal;
                stallDMAMem = 1'b1;
            end
            WAIT_RD: begin
                nextState = READ;
                cacheMiss = cacheMissInternal;
                stallDMAMem = 1'b1;
            end
            WRITE: begin
                nextState = (cacheHit) ? IDLE : (cacheEvict) ? EVICT_WR : LOAD_WR;
            end
            EVICT_WR: begin
                nextState = (evictDone) ? LOAD_WR : EVICT_WR;
                cacheMiss = cacheMissInternal;
                cacheEvict = cacheEvictInternal;
                //TODO: is this right?
                mcDataOut = cacheBlkOut;
                stallDMAMem = 1'b1;
            end
            LOAD_WR: begin
                nextState = (mcDataValid) ? WAIT_WR : LOAD_WR;
                cacheMiss = cacheMissInternal;
                stallDMAMem = 1'b1;
            end
            WAIT_WR: begin
                nextState = WRITE;
                cacheMiss = cacheMissInternal;
                stallDMAMem = 1'b1
            end
        endcase
    end

endmodule