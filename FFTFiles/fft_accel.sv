module fft_accel(
    input clk, 
          rst, 
          startF, 
          startI, 
          loadF, 
          filter, 
          loadFifoFromRam, 
          loadInFifo,
    input [17:0] sigNum,
    input [511:0] mcDataIn,
    output done, calculating,
    output reg [17:0] sigNumMC,
    output [511:0] mcDataOut,
    output outFifoReady, mcDataOutValid
);

    logic [31:0] butterfly_to_ram_RealA, 
                 butterfly_to_ram_RealB, 
                 butterfly_to_ram_ImagA, 
                 butterfly_to_ram_ImagB, 
                 ram_to_butterfly_RealA, 
                 ram_to_butterfly_RealB, 
                 ram_to_butterfly_ImagA, 
                 ram_to_butterfly_ImagB,
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
    logic doFilter, 
          writeFilter, 
          isIFFT, 
          fDone, 
          doneCalculating, 
          inFifoReady, 
          accelDataOutValid, 
          loadFromFifo, 
          loadExternal, 
          loadOutBuffer, 
          outLoadDone, 
          inFifoEmpty;

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
                     .outLoadDone(outLoadDone),
                     .startLoadingOutFifo(loadFifoFromRam),
                     .startLoadingRam(inFifoReady),
                     .outFifoReady(outFifoReady),
                     .inFifoEmpty(inFifoEmpty));

    butterfly_unit iBUnit(.real_A(ram_to_butterfly_RealA), 
                          .imag_A(ram_to_butterfly_ImagA), 
                          .real_B(ram_to_butterfly_RealB), 
                          .imag_B(ram_to_butterfly_ImagB), 
                          .twiddle_real(twiddle_real), 
                          .twiddle_imag(twiddle_imag), 
                          .real_A_out(butterfly_to_ram_RealA), 
                          .imag_A_out(butterfly_to_ram_ImagA), 
                          .real_B_out(butterfly_to_ram_RealB), 
                          .imag_B_out(butterfly_to_ram_ImagB));

    address_generator iAgen(.stageCount(stageCount), 
                            .cycleCount(cycleCount), 
                            .indexA(indexA), 
                            .indexB(indexB), 
                            .twiddleIndex(twiddleIndex));

    fft_ram iRam(.clk(clk), 
                 .rst(rst), 
                 .load(loadInternal), 
                 .externalLoad(loadFromFifo), 
                 .indexA(loadFromFifo ? loadRamCounter : 
                         loadOutBuffer ? loadFifoCounter :
                        indexA), 
                 .indexB(indexB), 
                 .A_real_i(loadFromFifo ? fifo_real_out : butterfly_to_ram_RealA), 
                 .A_imag_i(loadFromFifo ? fifo_imag_out : butterfly_to_ram_ImagA), 
                 .B_real_i(butterfly_to_ram_RealB),
                 .B_imag_i(butterfly_to_ram_ImagB) 
                 .A_real_o(ram_to_butterfly_RealA), 
                 .A_imag_o(ram_to_butterfly_ImagA), 
                 .B_real_o(ram_to_butterfly_RealB), 
                 .B_imag_o(ram_to_butterfly_ImagB));

    a_buf_top iABuf( .clk(clk), 
                     .rst(rst),
                     .accelWrEn(loadFifoFromRam),
                     .inFifoEmpty(inFifoEmpty),
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

    //////////// cycleCount dff ///////////////
    always_ff @(posedge clk, posedge rst) begin
        if (rst )
            cycleCount <= 9'b000000000;
        else if(&cycleCount)
            cycleCount <= 9'b0;
        else if (calculating & loadInternal)
            cycleCount <= cycleCount + 1;
    end

    ///////////// stage count dff //////////////
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            stageCount <= 5'b00000;
        else if (&stageCount) begin
            stageCount <= 5'b00000;
            doneCalculating <= 1'b1;
        end else if (calculating & loadInternal & &cycleCount)
            stageCount <= stageCount + 1;
    end

    /////////////////// sigNum dff //////////////
    always_ff @(posedge clk, posedge rst) begin
        if (rst)
            sigNumMC <= 18'h00000;
        else if (done)
            sigNumMC <= 18'h00000;
        else if (startF | startI)
            sigNumMC <= sigNum;
    end

    //////////// FIFO Load RAM DFF ////////////
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

    //////// RAM Load FIFO DFF ///////////////
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
        else if (loadOutBuffer)
            loadFifoCounter <= loadFifoCounter + 1;
    end
    
    //
    // Assign Statements
    //
    assign fifo_real_in = ram_to_butterfly_RealA;           // the data going into the out fifo
    assign fifo_imag_in = ram_to_butterfly_ImagA;           // the data going into the out fifo

    assign loadFromFifo = loadExternal;

endmodule