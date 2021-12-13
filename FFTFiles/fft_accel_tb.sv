module fft_accel_tb();

    // inputs
    logic clk,                                                      // clk signal
          rst,                                                      // rst
          startF,                                                   // Indicates to start FFT
          startI,                                                   // Indicates to start IFFT
          loadF,                                                    // indicates to load the filter
          filter,                                                   // indicates to filter signal
          loadFifoFromRam,                                          // indicates to load the Out fifo from accel ram
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
        loadFifoFromRam = 0;
        loadInFifo = 0;
        sigNum = 18'h00000;

        // reset the accelerator
        rst = 1;

        @(posedge clk);
        @(negedge clk);

        rst = 0;

        // start the FFT Accelerator
        

        $stop();
    end

endmodule