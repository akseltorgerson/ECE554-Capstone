module decode_and_execute_stage_tb();

    //------------------Inputs for the decode stage--------------------------
    logic clk, rst, fftCalculating;
    logic [31:0] writebackData;
    //------------------Outputs of the decode stage--------------------------
    //Control Signals
    logic haltActual, nopActual, memWriteActual, memReadActual, memToRegActual, blockInstructionActual;
    logic haltExpected, nopExpected, memWriteExpected, memReadExpected, memToRegExpected, blockInstructionExpected;
    //------------------ I/O between decode and execute stages---------------
    logic [3:0] aluOp; //Output of decode, input to execute
    logic [31:0] instr, pcPlus4 //Inputs to both decode and execute
    logic [31:0] read1Data, read2Data; //Output of decode, input to execute
    //Control Signals
    logic isSignExtend, isIType1, isBranch, aluSrc, isJump, isJR, isSLBI; //Output of decodem input to execute
    //------------------Inputs for the execute stage-------------------------
        //All come from decode stage or is a common input to both stages
    //------------------Outputs of the execute stage-------------------------
    logic [31:0] nextPCActual, aluResultActual;
    logic [31:0] nextPCExpected, aluResultExpected;


endmodule