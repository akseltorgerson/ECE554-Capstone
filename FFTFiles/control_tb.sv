module control_tb();

    //Inputs
    logic startF, 
          startI,  
          loadExternalDone, 
          doFilter, 
          done, 
          clk, 
          rst, 
          outLoadDone, 
          startLoadingOutFifo, 
          outFifoReady, 
          startLoadingRam, 
          inFifoEmpty;
    logic [17:0] sigNum;

    //Outputs
    logic calculating, 
            loadExternal, 
            loadInternal, 
            writeFilter, 
            isIFFT, 
            fDone, 
            aDone, 
            loadOutBuffer;

    control iCntrl(.*);

    always #5 clk = ~clk;

    initial begin
        rst = 0;
        clk = 0;
        startF = 0;
        startI = 0;
        loadExternalDone = 0;
        doFilter = 0;
        done = 0;
        outLoadDone = 0;
        startLoadingOutFifo = 0;
        outFifoReady = 0;
        startLoadingRam = 0;
        inFifoEmpty = 0;
        sigNum = 18'h00000;

        rst = 1;

        @(posedge clk);

        rst = 0;

        // test out start F and make sure we go through all the states correctly
        startF = 1;
        
        @(posedge clk);

        startF = 0;

        if (calculating !== 1'b1 && loadExternal !== 1'b1) begin
            $display("ERROR: Expected calculating and loadExternal to be 1 after startF set high");
        end

        // set inFifoEmpty to one to go back to loading IDLE
        inFifoEmpty = 1'b1;

        @(posedge clk);

        if (loadExternal !== 1'b0 && calculating !== 1'b1) begin
            $display("ERROR: Expected loadExternal to be 0 after inFifoEmpty called in LOAD state");
        end

        // set startLoadingRam high to get back into the loading state
        startLoadingRam = 1'b1;

        @(posedge clk);

        if (loadExternal !== 1'b1 && calculating !== 1'b1) begin
            $display("ERROR: Expected to be back in the LOAD state");
        end

        

    end

endmodule