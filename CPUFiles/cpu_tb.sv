module cpu_tb();

    logic clk, rst;

    logic fftCalculating, mcDataValid, mcInstrValid, evictDone;
    logic [511:0] mcDataIn;
    logic [511:0] mcInstrIn;
    logic startI, startF, loadF, filter, dCacheEvict;

    logic [17:0] sigNum;
    logic [511:0] dCacheOut;
    logic [31:0] mcAddr;

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
        rst = 1'b1;
	fftCalculating = 1'b0;
	mcDataValid = 1'b0;
	mcDataIn = 1'b0;
	
	@(posedge clk);
	@(negedge clk);
	@(posedge clk);
	@(negedge clk);
	@(posedge clk);
	@(negedge clk);
	@(posedge clk);
	@(negedge clk);
	@(posedge clk);
	@(negedge clk);
	@(posedge clk);
	@(negedge clk);
	@(posedge clk);
	@(negedge clk);
	@(posedge clk);
	@(negedge clk);
        $stop();
    end

    always #5 clk = ~clk;



endmodule