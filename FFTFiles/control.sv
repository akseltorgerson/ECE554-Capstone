module control(
    //Inputs
    input startF, 
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
          inFifoEmpty,
    input [17:0] sigNum, 
    //Outputs
    output reg calculating, 
               loadExternal, 
               loadInternal, 
               writeFilter, 
               isIFFT, 
               fDone, 
               aDone, 
               loadOutBuffer
);

    ////////////////////
    /// intermediates //
    ////////////////////

    typedef enum { IDLE, IDLE_LOADI, IDLE_LOADF, LOADI, LOADF, STARTF, STARTI, CALCULATINGF, CALCULATINGI, START_LOADOUT, IDLE_LOADOUT, LOADOUT, DONE } state_t;

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
                    next_state = LOADF;
                end
                else if (startI) begin
                    next_state = LOADI;
                end
                else begin
                    next_state = IDLE;
                end

            end

            // Await for RAM to be loaded from MC
            // LOADI
            IDLE_LOADI: begin
                calculating = 1'b1;
                if (loadExternalDone)
                    next_state = CALCULATINGI;
                else if(startLoadingRam)
                    next_state = LOADI;
            end

            LOADI: begin
                loadExternal = 1'b1;
                calculating = 1'b1;
                if (inFifoEmpty) begin
                    next_state = IDLE_LOADI;
                end
            end

            // LOADF
            IDLE_LOADF: begin
                calculating = 1'b1;
                if (loadExternalDone)
                    next_state = CALCULATINGF;
                else if(startLoadingRam)
                    next_state = LOADF;
            end

            LOADF: begin
                loadExternal = 1'b1;
                calculating = 1'b1;
                if (inFifoEmpty)
                    next_state = IDLE_LOADF;
            end

            // calculations
            CALCULATINGF: begin
                calculating = 1'b1;
                loadInternal = 1'b1;
                if (done)
                    next_state = LOADOUT;
            end
            CALCULATINGI: begin
                calculating = 1'b1;
                isIFFT = 1'b1;
                loadInternal = 1'b1;
                if (done)
                    next_state = LOADOUT;
            end

            // load the out fifo
            IDLE_LOADOUT: begin
                calculating = 1'b1;
                if (outLoadDone)
                    next_state = DONE;
                else if (startLoadingOutFifo)
                    next_state = LOADOUT;
            end

            LOADOUT: begin
                loadOutBuffer = 1'b1;
                calculating = 1'b1;
                if (outFifoReady)
                    next_state = IDLE_LOADOUT;
            end

            // DONE STATE
            DONE: begin
                aDone = 1;
                next_state = IDLE;
            end
        endcase
    end
endmodule