module fft_accel(
    input clk, rst, startF, startI, loadF, filter, read, loadInFifo,
    input [17:0] sigNum,
    input [511:0] mcDataIn,
    output done, calculating,
    output reg [17:0] sigNumMC,
    output [511:0] mcDataOut,
    output outFifoReady, mcDataOutValid
);

    logic [31:0] butterfly_real_A_out, 
                 butterfly_real_B_out, 
                 butterfly_imag_A_out, 
                 butterfly_imag_B_out, 
                 butterfly_real_A_in, 
                 butterfly_real_B_in, 
                 butterfly_imag_A_in, 
                 butterfly_imag_B_in,
                 twiddle_real,
                 twiddle_imag,
                 fifo_real_in,
                 fifo_imag_in,
                 fifo_real_out,
                 fifo_imag_out;

    logic [4:0] stageCount;
    logic [9:0] indexA, indexB, loadRamCounter, loadFifoCounter;
    logic [8:0] twiddleIndex, cycleCount;

    logic loadExternalDone;                                     // external signal for indicating loading RAM is done
    logic doFilter, writeFilter, isIFFT, fDone, doneCalculating, writeOutFIFO, inFifoReady, accelDataOutValid, loadFromFifo, loadExternal, loadOutBuffer, outLoadDone;

    ////////////////////////
    ////// modules//////////
    ////////////////////////
    
    twiddle_ROM rom1(.clk(clk),
                     .twiddleIndex(twiddleIndex),
                     .twiddle_real(twiddle_real),
                     .twiddle_imag(twiddle_imag));

    control control1(.clk(clk), 
                     .rst(rst), 
                     .done(doneCalculating), 
                     .loadExternalDone(loadExternalDone), 
                     .doFilter(doFilter),
                     .sigNum(sigNum),
                     .startF(startF), 
                     .startI(startI), 
                     .calculating(calculating), 
                     .loadInternal(loadInternal), 
                     .writeFilter(writeFilter), 
                     .isIFFT(isIFFT), 
                     .fDone(fDone), 
                     .aDone(done),
                     .loadExternal(loadExternal),
                     .loadOutBuffer(loadOutBuffer),
                     .outLoadDone(outLoadDone));

    butterfly_unit iBUnit(.real_A(butterfly_real_A_in), 
                          .imag_A(butterfly_imag_A_in), 
                          .real_B(butterfly_real_B_in), 
                          .imag_B(butterfly_imag_B_in), 
                          .twiddle_real(twiddle_real), 
                          .twiddle_imag(twiddle_imag), 
                          .real_A_out(butterfly_real_A_out), 
                          .imag_A_out(butterfly_imag_A_out), 
                          .real_B_out(butterfly_real_B_out), 
                          .imag_B_out(butterfly_imag_B_out));

    address_generator iAgen(.stageCount(stageCount), 
                            .cycleCount(cycleCount), 
                            .indexA(indexA), 
                            .indexB(indexB), 
                            .twiddleIndex(twiddleIndex));

    fft_ram iRam(.clk(clk), 
                 .rst(rst), 
                 .load(loadInternal), 
                 .externalLoad(loadFromFifo), 
                 .indexA(loadFromFifo | read ? loadRamCounter : indexA), 
                 .indexB(indexB), 
                 .A_real_i(loadFromFifo ? fifo_real_out : butterfly_real_A_out), 
                 .A_imag_i(loadFromFifo ? fifo_imag_out : butterfly_imag_A_out), 
                 .B_real_i(butterfly_real_B_out), 
                 .B_imag_i(butterfly_imag_B_out), 
                 .A_real_o(butterfly_real_A_in), 
                 .A_imag_o(butterfly_imag_A_in), 
                 .B_real_o(butterfly_real_B_in), 
                 .B_imag_o(butterfly_imag_B_in));

    a_buf_top iABuf( .clk(clk), 
                     .rst(rst),
                     .accelWrEn(writeOutFIFO),
                     .mcWrEn(loadInFifo),
                     .mcDataIn(mcDataIn),
                     .accelDataIn({fifo_imag_in, fifo_real_in}),
                     .outEmptyReady(outFifoReady),
                     .inEmptyReady(inFifoReady),
                     .accelDataOut({fifo_imag_out, fifo_real_out}),
                     .mcDataOut(mcDataOut),
                     .mcDataOutValid(mcDataOutValid),
                     .accelDataOutValid(accelDataOutValid));

    //////////////////////////////
    ////// DFFs //////////////////
    //////////////////////////////

    // cycleCount dff
    always_ff @(posedge clk, posedge rst) begin
        if (rst )
            cycleCount <= 9'b000000000;
        else if(&cycleCount)
            cycleCount <= 9'b0;
        else if (calculating & loadInternal)
            cycleCount <= cycleCount + 1;
    end

    // stage count dff
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            stageCount <= 5'b00000;
        else if (&stageCount) begin
            stageCount <= 5'b00000;
            doneCalculating <= 1'b1;
        end else if (calculating & loadInternal & &cycleCount)
            stageCount <= stageCount + 1;
    end

    // sigNum dff
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            sigNumMC <= 18'h00000;
        else if (done)
            sigNumMC <= 18'h00000;
        else if (startF | startI)
            sigNumMC <= sigNum;
    end

    // FIFO Load RAM DFF
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            loadRamCounter <= 10'h000;
            loadExternalDone <= 1'b0;
        end
        else if (loadExternalDone)
            loadExternalDone <= 1'b0;
        else if (&loadRamCounter) begin
            loadRamCounter <= 10'h000;
            loadExternalDone <= 1'b1;
        end
        else if (loadFromFifo)
            loadRamCounter <= loadRamCounter + 1;
    end

    // RAM Load FIFO DFF
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            loadFifoCounter <= 10'h000;
            outLoadDone <= 1'b0;
        end
        else if (outLoadDone)
            outLoadDone <= 1'b0;
        else if (&loadFifoCounter) begin
            loadFifoCounter <= 10'h000;
            outLoadDone <= 1'b1;
        end
        else if (read & loadOutBuffer)
            loadFifoCounter <= loadFifoCounter + 1;
    end
    
    assign fifo_real_in = butterfly_real_A_in;
    assign fifo_imag_in = butterfly_imag_A_in;

    assign loadFromFifo = inFifoReady & loadExternal;

endmodule