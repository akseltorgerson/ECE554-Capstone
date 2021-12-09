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

    logic halt;

    int errors = 0;
    int i = 0;

    //test RAM
    logic [31:0] testMemory [8192];

    //test RAM
    logic [31:0] testInstrMemory [2048];


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
             .halt(halt));

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
        mcInstrIn = {{7{32'h00000000}}, // HALT
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
        fftCalculating = 1'b0;
        @(posedge clk);
        if(startF != 1'b1 || iCPU.instruction != 32'h10000900) begin
            errors++;
            $display("startF not asserted when fftCalculating was cleared");
        end
        @(posedge clk);
        @(negedge clk);

        if(iCPU.instruction != 32'h00000000) begin
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