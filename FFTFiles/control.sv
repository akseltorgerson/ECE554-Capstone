module control(
    //Inputs
    input startF,                           // start FFT
          startI,                           // start IFFT
          loadExternalDone,                 // Tells when the ram is done being loaded from the FIFO
          doFilter,                         // Tells the control unit to filter (unused)
          done,                             // Indicates that the calculation portion is complete
          clk, 
          rst, 
          outLoadDone,                      // Indicates that the out FIFO is loaded and ready to be pushed to mem (unused)
          outFifoReady,                     // Indicates that the out FIFO is loaded and ready to be pushed to mem
          startLoadingRam,                  // Indicates to start loading the accelerator ram
          transformComplete,                // Indicates that the data from the out fifo has been loaded
          inFifoEmpty,                      // Indicates that the in FIFO has been emptied
    input [17:0] sigNum, 
    //Outputs
    output reg calculating,                 // Indicates that the accelerator is in the middle of calculating
               loadExternal,                // Indicates to load the RAM from FIFO
               loadInternal,                // Indicates to load the RAM with Butterfly data
               writeFilter,                 // Indicates to write to the filter
               isIFFT,                      // Indicates that process is an inverse
               fDone,                       // Indicates that the filter is complete
               aDone,                       // Indicates that the accelerator is done
               loadOutBuffer                // Indicates to load the output buffer
);

    ////////////////////
    /// intermediates //
    ////////////////////

    typedef enum { IDLE, IDLE_LOADI, IDLE_LOADF, LOADI, LOADF, STARTF, STARTI, CALCULATINGF, CALCULATINGI, START_LOADOUT, LOADOUT, DONE } state_t;

    state_t state, next_state;

    ///
    // state dff
    //
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    ////////////////
    // State machine
    ////////////////
    always_comb begin
        // defaults
        next_state = state;
        calculating = 1'b0;
        loadExternal = 0;
        loadInternal = 0;
        writeFilter = 0;
        isIFFT = 0;
        fDone = 0;
        aDone = 0;
        loadOutBuffer = 0;

        case(state)
            IDLE: begin
                if (startF)begin
                    next_state = IDLE_LOADF;
                end
                else if (startI) begin
                    next_state = IDLE_LOADI;
                end
                else begin
                    next_state = IDLE;
                end

            end

            // Await for RAM to be loaded from MC
            // LOADI
            IDLE_LOADI: begin
                calculating = 1'b1;
                if(startLoadingRam) begin
                    next_state = LOADI;
                    loadExternal = 1'b1;
                end
            end

            LOADI: begin
                loadExternal = 1'b1;
                calculating = 1'b1;
                if (loadExternalDone) begin
                    next_state = CALCULATINGI;
                end
            end

            // LOADF
            IDLE_LOADF: begin
                calculating = 1'b1;
                if(startLoadingRam)
                    next_state = LOADF;
            end

            LOADF: begin
                loadExternal = 1'b1;
                calculating = 1'b1;
                if (loadExternalDone)
                    next_state = CALCULATINGF;
            end

            // calculations
            CALCULATINGF: begin
                calculating = 1'b1;
                
                if (done) begin
                    next_state = LOADOUT;
                end else begin
                    loadInternal = 1'b1;
                end
            end
            CALCULATINGI: begin
                calculating = 1'b1;
                isIFFT = 1'b1;
                
                if (done) begin
                    next_state = LOADOUT;
                end else begin
                    loadInternal = 1'b1;
                end
            end

            LOADOUT: begin
                calculating = 1'b1;

                if (outFifoReady) begin
                    next_state = DONE;
                end else begin
                    loadOutBuffer = 1'b1;
                end
            end

            // DONE STATE
            DONE: begin
                aDone = transformComplete ? 1'b1 : 1'b0;
                calculating = 1'b1;
                next_state = transformComplete ? IDLE : DONE;
            end
        endcase
    end
endmodule