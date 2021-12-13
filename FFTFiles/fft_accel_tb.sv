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
        for (loadInFifoLoop = 0; loadInFifoLoop < 128; loadInFifo++) begin
            mcDataIn = 512'd1080;

            @(posedge clk);
            @(negedge clk);

        end

        if (iDUT.inFifoReady !== 1'b1) begin
            $display("ERROR: inFifoReady was not set high when it should have been");
            $stop();
        end

        $display("YAHOO! ALL TESTS PASSED");
        $stop();
    end

endmodule