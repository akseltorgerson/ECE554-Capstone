module mem_ctrl_top(

    input clk;
    input rst;

    // Instr Cache Interface
    input instrCacheBlkReq;             // cacheMiss    
    input instrCacheAddr;               // instrAddr
    output [511:0] instrBlock2Cache;    // blkIn
    output instrBlk2CacheValid;         // mcDataValid

    // Data Cache Interface
    input dataCacheBlkReq;              // cacheMiss
    input dataCacheAddr;                // aluResult
    input dataCacheEvictReq;            // cacheEvict
    input [511:0] dataBlock2Mem;        // mcDataOut
    output dataEvictAck;                // evictDone
    output dataBlk2MemValid;            // mcDataValid
    output [511:0] dataBlock2Cache;     // mcDataIn

    // FT Accelerator Buffer Interface
    input ftDataValid;                  //
    input [511:0] ftBlock2Mem;          //
    input [17:0] sigNum;                //
    output sigBlkValid;                 //
    output [511:0] ftBlk2Buffer;        //

    // Host Memory Interface
    // TODO is this even right?
        

);

endmodule