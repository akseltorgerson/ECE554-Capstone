module decode_and_execute_stage_tb();

    //------------------Inputs for the decode stage--------------------------
    logic clk, rst, fftCalculating;
    logic [31:0] writebackData;
    //------------------Outputs of the decode stage--------------------------
    //Control Signals
    logic haltActual, nopActual, memWriteActual, memReadActual, memToRegActual, blockInstructionActual, startIActual, startFActual, loadFActual;
    logic haltExpected, nopExpected, memWriteExpected, memReadExpected, memToRegExpected, blockInstructionExpected, startIExpected, startFExpected, loadFExpected;
    //------------------ I/O between decode and execute stages---------------
    logic [3:0] aluOp; //Output of decode, input to execute
    logic [31:0] instr, pcPlus4; //Inputs to both decode and execute
    logic [31:0] read1Data, read2Data; //Output of decode, input to execute
    //Control Signals
    logic isSignExtend, isIType1, isBranch, aluSrc, isJump, isJR, isSLBI; //Output of decodem input to execute
    //------------------Inputs for the execute stage-------------------------
        //All come from decode stage or is a common input to both stages
    //------------------Outputs of the execute stage-------------------------
    logic [31:0] nextPCActual, aluResultActual;
    logic [31:0] nextPCExpected, aluResultExpected;

    int errors = 0;

    decode_stage iDecode(.clk(clk),
                         .rst(rst),
                         .instr(instr),
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
                         .halt(haltActual),
                         .nop(nopActual),
                         .memWrite(memWriteActual),
                         .memRead(memReadActual),
                         .memToReg(memToRegActual),
                         .isJR(isJR),
                         .isSLBI(isSLBI),
                         .isJump(isJump),
                         .aluOp(aluOp),
                         .startI(startIActual),
                         .startF(startFActual),
                         .loadF(loadFActual),
                         .blockInstruction(blockInstructionActual));
    
    execute_stage iExecute(.instr(instr),
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
                           .nextPC(nextPCActual),
                           .aluResult(aluResultActual));

    initial begin
        //-------------------Test 1 (Reset)----------------------------
        clk = 0;
        rst = 1'b1;
        instr = 32'h08000000; //Nop
        pcPlus4 = 32'h0;
        writebackData = 32'h0;
        fftCalculating = 1'b0;
        haltExpected = 1'b0; 
        nopExpected = 1'b1;
        memWriteExpected = 1'b0;
        memReadExpected = 1'b0; 
        memToRegExpected = 1'b0;
        blockInstructionExpected = 1'b0;
        startIExpected = 1'b0;
        startFExpected = 1'b0; 
        loadFExpected = 1'b0;
        nextPCExpected = 32'h0;
        aluResultExpected = 32'h0;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        @(negedge clk);
        if(haltExpected != haltActual ||
            nopExpected != nopActual ||
            memWriteExpected != memWriteActual ||
            memReadExpected != memReadActual ||
            memToRegExpected != memToRegActual || 
            blockInstructionExpected != blockInstructionActual ||
            startIExpected != startIActual ||
            startFExpected != startFActual ||
            loadFExpected != loadFActual ||
            nextPCExpected != nextPCActual ||
            aluResultExpected != aluResultActual) begin
            $display("Test 1 Failed!");
            if(haltExpected != haltActual)begin
                $display("haltExpected: %b != haltActual: %b", haltExpected, haltActual);
            end
            if(nopExpected != nopActual)begin
                $display("nopExpected: %b != nopActual: %b", nopExpected, nopActual);
            end
            if(memWriteExpected != memWriteActual)begin
                $display("memWriteExpected: %b != memWriteActual: %b", memWriteExpected, memWriteActual);
            end
            if(memReadExpected != memReadActual)begin
                $display("memReadExpected: %b != memReadActual: %b", memReadExpected, memReadActual);
            end
            if(memToRegExpected != memToRegActual)begin
                $display("memToRegExpected: %b != memToRegActual: %b", memToRegExpected, memToRegActual);
            end
            if(blockInstructionExpected != blockInstructionActual)begin
                $display("blockInstructionExpected: %b != blockInstructionActual: %b", blockInstructionExpected, blockInstructionActual);
            end
            if(startIExpected != startIActual)begin
                $display("startIExpected: %b != startIActual: %b", startIExpected, startIActual);
            end
            if(startFExpected != startFActual)begin
                $display("startFExpected: %b != startFActual: %b", startFExpected, startFActual);
            end
            if(loadFExpected != loadFActual)begin
                $display("loadFExpected: %b != loadFActual: %b", loadFExpected, loadFActual);
            end
            if(nextPCExpected != nextPCActual)begin
                $display("nextPCExpected: %b != nextPCActual: %b", nextPCExpected, nextPCActual);
            end
            if(aluResultExpected != aluResultActual)begin
                $display("aluResultExpected: %b != aluResultActual: %b", aluResultExpected, aluResultActual);
            end
            errors++;
        end

        if(errors == 0) begin
            $display("YAHOO! All Tests Passed!");
        end else begin
            $display("ARG! Yar code be blasted!");
        end
	$stop();
    end

    always #5 clk = ~clk;

endmodule