module proc(
    //Inputs
    mcDataValid, mcInstrValid, mcDataIn, mcInstrIn, evictDone
    //Outputs
    dCacheOut, dCacheEvict, mcDataAddr, cacheMissFetch, cacheMissMemory
);


    //-------------------------- Memory Controller signals----------------------
    //Lets the dCache know that the data from the MC is valid and ready to write
    input mcDataValid;

    //Lets the iCache know that the data from the MC is valid and ready to write
    input mcInstrValid;

    //Data from the memory controller to be used on a DMA request (for memory stage i.e dCache)
    input [511:0] mcDataIn;

    //Data from the memory controller to be used on a DMA request (for fetch stage i.e iCache)
    input [511:0] mcInstrIn;

    //From memory controller, lets memory know succefully stored into host memory
    input evictDone;

    //For the memory controller when there is an evict in the data Cache
    output [511:0] dCacheOut;

    //For the machine controller to evict the data and WRITE to host mem
    output dCacheEvict;

    //Address used for the MC on a DMA request
    output [31:0] mcDataAddr;

    //Control signal indicating that there was a cache miss in the fetch stage
    //Will need to do a DMA request to retrieve the data when this occurs
    output cacheMissFetch;

    //Control signal indicating that there was a cache miss in the memory stage
    //Will need to do a DMA request to retrieve the data when this occurs
    output cacheMissMemory;


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

    //TODO: These two below might be outputs of the processor?
    logic exception;

    logic halt;

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
        .cacheMissMemory(cacheMissMemory)
    );

    accelerator iAccelerator(
        /*
        //Inputs
        (startF),
        (startI),
        (loadF),
        (sigNum),
        (filter),
        //Outputs
        (fftCalculating)

        */
    );

    //mem controller in here too?

endmodule