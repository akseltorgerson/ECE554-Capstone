module cpu(//Inputs
            fftCalculating, clk, rst, mcDataValid, mcDataIn,
           //Outputs
           startI, startF, loadF, sigNum, filter, dCacheOut, dCacheEvict
           //TODO: need to add in other accelerator and memory controller signals
           );
    
    input clk, rst, fftCalculating;

    //Lets the caches know that the data from the MC is valid and ready to write
    input mcDataValid;

    //Data from the memory controller to be used on a DMA request
    input [511:0] mcDataIn;

    //Output control signals for the accelerator
    //TODO: Determine the filter signal
    output startI, startF, loadF, filter;
    output [17:0] sigNum; //Signal number for the accelerator, 18 bits

    //For the machine controller when there is an evict in the data Cache
    output [511:0] dCacheOut;

    //For the machine controller to evict the data and WRITE to host mem
    output dCacheEvict;

    //---------------------------------Wires First Used in Fetch Stage--------------------------------
    logic [31:0] instruction;

    //Stops the processor from executing instructions
    //TODO: Want this to dump the memory state somehow
    logic halt;

    //The address of the next instruction the PC will be getting
    logic [31:0] nextPC;

    //Lets the fetch stage to stall (not go to next instruction) while
    //the mem stage is waiting for a DMA request
    logic stallDMAMem;


    //Lets the PC know to stall (not go to next instruction) if
    //a startF or startI instruction comes through while the accelerator is
    //still processing on a previous signal
    logic stallFFT;

    //The current PC plus 4 (to get the next instruction if no branch)
    logic [31:0] pcPlus4;

    //Control signal indicating that there was a cache miss in the fetch stage
    //Will need to do a DMA request to retrieve the data when this occurs
    //TODO: This might have to be an output of the CPU?
    logic cacheMissFetch;
    //-----------------------------------------------------------------------------------------------


    //---------------------------------Wires First used in Decode Stage------------------------------

    //Output of the writeback stage of memory data that may need to be written to register file
    logic [31:0] writebackData;

    //The data held in the first register to be read in an instruction
    logic [31:0] read1Data;

    //The data held in the second register to be read in an instruction
    logic [31:0] read2Data;

        //---------------Control Signals of Decode------------

    //Goes into execute to determine what the Binput of the aluIs (either read2Data or IType Data)
    logic aluSrc;

    //Goes into execute to determine how to extend last 19 bits of IFormType1
    logic isSignExtend;

    //Goes into execute to determine which immediate to use for ITypes
    logic isIType1;

    //Goes into execute to determine the offset for adding to the PC
    logic isBranch;

    //Signal to show that there is a nop (would be useful in pipelined implementation)
    logic nop;

    //Goes into memory to let cache know that we should be writing memory
    logic memWrite;

    //Goes into memory to let cache know we are doing a memory read
    logic memRead;

    //Goes into writeback to determine what data will be used as the writeback data
    // (Either output of memory or the result of the ALU)
    logic memToReg;

    //Goes to execute to determine whether the nextPC will be
    //aluResult or pcNotJR(offsetPCplus4 or just pcPlus4)
    logic isJR;

    //Goes into execute to determine extension for IFormType2
    logic isSLBI;

    //Goes into execute to help determine what the nextPC will be
    logic isJump;

    //Goes into execute to determine what operation the ALU is doing
    logic aluOp;

        //-------------- Exceptions----------------

    //Exception for if real loaded into imag reg or vice versa
    logic realImagLoadEx;

    //Exception for if real and imaginary data are being added/subtracted
    logic complexArithmeticEx;

    //Exception for if a startF instruction is issued with the filter bit high
    //before a loadF instruction has been done
    logic invalidFilterEx;

    //-----------------------------------------------------------------------------------------------


    //----------------------------- Wires First Used in Execute -------------------------------------

    //Goes into both memory and writeback, and it the result of the alu operation
    //TODO: Possibly need to just make this an output of the CPU module as it's needed for the MC
    logic [31:0] aluResult;

    //Control signal indicating that there was a cache miss in the memory stage
    //Will need to do a DMA request to retrieve the data when this occurs
    //TODO: This might have to be an output of the CPU?
    logic cacheMissMemory;

    //-----------------------------------------------------------------------------------------------

    //---------------------------- Wires first Used in Memory ---------------------------------------

    //Output of a dataCache read
    logic [31:0] memoryOut;

    //-----------------------------------------------------------------------------------------------

    //---------------------------- Wires first Used in Writeback ------------------------------------
        //None all declared before
    //-----------------------------------------------------------------------------------------------

    //sigNum will equal the instruction's 26-9 bits
    assign sigNum = instruction[26:9];

    fetch_stage iFetch(
        .clk(clk),
        .rst(rst),
        .halt(halt),
        .nextPC(nextPC),
        .stallDMAMem(stallDMAMem),
        .mcDataValid(mcDataValid),
        .blockInstruction(stallFFT),
        .mcDataIn(mcDataIn),
        //Outputs
        .instr(instruction),
        .pcPlus4(pcPlus4),
        .cacheMiss(cacheMissFetch)
    );

    decode_stage iDecode(
        .clk(clk),
        .rst(rst),
        .instr(instruction),
        .pcPlus4(pcPlus4),
        .writebackData(writebackData),
        .fftCalculating(fftCalculating),
        //Outputs
        .read1Data(read1Data),
        .read2Data(read2Data),
        .aluSrc(aluSrc),
        .isSignExtend(isSignExtend),
        .isIType1(isIType1),
        .isBranch(isBranch),
        .halt(halt),
        .nop(nop),
        .memWrite(memWrite),
        .memRead(memRead),
        .memToReg(memToReg),
        .isJR(isJR),
        .isSLBI(isSLBI),
        .isJump(isJump),
        .aluOp(aluOp),
        .startI(startI),
        .startF(startF),
        .loadF(loadF),
        .blockInstruction(blockInstruction),
        .realImagLoadEx(realImagLoadEx),
        .complexArithmeticEx(complexArithmeticEx),
        .invalidFilterEx(invalidFilterEx)
    );

    execute_stage iExecute(
        .instr(instruction),
        .pcPlus4(pcPlus4),
        .read1Data(read1Data),
        .read2Data(read2Data),
        .isSignExtend(isSignExtend),
        .isIType1(isIType1),
        .isBranch(isBranch),
        .aluSrc(aluSrc),
        .isJump(isJump),
        .isJR(isJR),
        .isSLBI(isSLBI),
        .aluOp(aluOp),
        //Outputs
        .nextPC(nextPC),
        .aluResult(aluResult)
    );

    memory_stage iMemory(
        .clk(clk),
        .rst(rst),
        .aluResult(aluResult),
        .read2Data(read2Data),
        .memWrite(memWrite),
        .memRead(memRead),
        .halt(halt),
        .mcDataIn(mcDataIn),
        .mcDataValid(mcDataValid),
        //Outputs
        .memoryOut(memoryOut),
        .cacheMiss(cacheMissMemory),
        //TODO: don't think this is really needed just make aluResult an output of the cpumodule
        .aluResultMC(),
        .mcDataOut(dCacheOut),
        .cacheEvict(dCacheEvict),
        .stallDMAMem(stallDMAMem)
    );

    writeback_stage iWriteback(
        .memoryOut(memoryOut),
        .aluResult(aluResult),
        .memToReg(memToReg),
        //Outputs
        .writebackData(writebackData)
    );

    cause_register iCR(
        .clk(clk),
        .rst(rst),
        .realImagLoadEx(),
        .complexArithmeticEx(),
        .fftNotCompleteEx(),
        .memAccessEx(),
        .memWriteEx(),
        .invalidJMPEx(),
        .invalidFilterEx(),
        .invalidWaveEx(),
        //Outputs
        .causeDataOut(),
        .exception(),
        .err()
    );

    epc_register iEPC(
        .clk(clk),
        .rst(rst),
        .epcIn(),
        .write(),
        //Outputs
        .epcOut()
    );
    


endmodule