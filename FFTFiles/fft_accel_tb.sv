module fft_accel_tb();

    // inputs
    logic clk,                                                      // clk signal
          rst,                                                      // rst
          startF,                                                   // Indicates to start FFT
          startI,                                                   // Indicates to start IFFT
          loadF,                                                    // indicates to load the filter
          filter,                                                   // indicates to filter signal
          accelWrBlkDone,                                           // indicates to load the Out fifo from accel ram
          loadInFifo;                                               // indicates to load the in fifo from mc
    logic [17:0] sigNum;                                            // input signal number for the FFT
    logic [511:0] mcDataIn;                                         // data sent from mc
    
    // outputs
    logic done;                                                     // indicates accel done
    logic calculating;                                              // indicates the accel is calculating
    logic [17:0] sigNumMC;                                          // holds the signal number used by host mem
    logic [511:0] mcDataOut;                                        // data to send to mc
    logic outFifoReady;                                             // indicates the out fifo is ready to to emptied
    logic mcDataOutValid;                                           // mc data out is valid
    logic inFifoEmpty;                                              // indicates that the in fifo is empty


    /////////////////////////////
    //////// intermediates //////
    /////////////////////////////
    integer loadInFifoLoop;                                          // loop vairable to load the in fifo
    integer cycleCounter, stageCounter;                              // for running the FFT

    //////////////////////////////
    ///////// modules ////////////
    //////////////////////////////

    fft_accel iDUT(.*);

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 0;
        startF = 0;
        startI = 0;
        loadF = 0;
        filter = 0;
        accelWrBlkDone = 0;
        loadInFifo = 0;
        sigNum = 18'h00000;

        // reset the accelerator
        rst = 1;

        @(posedge clk);
        @(negedge clk);

        rst = 0;

        // start the FFT Accelerator with the signum set to 1
        startF = 1'b1;
        sigNum = 18'h00001;

        @(posedge clk);
        @(negedge clk);

        // Check if the signal number was stored
        if (sigNumMC !== sigNum) begin
            $display("ERROR: SigNum was not stored in the accelerator");
            $stop();
        end

        // check if calculating is set
        if (calculating !== 1'b1) begin
            $display("ERROR: Calculating bit was not set high when it should be.");
            $stop();
        end

        //
        // start filling the IN FIFO
        //
        loadInFifo = 1'b1;              // indicates that the mc has data ready to be loaded into the FFT

        // should go through and load the fifo 128 times
        for (loadInFifoLoop = 0; loadInFifoLoop < 128; loadInFifoLoop++) begin

            mcDataIn = 512'd1080;

            @(posedge clk);
            @(negedge clk);

        end

        loadInFifo = 1'b0;

        // check if inFifoReady is correctly asserted
        if (iDUT.inFifoReady !== 1'b1) begin
            $display("ERROR: inFifoReady was not set high when it should have been");
            $stop();
        end

        @(posedge clk);
        @(negedge clk);

        // loadExternal should be set high (WAM is being loaded)
        if (iDUT.loadExternal !== 1'b1) begin
            $display("ERROR: loadExternal was not set high when it should have been");
            $stop();
        end

        // await for the positive edge of inFifoEmpty (RAM has been loaded)
        @(posedge iDUT.loadExternalDone);

        // loadExternal should still be being loaded ?????? CHECK THIS FOR TIMING
        if (iDUT.loadExternal !== 1'b1) begin
            $display("ERROR: loadExternal should still be asserted.");
            $stop();
        end

        // should now go into the next calculating state
        @(posedge clk);
        @(negedge clk);

        for (stageCounter = 0; stageCounter < 10; stageCounter++) begin
            for (cycleCounter = 0; cycleCounter < 512; cycleCounter++) begin
                
                // check if the stages and the cycles match ups
                if (stageCounter[4:0] !== iDUT.stageCount) begin
                    $display("ERROR: TB Stage and actual Stage not in sync.");
                    $display("TB STAGE: %d,  ACC STAGE: %d", stageCounter, iDUT.stageCount);
                    $stop();
                end

                if (cycleCounter[8:0] !== iDUT.cycleCount) begin
                    $display("ERROR: TB Cycle and actual Cycle not in sync.");
                    $display("TB CYCLE: %d,  ACC CYCLE: %d", stageCounter, iDUT.stageCount);
                    $stop();
                end

                // Check loadInternal (should be 1'b1)
                if (iDUT.loadInternal !== 1'b1) begin
                    $display("ERROR: loadInternal should be asserted for every stage and every cycle.");
                    $display("STAGE: %d,  CYCLE: %d", stageCounter, cycleCounter);
                    $stop();
                end

                @(posedge clk);
                @(negedge clk);

            end
        end

        // make sure that load internal is set low
        @(posedge clk);
        @(negedge clk);

        // loadInternal should be low
        if (iDUT.loadInternal !== 1'b0) begin
            $display("ERROR: load Internal should be set low.");
            $stop();
        end

        if (iDUT.doneCalculating !== 1'b1) begin
            $display("ERROR: doneCalculating should be set high.");
            $stop();
        end

        $display("YAHOO! ALL TESTS PASSED");
        $stop();
    end

endmodule