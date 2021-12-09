module cpu_memReadEx_tb();

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
             .cacheMissMemory(cacheMissMemory));

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

        mcInstrIn = {{11{32'h0}},
                    32'hF8000600, // LOADF signum (3) //good instruction, won't get to
                    32'h8B080000, //LD R1 <- Mem[R6 + 0 h'00010000] //reading static region should cause exception
                    32'h93000000, //SLBI R6 is h'00010000
                    32'hA3000001, //LBI R6 <- 'h00000001
                    32'h10000000}; //STARTF

        //wait random number of cycles
        repeat($urandom_range(1,20)) begin
            @(posedge clk);
            @(negedge clk);
        end

        //----------Test-----------
        mcInstrValid = 1'b1;
        @(posedge clk);
        @(negedge clk);
        mcInstrValid = 1'b0;
        if(iCPU.instruction != 32'h10000000) begin
            errors++;
            $display("Failed STARTF instruction Test");
        end
        @(posedge clk);
        @(negedge clk);
        if(iCPU.instruction != 32'hA3000001) begin
            errors++;
            $display("Failed LBI  instruction Test");
        end
        @(posedge clk);
        @(negedge clk);
        if(iCPU.instruction != 32'h93000000) begin
            errors++;
            $display("Failed SLBI instruction Test");
        end
        @(posedge clk);
        @(negedge clk);
        if(iCPU.instruction != 32'h8B080000 || exception != 1'b1 || iCPU.memAccessEx != 1'b1) begin
            errors++;
            $display("Failed LD instruction Test");
        end

        repeat(10) begin
            @(posedge clk);
            @(negedge clk);
        end
        //Processor should stop on the instruction that caused the exception
        //Should have exception here 
        if(iCPU.instruction != 32'h8B080000 || exception !=  1'b1 || iCPU.memAccessEx != 1'b1) begin
            errors++;
            $display("Failed stopping processor on exception");
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