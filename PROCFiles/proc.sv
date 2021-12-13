module proc(
    //Inputs
    clk, rst, common_data_bus_in, tx_done, rd_valid,
    //Outputs
    op, common_data_bus_out, io_addr, cv_value
);
    localparam WORD_SIZE = 32;
    localparam LINE_SIZE = 512;

    input clk, rst;
    input [LINE_SIZE-1:0] common_data_bus_in;
    input tx_done;
    input rd_valid;

    output [1:0] op;
    output [LINE_SIZE-1:0] common_data_bus_out;
    output [31:0] io_addr;
    output logic [63:0] cv_value;

    //-------------------------- Memory Controller signals----------------------
    //Lets the dCache know that the data from the MC is valid and ready to write
    logic mcDataValid;

    //Lets the iCache know that the data from the MC is valid and ready to write
    logic mcInstrValid;

    //Data from the memory controller to be used on a DMA request (for memory stage i.e dCache)
    logic [511:0] mcDataIn;

    //Data from the memory controller to be used on a DMA request (for fetch stage i.e iCache)
    logic [511:0] mcInstrIn;

    //From memory controller, lets memory know succefully stored into host memory
    logic evictDone;

    //For the memory controller when there is an evict in the data Cache
    logic [511:0] dCacheOut;

    //For the machine controller to evict the data and WRITE to host mem
    logic dCacheEvict;

    //Address used for the MC on a DMA request
    logic [31:0] mcDataAddr;

    //Control signal indicating that there was a cache miss in the fetch stage
    //Will need to do a DMA request to retrieve the data when this occurs
    logic cacheMissFetch;

    //Control signal indicating that there was a cache miss in the memory stage
    //Will need to do a DMA request to retrieve the data when this occurs
    logic cacheMissMemory;

    //The current address the PC is on
    logic [31:0] instrAddr;

    logic exception;

    logic halt;
    //----------------------------Accelerator Signals---------------------------

    //Lets CPU know that the accelerator is currently calculating
    logic fftCalculating;

    //Lets accelerator know that a startF instruction has been issued
    logic startF;

    //Lets accelerator know that a startI instruction had been issued
    logic startI;

    //Lets accelerator know that a load Filter instruction has been issued
    logic loadF;

    //For Accelerator on a startF, if it needs to be filtered as well
    logic filter;

    //The signal number that the accelerator will operate on
    logic [17:0] sigNum;

    //TODO: ?
    logic accelBlockWrittenToHost;

    //TODO: ?
    logic loadInFifo;

    //TODO: ?
    logic [511:0] mcAccelIn;

    //TODO: ?
    logic [511:0] mcAccelOut;

    //TODO: ?
    logic outFifoReady;

    //TODO: ?
    logic mcAccelDataOutValid;

    //The accelerator is done with it's signal
    logic done;

    // lets mc know to grab data from mem
    logic inFifoEmpty;

    logic [17:0] sigNumMC;

    //---------------------- Mem Arbiter Signals---------------------------------
    
    logic transformComplete;

    cpu iCPU( //Inputs
        .clk(clk),
        .rst(rst),
        .fftCalculating(fftCalculating),
        .mcDataValid(mcDataValid),
        .mcInstrValid(mcInstrValid),
        .mcDataIn(mcDataIn),
        .mcInstrIn(mcInstrIn),
        .evictDone(evictDone),
        //Outputs
        .startF(startF),
        .startI(startI),
        .loadF(loadF),
        .sigNum(sigNum),
        .filter(filter),
        .dCacheOut(dCacheOut),
        .dCacheEvict(dCacheEvict),
        .aluResult(mcDataAddr),
        .exception(exception),
        .halt(halt),
        .cacheMissFetch(cacheMissFetch),
        .cacheMissMemory(cacheMissMemory),
        .instrAddr(instrAddr)
    );

    fft_accel iAccelerator(
        .clk(clk),
        .rst(rst),
        .startF(startF),
        .startI(startI),
        .loadF(loadF),
        .filter(filter),
        .sigNum(sigNum),
        .accelWrBlkDone(accelBlockWrittenToHost),
        .loadInFifo(loadInFifo), 
        .mcDataIn(mcAccelIn),  
        //Outputs
        .done(done),
        .calculating(fftCalculating),
        .sigNumMC(sigNumMC),
        .mcDataOut(mcAccelOut),
        .outFifoReady(outFifoReady),
        .mcDataOutValid(mcAccelDataOutValid),
        .inFifoEmpty(inFifoEmpty)
    );

    mem_arb iMemArbiter(
        //Inputs
        .clk(clk),
        .rst(rst),
        .dump(halt | exception),
        .instrCacheBlkReq(cacheMissFetch),
        .instrAddr(instrAddr),
        .dataCacheBlkReq(cacheMissMemory),
        .dataAddr(mcDataAddr),
        .dataCacheEvictReq(dCacheEvict),
        .dataBlk2Mem(dCacheOut),
        .accelDataRd(inFifoEmpty), //Fine with 1 8kb chunk
        .accelDataWr(outFifoReady),
        .accelBlk2Mem(mcAccelOut),
        .sigNum(sigNumMC),
        //Mem Controller Interface inputs
        .common_data_bus_in(common_data_bus_in),
        .tx_done(tx_done),
        .rd_valid(rd_valid),
        //Outputs
        .instrBlk2Cache(mcInstrIn),
        .instrBlk2CacheValid(mcInstrValid),
        .dataEvictAck(evictDone),
        .dataBlk2CacheValid(mcDataValid),
        .dataBlk2Cache(mcDataIn),
        .accelWrBlkDone(accelBlockWrittenToHost),
        .accelRdBlkDone(loadInFifo),
        .accelBlk2Buffer(mcAccelIn),
        .transformComplete(transformComplete),
        //Mem Controller interface outputs
        .op(op),
        .common_data_bus_out(common_data_bus_out),
        .io_addr(io_addr),
        .cv_value(cv_value)
    );

endmodule