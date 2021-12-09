module control_unit_tb();
    //Input Stimulus
    logic [4:0] opcode;
    logic fftCalculating;
    
    //Outputs of Control Unit DUT
    logic isJALActual;
    logic regDstActual;
    logic rsWriteActual; 
    logic regWriteActual; 
    logic aluSrcActual; 
    logic isSignExtendActual; 
    logic isIType1Actual; 
    logic isBranchActual;
    logic haltActual;
    logic nopActual;
    logic memWriteActual; 
    logic memReadActual; 
    logic memToRegActual; 
    logic isJRActual; 
    logic isSLBIActual;
    logic [3:0] aluOpActual;
    logic isJumpActual;
    logic startIActual; 
    logic startFActual;
    logic loadFActual;
    logic blockInstructionActual;

    //Expected Outcomes of Control Unit Block
    logic isJALExpected;
    logic regDstExpected;
    logic rsWriteExpected; 
    logic regWriteExpected; 
    logic aluSrcExpected; 
    logic isSignExtendExpected; 
    logic isIType1Expected; 
    logic isBranchExpected;
    logic haltExpected;
    logic nopExpected;
    logic memWriteExpected; 
    logic memReadExpected; 
    logic memToRegExpected; 
    logic isJRExpected; 
    logic isSLBIExpected;
    logic [3:0] aluOpExpected;
    logic isJumpExpected;
    logic startIExpected; 
    logic startFExpected;
    logic loadFExpected;
    logic blockInstructionExpected;

    int errors = 0;

    control_unit iCU(.opcode(opcode),
                     .fftCalculating(fftCalculating),
                     .isJAL(isJALActual),
                     .regDst(regDstActual),
                     .rsWrite(rsWriteActual),
                     .regWrite(regWriteActual),
                     .aluSrc(aluSrcActual),
                     .isSignExtend(isSignExtendActual),
                     .isIType1(isIType1Actual),
                     .isBranch(isBranchActual),
                     .halt(haltActual),
                     .nop(nopActual),
                     .memWrite(memWriteActual),
                     .memRead(memReadActual),
                     .memToReg(memToRegActual),
                     .isJR(isJRActual),
                     .isSLBI(isSLBIActual),
                     .aluOp(aluOpActual),
                     .isJump(isJumpActual),
                     .startI(startIActual),
                     .startF(startFActual),
                     .loadF(loadFActual),
                     .blockInstruction(blockInstructionActual));

    initial begin
        $display("Starting test...");
        for(int i = 0; i < 200; i++)begin
            opcode = $urandom_range(0, 31);
            // Could give a seed here
            fftCalculating = $random();

            isJALExpected = 1'b0;
            regDstExpected = 1'b0;
            rsWriteExpected = 1'b0; 
            regWriteExpected = 1'b0; 
            aluSrcExpected = 1'b0; 
            isSignExtendExpected = 1'b0; 
            isIType1Expected = 1'b0; 
            isBranchExpected = 1'b0;
            haltExpected = 1'b0;
            nopExpected = 1'b0;
            memWriteExpected = 1'b0; 
            memReadExpected = 1'b0; 
            memToRegExpected = 1'b0; 
            isJRExpected = 1'b0; 
            isSLBIExpected = 1'b0;
            aluOpExpected = 4'h0;
            isJumpExpected = 1'b0;
            startIExpected = 1'b0; 
            startFExpected = 1'b0;
            loadFExpected = 1'b0;
            blockInstructionExpected = 1'b0;
            case(opcode)
                //Halt
                5'b00000: begin
                    haltExpected = 1'b1;
                end
                //nop
                5'b00001: begin
                    nopExpected = 1'b1;
                end
                //STARTF
                5'b00010: begin
                    startFExpected = 1'b1;
                    blockInstructionExpected = fftCalculating ? 1'b1 : 1'b0;
                end
                //STARTI
                5'b00011: begin
                    startIExpected = 1'b1;
                    blockInstructionExpected = fftCalculating ? 1'b1 : 1'b0;
                end
                //LOADF
                5'b11111: begin
                    loadFExpected = 1'b1;
                end
                //ADDI
                5'b01000: begin
                    //Add operation
                    aluOpExpected = 4'b0000;
                    regWriteExpected = 1'b1;
                    isIType1Expected = 1'b1;
                    isSignExtendExpected = 1'b1;
                    //aluSrc == 0 since immediate
                end
                //SUBI
			    5'b01001: begin
                    //subtract operation
				    aluOpExpected = 4'b0001;
				    isSignExtendExpected = 1'b1;
				    regWriteExpected = 1'b1;
				    isIType1Expected = 1'b1;
				    //aluSrc == 0 since immediate
			    end
                //XORI
			    5'b01010: begin
                    //Xor operation
                    aluOpExpected = 4'b0010;
				    regWriteExpected = 1'b1;
				    isIType1Expected = 1'b1;
				    //aluSrc == 0 since immediate
			    end
                //ANDNI
			    5'b01011: begin
                    // And operation
                    aluOpExpected = 4'b0011;
				    regWriteExpected = 1'b1;
				    isIType1Expected = 1'b1;
				    //aluSrc ==- 0 since immediate
			    end
                //ST
			    5'b10000: begin
				    isSignExtendExpected = 1'b1;
                    //Add operation
				    aluOpExpected = 4'b0000;
				    memWriteExpected = 1'b1;
				    isIType1Expected = 1'b1;
			    end
                //LD
			    5'b10001: begin
                    //Add operation
				    aluOpExpected = 4'b0000;
				    memReadExpected = 1'b1;
				    memToRegExpected = 1'b1;
				    isSignExtendExpected = 1'b1;
				    isIType1Expected = 1'b1;
				    regWriteExpected = 1'b1;
			    end
                //STU
                5'b10011: begin
                    isSignExtendExpected = 1'b1;
                    isIType1Expected = 1'b1;
                    memWriteExpected = 1'b1;
                    rsWriteExpected = 1'b1;
                    //Add operation
                    aluOpExpected = 4'b0000;
                    regWriteExpected = 1'b1;
                end
        //////////////////////R Format Instructions////////////////////////////////////
                //ADD
                5'b11000: begin
                    regDstExpected = 1'b1;
                    aluSrcExpected = 1'b1;
                    regWriteExpected = 1'b1;
                    //Add operation
                    aluOpExpected = 4'b0000;
                end
                //SUB
                5'b11001: begin
                    regDstExpected = 1'b1;
                    aluSrcExpected = 1'b1;
                    regWriteExpected = 1'b1;
                    //Subtract operation
                    aluOpExpected = 4'b0001;
                end
                //XOR
                5'b11010: begin
                    regDstExpected = 1'b1;
                    aluSrcExpected = 1'b1;
                    regWriteExpected = 1'b1;
                    //Xor operation
                    aluOpExpected = 4'b0010;
                end
                //ANDN
                5'b11011: begin
                    regDstExpected = 1'b1;
                    aluSrcExpected = 1'b1;
                    regWriteExpected = 1'b1;
                    //And operation
                    aluOpExpected = 4'b0011;
                end
                //SEQ
                5'b11100: begin
                    regDstExpected = 1'b1;
                    aluSrcExpected = 1'b1;
                    aluOpExpected = 4'b1000;
                    regWriteExpected = 1'b1;
                end
                //SLT
                5'b11101: begin
                    regDstExpected = 1'b1;
                    aluSrcExpected = 1'b1;
                    aluOpExpected = 4'b1001;
                    regWriteExpected = 1'b1;
                end
                //SLE
                5'b11110: begin
                    regDstExpected = 1'b1;
                    aluSrcExpected = 1'b1;
                    aluOpExpected = 4'b1010;
                    regWriteExpected = 1'b1;
                end
        ////////////////////////I Format Type 2/////////////////////////////////////////////
                //BEQZ
                5'b01100: begin 
                    isBranchExpected = 1'b1;
                    //branchOp = 2'b00;
                    //Branch Operation
                    aluOpExpected = 4'b0100;
                    //pcSrc = 1'b1;
                end
                //BNEZ
                5'b01101: begin
                    isBranchExpected = 1'b1;
                    //branchOp = 2'b01;
                    aluOpExpected = 4'b0101;
                    //pcSrc = 1'b1;
                end
                //BLTZ
                5'b01110: begin
                    isBranchExpected = 1'b1;
                    //branchOp = 2'b10;
                    aluOpExpected = 4'b0110;
                    //pcSrc = 1'b1;
                end
                //BGEZ
                5'b01111: begin
                    isBranchExpected = 1'b1;
                    //branchOp = 2'b11;
                    aluOpExpected = 4'b0111;
                    //pcSrc = 1'b1;
                end
                //LBI
                5'b10100: begin
                    aluOpExpected = 4'b1011;
                    rsWriteExpected = 1'b1;
                    regWriteExpected = 1'b1;
                end
                //SLBI
                5'b10010: begin
                    aluOpExpected = 4'b1100;
                    rsWriteExpected = 1'b1;
                    isSLBIExpected = 1'b1;
                    regWriteExpected = 1'b1;
                end
                //JR
                5'b00101: begin
                    isJRExpected = 1'b1;
                    //pcSrc = 1'b1;
                end
                //JALR
                5'b00111: begin
                    isJALExpected = 1'b1;
                    isJRExpected = 1'b1;
                    regWriteExpected = 1'b1;
                    //pcSrc = 1'b1;
                end
        /////////////////////// J Format Instructions//////////////////////////////////////
                //J
                5'b00100: begin
                    isJumpExpected = 1'b1;
                    //pcSrc = 1'b1;
                end
                //JAL
                5'b00110: begin
                    isJALExpected = 1'b1;
                    isJumpExpected = 1'b1;
                    regWriteExpected = 1'b1;
                    //pcSrc = 1'b1;
                end
        /////////////////////// Extra Credit Instructions//////////////////////////////////
        // TODO: Maybe want these from 552 for exceptions, not sure if do it this way    //
                5'b00010: begin
                    //Set the SIIC illegal instruction exception
                end
                5'b00011: begin
                    //RTI returns from an exception by loading the PC for the value in the EPC register
                end
                default: begin
                    
                end
            endcase

            if(isJALExpected != isJALActual ||
               regDstExpected != regDstActual ||
               rsWriteExpected != rsWriteActual ||
               regWriteExpected != regWriteActual ||
               aluSrcExpected != aluSrcActual ||
               isSignExtendExpected != isSignExtendActual ||
               isIType1Expected != isIType1Actual ||
               isBranchActual != isBranchExpected ||
               haltExpected != haltActual ||
               nopExpected != nopActual ||
               memWriteExpected != memWriteActual ||
               memReadExpected != memReadActual ||
               memToRegExpected != memToRegActual ||
               isJRExpected != isJRActual ||
               isSLBIExpected != isSLBIActual ||
               aluOpExpected != aluOpActual ||
               isJumpExpected != isJumpActual ||
               startIExpected != startIActual ||
               startFExpected != startFActual ||
               loadFExpected != loadFActual ||
               blockInstructionExpected != blockInstructionActual) begin
                   errors++;
                   $display("Opcode: %b Failed the test", opcode);
               end
        end

        if(errors == 0) begin
            $display("YAHOO! All tests passed");
        end else begin
            $display("DARN! Your code be blasted");
        end
    end

endmodule