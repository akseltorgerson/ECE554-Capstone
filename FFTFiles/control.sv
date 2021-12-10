module control(
    //Inputs
    input startF, startI, loadF, loadExternalDone, doFilter, done, clk, rst,
    input [17:0] sigNum, 
    //Outputs
    output reg calculating, loadExternal, loadInternal, writeFilter, isIFFT, fDone, aDone, startFFT
);

    ////////////////////
    /// intermediates //
    ////////////////////

    typedef enum { INITIAL, IDLE, LOADI, LOADF, STARTF, STARTI, CALCULATINGF, CALCULATINGI, DONE } state_t;

    state_t state, next_state;


    ///
    // state dff
    //
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= INITIAL;
            next_state <=INITIAL;
        end else begin
            state <= next_state;
        end
    end

    ////////////////
    // State machine
    ////////////////
    always_comb
        // defaults
        next_state = state;
        calculating = 0;
        loadExternal = 0;
        loadInternal = 0;
        writeFilter = 0;
        isIFFT = 0;
        startFFT = 0;
        fDone = 0;
        aDone = 0;

        case(state)
            INITIAL: begin
                next_state = IDLE;
            end
            IDLE: begin
                if (startF)
                    next_state = LOADF;
                else if (startI)
                    next_state = LOADI; 
            end
            // Await for RAM to be loaded
            LOADI: begin
                loadExternal = 1;
                if (loadExternalDone) begin
                    next_state = STARTI;
                end
            end
            LOADF: begin
                loadExternal = 1;
                if(loadExternalDone) begin
                    next_state = STARTF;
                end
            end

            // start calculation
            STARTF: begin
                startFFT = 1;
                next_state = CALCULATINGF;
            end
            STARTI: begin
                startFFT = 1;
                next_state = CALCULATINGI;
            end

            // calculations
            CALCULATINGF: begin
                calculating = 1;
                loadInternal = 1;
                if (done)
                    next_state = DONE;
            end
            CALCULATINGI: begin
                calculating = 1;
                isIFFT = 1;
                loadInternal = 1;
                if (done)
                    next_state = DONE;
            end

            // DONE STATE
            DONE: begin
                aDone = 1;
                next_state = IDLE;
            end


        endcase
    end
endmodule