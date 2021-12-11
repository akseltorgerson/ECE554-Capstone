module cpu_tb();

    logic clk, rst;

    logic fftCalculating, mcDataValid, mcInstrValid, evictDone;
    logic [511:0] mcDataIn;
    logic [511:0] mcInstrIn;
    logic startI, startF, loadF, filter, dCacheEvict;

    logic [17:0] sigNum;
    logic [511:0] dCacheOut;
    logic [31:0] mcAddr;

    logic exception;

    logic cacheMissFetch;
    logic cacheMissMemory;

    logic halt;

    int errors = 0;
    int i = 0;

    //test RAM
    logic [31:0] testMemory [8192];

    //test RAM
    logic [31:0] testInstrMemory [2048];

    logic [31:0] instrAddr;


    cpu iCPU(.fftCalculating(fftCalculating),
             .clk(clk),
             .rst(rst),
             .mcDataValid(mcDataValid),
             .mcDataIn(mcDataIn),
	         .mcInstrValid(mcInstrValid),
	         .mcInstrIn(mcInstrIn),
             .evictDone(evictDone),
		     //Outputs
             .startI(startI),
             .startF(startF),
             .loadF(loadF),
             .sigNum(sigNum),
             .filter(filter),
             .dCacheOut(dCacheOut),
             .dCacheEvict(dCacheEvict),
	         .aluResult(mcAddr),
             .exception(exception),
             .halt(halt),
             .cacheMissFetch(cacheMissFetch),
             .cacheMissMemory(cacheMissMemory),
             .instrAddr(instrAddr));

    initial begin
        clk = 1'b0;
        rst = 1'b0;
	    fftCalculating = 1'b0;
	    mcDataValid = 1'b0;
	    mcDataIn = 512'b0;
        mcInstrIn = 512'b0;
        mcInstrValid = 1'b0;
        evictDone = 1'b0;

        //RESET
        rst = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        //Issued instructions:
        //R6 = 10000000 R5= 1002 R4 = 1002 after instruction done
        mcInstrIn = {{6{32'h00000000}}, // HALT will be skipped due to JR
                      32'h28850000, // JR $1, 327680 (Jump to addy 'h00005000)
                      32'h10000900, // STARTF signum (4), filter(1)
                      32'h10000500, // STARTF signum (2), filter (1)
                      32'hF8000600, // LOADF signum (3)
                      32'h8B200000, // LD R4 <- MEM [R6 + 0 h'10000000] R4(h'1002)
                      32'h83280000, // ST Mem[R6 + 0 (h'10000000)] <- R5 ('h1002)
                      32'h93000000, // SLBI R6 zero filled so R6 = h'10000000
                      32'h43280002, // ADDI R5 ('h1002) <- R6('h1000) + ('h02)
                      32'hA3001000, // LBI R6 <- 'h00001000;
                      32'h10000200}; // STARTF signum(1), filter (0)

        //wait random number of cycles
        repeat($urandom_range(1,20)) begin
            @(posedge clk);
            @(negedge clk);
        end

        //------------Tests-------------
        mcInstrValid = 1'b1;
        @(posedge clk);
        @(negedge clk);
        mcInstrValid = 1'b0;
        if(sigNum != 18'b1 || iCPU.startF != 1'b1) begin
            errors++;
            $display("Failed STARTF Test");
        end

        @(posedge clk);
        @(negedge clk);
        fftCalculating = 1'b1;
        if(iCPU.instruction != 32'hA3001000 || iCPU.writebackData != 32'h1000)begin
            errors++;
            $display("Failed LBI Test");
        end

        @(posedge clk);
        @(negedge clk);

        if(iCPU.instruction != 32'h43280002 || iCPU.writebackData != 32'h1002) begin
            errors++;
            $display("Failed ADDI Test");
        end

        @(posedge clk);
        @(negedge clk);
        fftCalculating = 1'b0;
        if(iCPU.instruction != 32'h93000000 || iCPU.writebackData != 32'h10000000)begin
            errors++;
            $display("Failed SLBI Test");
        end

        @(posedge clk);
        @(negedge clk);
        if(iCPU.instruction != 32'h83280000) begin
            errors++;
            $display("Store Test Failed");
        end
        //wait 10 clk cycles to simulate that we are waiting for mcDataValid
        repeat(10)begin
            @(posedge clk);
            @(negedge clk);
        end
        //will just write all zeros to the data array
        mcDataValid = 1'b1;

        @(posedge clk);
        @(negedge clk);
        mcDataValid = 1'b0;
        
        //wait two clk cycles for the mem state machine to finish (should be a hit and then the next instruction)
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        if(iCPU.instruction != 32'h8B200000) begin
            errors++;
            $display("Load Test Failed");
        end

        @(posedge clk);
        @(negedge clk);
        if(iCPU.writebackData != 32'h1002) begin
            errors++;
            $display("Writeback data in Load is not right");
        end

        @(posedge clk);
        @(negedge clk);
        
        if(iCPU.instruction != 32'hF8000600 || loadF != 1'b1 || sigNum != 18'h3)begin
            errors++;
            $display("Failed LoadF test");
        end

        @(posedge clk);
        @(negedge clk);
        //filter loaded signal should now stay high for the rest of the CPU
        if(iCPU.iDecode.filterLoaded != 1'b1)begin
            errors++;
            $display("Filter loaded did not get properly set by LOADF");
        end

        if(iCPU.instruction != 32'h10000500 || sigNum != 18'h2 || filter != 1'b1) begin
            errors++;
            $display("Failed 2nd StartF Test");
        end

        @(posedge clk);
        //set fftCalculating to 1 to simulate the accelerator working on previous startF
        fftCalculating = 1'b1;
        @(negedge clk);
        if(iCPU.instruction != 32'h10000900 || startF != 1'b0 || filter != 1'b1 || sigNum != 18'h4) begin
            errors++;
            $display("Failed second startF in a row");
        end

        //Wait a 6 cycles to simulate the accelerator working
        repeat(6) begin
            @(posedge clk);
            @(negedge clk);
        end
        //Should still be on startF while previous one is calculating still 
        if(iCPU.instruction != 32'h10000900 || startF != 1'b0 || filter != 1'b1 || sigNum != 18'h4) begin
            errors++;
            $display("Didn't stall PC on startF while accelerator calculating on previous signal");
        end

        //Simulate that the accelerator finished working
        @(posedge clk);
        fftCalculating = 1'b0;
        @(negedge clk);
        if(startF != 1'b1 || iCPU.instruction != 32'h10000900) begin
            errors++;
            $display("startF not asserted when fftCalculating was cleared");
        end

        @(posedge clk);
        @(negedge clk);

        if(iCPU.instruction != 32'h28850000 ||iCPU.isJR != 1'b1) begin
            errors++;
            $display("JR instruction not seen");
        end

        @(posedge clk);
        @(negedge clk);
        //Should have a cache miss here, which overwrites the instruction output with a nop until cache Valid comes in
        if(instrAddr != 32'h00050000 || iCPU.instruction != 32'h08000000 || cacheMissFetch != 1'b1) begin
            errors++;
            $display("Did not JR to the correct next address");
        end

        //Wait a 4 cycles to simulate the DMA getting the block of instructions in
        repeat(4) begin
            @(posedge clk);
            @(negedge clk);
        end
        //Should still be the same outputs
        if(instrAddr != 32'h00050000 || iCPU.instruction != 32'h08000000 || cacheMissFetch != 1'b1) begin
            errors++;
            $display("Failed Stall on cache Miss for JR");
        end

        // Current register state (in hex): R6 = 10000000 R5= 1002 R4 = 1002
        //new block coming in
        //After instructions execture reg state:
            //R6 = 10000000, R5 = 1002, R4 = 1002, R11= 5, R12 = A, R10 = FFFFFFFB, R1= 0, R15 = 50007, R2 = 10001002, R3 = 4326
        mcInstrValid = 1'b1;
        mcInstrIn = {32'hda288000, //AND R1 <- R4 & ~R5 so R1 should get 0 
                    32'h599bfffd, //ANDNI R3 <- R3 & 3FFFD so R3 gets 0002
                    32'h50985324, //XORI R3 <- R1 ^ 5324 should give R3 4326
                    32'h89080000, //LD R1 <- MEM[R2] so R1 should get 1002
                    32'h89080001, //LD the R1 <- MEM[R2 + 1] so R1 should get 0
                    32'h99200A40, //STU MEM[10001A32] <- R4 (1002) R2 <- 10001A32
                    32'hd3290000, //XOR R2 <- R6(10000000) ^ R5(1002) (R2 gets 10001002)
                    32'he2288000, //SEQ R1 <- 1 cuz R5 and R4 equal (will get skipped becuase of JAL isntruction)
                    32'h30000001, //JAL over 1 instruction but save address of the next instruction in R15 = 50008 (J instruction goes here)
                    32'heaa08000, //SLT R1 <- 0 cuz R5 !< R4 (will get skipped because of the J instruction)
                    32'h20000001, //Jump over one instruction
                    32'heaa08000, //SLT R1 <- 0 cuz R5 !< R4 addr= 50004
                    32'he2288000, //SEQ R1 <- 1 cuz R5 and R4 equal
                    32'hce5d0000, //SUB R10 <- R11 - R12 R10 gets -5 (FFFB)
                    32'h4e58000F, //SUBI R11 <- R12 15 - 10 (5)
                    32'ha600000a //LBI R12 <- 10 (Caused issue with assembler)
            };
        @(posedge clk);
        @(negedge clk);
        mcInstrValid = 1'b0;
        //Check signals for the LBI
        if(iCPU.instruction != 32'ha600000a || iCPU.iDecode.rsWrite != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.writebackData != 32'hA || iCPU.iDecode.writeRegSel != 4'b1100) begin
            errors++;
            $display("Failed LBI R12 Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Check signals for SUBI
        if(iCPU.instruction != 32'h4e58000F || iCPU.isSignExtend != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.isIType1 != 1'b1 || iCPU.writebackData != 32'h5 || iCPU.iDecode.writeRegSel != 4'b1011) begin
            errors++;
            $display("Failed SUBI R11 Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Check signals for SUB
        if(iCPU.instruction != 32'hce5d0000 || iCPU.iDecode.regDst != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.aluSrc != 1'b1 || iCPU.writebackData != 32'hFFFFFFFB || iCPU.iDecode.writeRegSel != 4'b1010) begin
            errors++;
            $display("Failed SUBI R11 Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Check signals for SEQ
        if(iCPU.instruction != 32'he2288000 || iCPU.iDecode.regDst != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.aluSrc != 1'b1 || iCPU.writebackData != 32'h1 || iCPU.iDecode.writeRegSel != 4'b0001) begin
            errors++;
            $display("Failed SEQ Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Check signals for SLT
        if(iCPU.instruction != 32'heaa08000 || iCPU.iDecode.regDst != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.aluSrc != 1'b1 || iCPU.writebackData != 32'h0 || iCPU.iDecode.writeRegSel != 4'b0001) begin
            errors++;
            $display("Failed SLT Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Check signals for Jump (J)
        if(iCPU.instruction != 32'h20000001 || iCPU.iDecode.isJump != 1'b1) begin
            errors++;
            $display("Failed Jump (J) Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Check signals for JAL (J) (also tests that Jump properly skipped 1 instruction)
        if(iCPU.instruction != 32'h30000001 || iCPU.iDecode.isJump != 1'b1 || iCPU.iDecode.isJAL != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.iDecode.writeData != 32'h50008 || iCPU.iDecode.writeRegSel != 4'b1111) begin
            errors++;
            $display("Failed JAL Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Check signals for XOR (also tests that JAL properly skipped 1 instruction)
        if(iCPU.instruction != 32'hd3290000 || iCPU.aluSrc != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.writebackData != 32'h10001002 || iCPU.iDecode.writeRegSel != 4'b0010) begin
            errors++;
            $display("Failed XOR Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Check signals for STU
        if(iCPU.instruction != 32'h99200A40 || iCPU.isSignExtend != 1'b1 || iCPU.isIType1 != 1'b1 || iCPU.memWrite != 1'b1 || iCPU.iDecode.rsWrite != 1'b1 || iCPU.iDecode.writeRegSel != 4'b0010) begin
            errors++;
            $display("Failed STU Test");
        end
        //wait 10 clk cycles to simulate that we are waiting for mcDataValid
        repeat(10)begin
            @(posedge clk);
            @(negedge clk);
        end
        //will just write all zeros to the data array
        mcDataValid = 1'b1;

        @(posedge clk);
        @(negedge clk);
        mcDataValid = 1'b0;
        
        //wait two clk cycles for the mem state machine to finish (should be a hit and then the next instruction)
        @(posedge clk);
        @(negedge clk);
        @(posedge clk);
        @(negedge clk);
        //Check signals for LD plus 1 offset, should be hit cuz of block brought in
        if(iCPU.instruction != 32'h89080001 || iCPU.isSignExtend != 1'b1 || iCPU.isIType1 != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.writebackData != 32'h0 || iCPU.cacheMissMemory != 0) begin
            errors++;
            $display("Failed First Load after STU Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Should still be on same instruction since had to stall one cycle to get the data
        if(iCPU.instruction != 32'h89080001 || iCPU.isSignExtend != 1'b1 || iCPU.isIType1 != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.writebackData != 32'h0 || iCPU.cacheMissMemory != 0) begin
            errors++;
            $display("Failed Stall First Load after STU Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Should be on next load instruction now
        if(iCPU.instruction != 32'h89080000 || iCPU.isSignExtend != 1'b1 || iCPU.isIType1 != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.cacheMissMemory != 0) begin
            errors++;
            $display("Failed Second Load after STU Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Should be on same load instruction now but with writeback data ready
        if(iCPU.instruction != 32'h89080000 || iCPU.isSignExtend != 1'b1 || iCPU.isIType1 != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.writebackData != 32'h1002 || iCPU.cacheMissMemory != 0) begin
            errors++;
            $display("Failed Second Load after STU Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Test XORI signals
        if(iCPU.instruction != 32'h50985324 || iCPU.iDecode.regWrite != 1'b1 || iCPU.isIType1 != 1'b1 || iCPU.iDecode.writeRegSel != 4'b0011 || iCPU.writebackData != 32'h4326)begin
            errors++;
            $display("Failed XORI Test");
        end
        
        @(posedge clk);
        @(negedge clk);
        //Test ANDNI
        if(iCPU.instruction != 32'h599bfffd || iCPU.iDecode.regWrite != 1'b1 || iCPU.isIType1 != 1'b1 || iCPU.iDecode.writeRegSel != 4'b0011 || iCPU.writebackData != 32'h0002)begin
            errors++;
            $display("Failed ANDNI Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Test ANDN
        if(iCPU.instruction != 32'hda288000 || iCPU.iDecode.regWrite != 1'b1 || iCPU.iDecode.regDst != 1'b1 || iCPU.aluSrc != 1'b1 || iCPU.iDecode.writeRegSel != 4'b0001 || iCPU.writebackData != 32'h0)begin
            errors++;
            $display("Failed ANDN Test");
        end
        //Current Register state: R6 = 10000000, R5 = 1002, R4 = 1002, R11= 5, R12 = A, R10 = FFFFFFFB, R1= 0, R15 = 50007, R2 = 10001002, R3 = 4326
        //Next instruction block
        mcInstrIn = {{13{32'h0}}, //HALT, shouldn't get here because of branch
                  32'h6a80138D,   //BNEZ R1 (R5 is 1) so branch to currAddr + 138D addrInstr = 0050012 (pcplus1 + offset) so nextPC = 513A0
                  32'h62801390, //BEQZ R1 (R5 is 1) so no branch happens (addrInstr = 00050011)
                  32'hf22a8000  //SLE R5 should get 1 since at this point R5 = 1002, R4 = 1002      
            };
        // Register state after instr block: R6 = 10000000, R5 = 1, R4 = 1002, R11= 5, R12 = A, R10 = FFFFFFFB, R1= 0, R15 = 50007, R2 = 10001002, R3 = 4326
        @(posedge clk);
        @(negedge clk);
        //Should have a cache miss (since 16 instruction have run so next blk needs to come in) resulting in the operation being run being a nop
        if(iCPU.instruction != 32'h08000000 || iCPU.cacheMissFetch != 1'b1) begin
            errors++;
            $display("Failed cache miss after running 16 instructions");
        end
        @(posedge clk);
        @(negedge clk);
        mcInstrValid = 1'b1;
        @(posedge clk);
        @(negedge clk);
        mcInstrValid = 1'b0;
        //Should have new instructions now (test SLE)
        if(iCPU.instruction != 32'hf22a8000 || iCPU.iDecode.regDst != 1'b1 || iCPU.aluSrc != 1'b1 || iCPU.iDecode.regWrite != 1'b1 || iCPU.iDecode.writeRegSel != 4'b0101 || iCPU.writebackData != 32'h1) begin
            errors++;
            $display("Failed SLE Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Test BEQZ
        if(iCPU.instruction != 32'h62801390 || iCPU.iDecode.isBranch != 1'b1) begin
            errors++;
            $display("Failed BEQZ Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Test BNEZ (should reach here since BEQZ not true)
        if(iCPU.instruction != 32'h6a80138D || iCPU.iDecode.isBranch != 1'b1) begin
            errors++;
            $display("Failed BNEZ Test");
        end
        //Last instruction
        @(posedge clk);
        @(negedge clk);
        //Should have cache miss from the branch not being in instruction
        if(iCPU.instruction != 32'h08000000) begin
            errors++;
            $display("Failed BNEZ next address");
        end
        //  28 jalr
        // Current reg state: R6 = 10000000, R5 = 1, R4 = 1002, R11= 5, R12 = A, R10 = FFFFFFFB, R1= 0, R15 = 50007, R2 = 10001002, R3 = 4326
        mcInstrIn = {{10{32'h0}}, //HALT, final instrcution
                  32'h79800001, //should get skipped by the JALR
                  //388513a6
                  32'h38800001,  //JALR R1 + 1 (so skip 1 instrcution), R15 <- 513a6 (next instr addr) skips 1 
                  32'h465800c0, //addi R11 <- R12 + CA so R11 gets CA (gets here from bgez) instr addr = 513a3
                  32'h00000000, //HALT, gets skipped because of BGEZ
                  32'h79800001, //BGEZ R3, 1 (R3 greater than zero so should branch, skips 1 instruction)
                  32'h710001f4 //BLTZ R2 (R2 greater than zero so shouldn't branch)    
            };
        // Reg state after instruction blk executed: R6 = 10000000, R5 = 1, R4 = 1002, R11= CA, R12 = A, R10 = FFFFFFFB, R1= 0, R15 = 50007, R2 = 10001002, R3 = 4326
        mcInstrValid = 1'b1;
        @(posedge clk);
        @(negedge clk);
        mcInstrValid = 1'b0;
        //Should have new instruction now (test BLTZ)
        if(iCPU.instruction != 32'h710001f4 || iCPU.iDecode.isBranch != 1'b1) begin
            errors++;
            $display("Failed BLTZ Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Test BGEZ (should get here cuz no brawnch from BLTZ)
        if(iCPU.instruction != 32'h79800001 || iCPU.iDecode.isBranch != 1'b1) begin
            errors++;
            $display("Failed BGEZ Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Test ADDI (also that branch from BGEZ got to this instruction)
        if(iCPU.instruction != 32'h465800c0 || iCPU.iDecode.regWrite != 1'b1 || iCPU.isIType1 != 1'b1 || iCPU.isSignExtend != 1'b1 || iCPU.iDecode.writeRegSel != 4'b1011 || iCPU.writebackData != 32'hCA) begin
            errors++;
            $display("Failed ADDI Test");
        end

        @(posedge clk);
        @(negedge clk);
        //Test JALR
        if(iCPU.instruction != 32'h388513a6 || iCPU.iDecode.regWrite != 1'b1 || iCPU.iDecode.isJR != 1'b1 || iCPU.iDecode.isJAL != 1'b1 || iCPU.iDecode.writeRegSel != 4'b1111 || iCPU.iDecode.writeData != 32'h513a5) begin
            errors++;
            $display("Failed JALR Test");
        end
        @(posedge clk);
        @(negedge clk);
        mcInstrValid = 1'b0;
        //LAST HALT, JALR should jump to here
        if(iCPU.instruction != 32'h00000000 || halt != 1'b1) begin
            errors++;
            $display("Failed Halt Test");
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