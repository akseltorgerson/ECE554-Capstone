module cpu(//Inputs
            fftCalculating, clk, rst, mcDataValid, mcDataIn,
           //Outputs
           startI, startF, loadF, sigNum, filter
           //TODO: need to add in other accelerator and memory controller signals
           );
    
    input clk, rst, fftCalculating, mcDataValid;]

    output startI, startF, loadF, filter;
    output [17:0] sigNum; //Signal number for the accelerator, 18 bits

    wire [31:0] instruction;

    //sigNum will equal the instruction's 26-9 bits
    assign sigNum = instruction[26:9];

    fetch_stage iFetch(
        .clk(clk),
        .rst(rst),
        .halt(),
        .nextPC(),
        .stallDMAMem(),
        .mcDataValid(),
        .blockInstruction(),
        .mcDataIn(),
        //Outputs
        .instr(),
        .pcPlus4(),
        .cacheMiss()
    );

    decode_stage iDecode(
        .clk(clk),
        .rst(rst),
        .instr(),
        .pcPlus4(),
        .writebackData(),
        .fftCalculating(),
        //Outputs
        .read1Data(),
        .read2Data(),
        .aluSrc(),
        .isSignExtend(),
        .isIType1(),
        .isBranch(),
        .halt(),
        .nop(),
        .memWrite(),
        .memRead(),
        .memToReg(),
        .isJR(),
        .isSLBI(),
        .isJump(),
        .aluOp(),
        .startI(),
        .startF(),
        .loadF(),
        .blockinstruction(),
        .realImagLoadEx(),
        .complexArithmeticEx(),
        .invalidFilterEx()
    );

    execute_stage iExecute(
        .instr(),
        .pcPlus4(),
        .read1Data(),
        .read2Data(),
        .isSignExtend(),
        .isIType1(),
        .isBranch(),
        .aluSrc(),
        .isJump(),
        .isJR(),
        .isSLBI(),
        .aluOp(),
        //Outputs
        .nextPC(),
        .aluResult()
    );

    memory_stage iMemory(
        .clk(clk),
        .rst(rst),
        .aluResult(),
        .read2Data(),
        .memWrite(),
        .memRead(),
        .halt(),
        .mcDataIn(),
        .mcDatavalid(),
        //Outputs
        .memoryOut(),
        .cacheMiss(),
        .aluResultMC(),
        .mcDataOut(),
        .cacheEvict(),
        .stallDMAMem()
    );

    writeback_stage iWriteback(
        .memoryOut(),
        .aluResult(),
        .memToReg(),
        //Outputs
        .writebackData()
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