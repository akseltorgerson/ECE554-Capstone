module cpu_tb();

    logic clk, rst;

    logic fftCalculating, mcDataValid, mcInstrValid, evictDone;
    logic [511:0] mcDataIn;
    logic [511:0] mcInstrIn;
    logic startI, startF, loadF, filter, dCacheEvict;

    logic [17:0] sigNum;
    logic [511:0] dCacheOut;
    logic [31:0] mcAddr;

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
	         .aluResult(mcAddr));

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
        // STARTF signum(1), filter (0)
        // LBI R6 <- 'h00001000;
        // ADDI R5 ('h1002) <- R6('h1000) + ('h02)
        // SLBI R6 zero filled so R6 = h'10000000
        // ST Mem[R6 + 0 (h'10000000)] <- R5 ('h1002)
        //1000 0011 0010 1000
        // LD R4 <- MEM [R6 + 0 h'10000000] R4(h'1002)
        //1000 1011 0010 00000000000000000000000
        // HALT
        mcInstrIn = {{10{32'h00000000}}, 32'h8B200000, 32'h83280000, 32'h93000000, 32'h43280002, 32'hA3001000, 32'h10000200};
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
        if(sigNum != 18'b1) begin
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
        
        //wait two clk cycles for the me state machine to finish (should be a hit and then the next instruction)
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
        //make sure to test two loads in a row so that it doesn't keep stalling and actually goes to next instr

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