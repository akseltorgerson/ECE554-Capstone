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
    input ftDataRead;                   //
    input [511:0] ftBlock2Mem;          //
    input [17:0] sigNum;                //
    output ftDataRead;                  //
    output [511:0] ftBlk2Buffer;        //

);

    // Instr req, Data req, Accel Req
    reg bit priorityReg [3];


    // Instr 
    assign reqReg[0] = instrCacheBlkReq;
    // Data
    assign reqReg[1] = dataCacheBlkReq;
    // Accel
    assign reqReg[2] = ftDataWrite;



endmodule