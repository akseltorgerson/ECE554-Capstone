module cpu(//Inputs                   
            fftCalculating, clk, rst, mcDataValid, mcInstrValid, mcDataIn, mcInstrIn, evictDone,
           //Outputs
           startI, startF, loadF, sigNum, filter, dCacheOut, dCacheEvict, aluResult, exception, halt,
           cacheMissFetch, cacheMissMemory, instrAddr
           );
    
    input clk, rst, fftCalculating;

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

    //Output control signals for the accelerator
    output startI, startF, loadF, filter;
    output [17:0] sigNum; //Signal number for the accelerator, 18 bits

    //For the machine controller when there is an evict in the data Cache
    output [511:0] dCacheOut;

    //For the machine controller to evict the data and WRITE to host mem
    output dCacheEvict;

    //Address used for the MC on a DMA request
    output [31:0] aluResult;

    //If an exception is raised, then this will output to dump the memory
    output exception;

    //If there is a halt, then dump the memory and will stop executing instructions
    output halt;

    //Control signal indicating that there was a cache miss in the fetch stage
    //Will need to do a DMA request to retrieve the data when this occurs
    output cacheMissFetch;

    //Control signal indicating that there was a cache miss in the memory stage
    //Will need to do a DMA request to retrieve the data when this occurs
    output cacheMissMemory;

    //The current instruction's address
    output [31:0] instrAddr;

    //---------------------------------Wires First Used in Fetch Stage--------------------------------
    logic [31:0] instruction;

    //Stops the processor from executing instructions

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
    logic [31:0] pcPlus1;
    
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
    //aluResult or pcNotJR(offsetPCplus1 or just pcPlus1)
    logic isJR;

    //Goes into execute to determine extension for IFormType2
    logic isSLBI;

    //Goes into execute to help determine what the nextPC will be
    logic isJump;

    //Goes into execute to determine what operation the ALU is doing
    logic [3:0] aluOp;

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
    

    //-----------------------------------------------------------------------------------------------

    //---------------------------- Wires first Used in Memory ---------------------------------------

    //Output of a dataCache read
    logic [31:0] memoryOut;

    //-----------------------------------------------------------------------------------------------

    //---------------------------- Wires first Used in Writeback ------------------------------------
        //None all declared before
    //-----------------------------------------------------------------------------------------------

    //---------------------------- Wires in Cause Register ----------------

    logic fftNotCompleteEx;

    logic memAccessEx;
    logic memWriteEx;
    logic invalidJMPEx;
    
    logic [31:0] causeDataOut;

    logic err;

    //------------------------------------------------------------------------------------------------

    //------------------------------ Wires first used in EPC------------------------------------------
    
    //This is just the current instr Addr if there is an exception
    //logic [31:0] epcIn;

    logic [31:0] epcOut;

    //------------------------------------------------------------------------------------------------

    //sigNum will equal the instruction's 26-9 bits
    assign sigNum = instruction[26:9];

    assign filter = instruction[8];

    fetch_stage iFetch(
        .clk(clk),
        .rst(rst),
        .halt(halt), //stops the processor
        .nextPC(nextPC), //the nextPC that the instruction should be fetched from 
        .stallDMAMem(stallDMAMem), //stall signal from memory while memory is performing a DMA request
        .mcDataValid(mcInstrValid), //Lets the iCache know that the data from the MC is valid and ready to write
        .blockInstruction(stallFFT), //Lets the PC know to stall if get a startF or startI while the accelerator is calculating
        .mcDataIn(mcInstrIn), //Data from the memory controller to be used on a DMA request (for fetch stage i.e iCache)
        .exception(exception), //Exception raised, stops the processor
        //Outputs
        .instr(instruction), //The instruction to decode
        .pcPlus1(pcPlus1), //The current pcplus1 which will be used as nextPC if no Branch or Jump
        .cacheMiss(cacheMissFetch), //Control signal indicating that there was a cache miss in the fetch stage
        .instrAddr(instrAddr) //The address of the current instruction the cpu is working on
    );

    decode_stage iDecode(
        .clk(clk),
        .rst(rst),
        .instr(instruction), //The current instruction to decode
        .pcPlus1(pcPlus1), //The current pc plus 1
        .writebackData(writebackData), //Data from writeback to write to the register file
        .fftCalculating(fftCalculating), //From the accelerator, if the accelerator is calculating on a signal
        .stallDMAMem(stallDMAMem), //Lets decode know not to write to the register file on a stall
        //Outputs
        .read1Data(read1Data), //The data held in the first register to be read in an instruction
        .read2Data(read2Data), //The data held in the second register to be read in an instruction
        .aluSrc(aluSrc), //Goes into execute to determine what the Binput of the aluIs (either read2Data or IType Data)
        .isSignExtend(isSignExtend), //Goes into execute to determine how to extend last 19 bits of IFormType1
        .isIType1(isIType1), //Goes into execute to determine which immediate to use for ITypes
        .isBranch(isBranch), //Goes into execute to determine the offset for adding to the PC
        .halt(halt), //If there is a halt, then dump the memory and will stop executing instructions
        .nop(nop), //Signal to show that there is a nop 
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
        .blockInstruction(stallFFT),
        .realImagLoadEx(realImagLoadEx),
        .complexArithmeticEx(complexArithmeticEx),
        .invalidFilterEx(invalidFilterEx)
    );

    execute_stage iExecute(
        .instr(instruction),
        .pcPlus1(pcPlus1),
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
        .aluResult(aluResult),
        .invalidJMPEx(invalidJMPEx)
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
	    .evictDone(evictDone),
        .fftCalculating(fftCalculating),
        .exception(exception),
        //Outputs
        .memoryOut(memoryOut),
        .cacheMiss(cacheMissMemory),
        .mcDataOut(dCacheOut),
        .cacheEvict(dCacheEvict),
        .stallDMAMem(stallDMAMem),
        .memAccessEx(memAccessEx),
        .memWriteEx(memWriteEx),
        .fftNotCompleteEx(fftNotCompleteEx)
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
        .realImagLoadEx(realImagLoadEx), //Exception for if real loaded into imag reg or vice versa
        .complexArithmeticEx(complexArithmeticEx), //Exception for if real and imaginary data are being added/subtracted
        .fftNotCompleteEx(fftNotCompleteEx), //If access fft output memory addresses while data is calculating in accelerator
        .memAccessEx(memAccessEx),  //If read an illegal memory address
        .memWriteEx(memWriteEx), //If write to an illegal memory address
        .invalidJMPEx(invalidJMPEx), //If jump to an invalid address
        .invalidFilterEx(invalidFilterEx), //If there is a startF with filtering before a loadF has been done
        //Outputs
        .causeDataOut(causeDataOut), //Shows which exception was raised
        .exception(exception), //whether there was an exception raised
        .err(err) //Error signal for bad state
    );

    epc_register iEPC(
        .clk(clk),
        .rst(rst),
        .epcIn(instrAddr), //The address of the current instruction that raised the exception
        .write(exception), // Write the epcIn when an exception is raised
        //Outputs
        .epcOut(epcOut) //The data of the epc (address of exception)
    );
    


endmodule