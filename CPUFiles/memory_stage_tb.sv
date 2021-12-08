module memory_stage_tb();
    localparam BLOCKS = 256;
    localparam BLOCK_SIZE = 512;
    localparam WORDS = 16;
    localparam WORD_SIZE = 32;
    localparam OFFSET_BITS = 4;
    localparam INDEX_BITS = 8;
    localparam TAG_BITS = 20;

    // input signals
    logic clk, rst;
    logic [31:0] aluResult;
    logic [31:0] read2Data;
    logic memWrite, memRead, halt;
    logic mcDataValid;
    logic [511:0] mcDataIn;
    logic evictDone;
    logic fftCalculating;

    // output signals
    logic [31:0] memoryOut;
    logic cacheMiss;
    logic cacheEvict;
    logic [511:0] mcDataOut;
    logic stallDMAMem;
    logic memAccessEx;
    logic memWriteEx;
    logic fftNotCompleteEx;

    // other signals
    integer errors;
    integer numMisses, numHits;
    integer blkStartIndex;
    integer i;
    logic [3:0] randOffset;

    // test RAM
    logic [WORD_SIZE-1:0] testMemory [8192];

    memory_stage iMemoryStage(.*);

    always #5 clk = ~clk;

    initial begin
        // zero out inputs
        clk = 1'b0;
        rst = 1'b0;
        aluResult = 32'b0;
        read2Data = 32'b0;
        memWrite = 1'b0;
        memRead = 1'b0;
        halt = 1'b0;
        mcDataValid = 1'b0;
        mcDataIn = 512'b0;
        evictDone = 1'b0;
        fftCalculating = 1'b0;

        errors = 0;
        numMisses = 0;
        numHits = 0;
        blkStartIndex = 0;

        // Load test memory with ascending data
        for (i = 0; i < 8192; i++) begin
            testMemory[i] = i+1;
        end

        // RESET
        rst = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        memRead = 1'b1;
        @(posedge clk);

        // test reading the first 256 blocks
        for (i = 0; i < 4096; i++) begin
            // test reading the cache
            aluResult = i;
            @(posedge clk);
            // READ PHASE
            if (cacheMiss) begin
                if (cacheEvict) begin
                    $display("ERROR: No data has been modified yet, should not see evict");
                    errors += 1;
                end else begin
                    // Wait some cycles for a DMA request
                    repeat($urandom_range(2, 20)) begin
                        @(posedge clk);
                        if (stallDMAMem != 1) begin
                            $display("ERROR: Cache should be stalling for a DMA request");
                            errors += 1;
                        end
                    end
                    // Data requested from the MC is now valid
                    mcDataValid = 1'b1;
                    blkStartIndex = i[11:4] * 16;
                    mcDataIn = {testMemory[blkStartIndex+15],
                                testMemory[blkStartIndex+14],
                                testMemory[blkStartIndex+13],
                                testMemory[blkStartIndex+12],
                                testMemory[blkStartIndex+11],
                                testMemory[blkStartIndex+10],
                                testMemory[blkStartIndex+9],
                                testMemory[blkStartIndex+8],
                                testMemory[blkStartIndex+7],
                                testMemory[blkStartIndex+6],
                                testMemory[blkStartIndex+5],
                                testMemory[blkStartIndex+4],
                                testMemory[blkStartIndex+3],
                                testMemory[blkStartIndex+2],
                                testMemory[blkStartIndex+1],
                                testMemory[blkStartIndex]};

                    // subtract from our loop index so we can read the block we just attempted to
                    i -= 1;
                    @(posedge clk);
                    mcDataValid = 1'b0;
                    // Read PHASE
                    if (stallDMAMem != 1'b1) begin
                        $display("ERROR: Cache should still be stalling in wait phase");
                        errors += 1;
                    end
                end
            end
            @(posedge clk);
            // BACK TO IDLE
        end

        memRead = 1'b0;
        // chill in idle for a while
        repeat(20) begin
            @(posedge clk);
        end
        memWrite = 1'b1;
        numHits = 0;
        numMisses = 0;
        memRead = 1'b0;

        // write to a word in each block, this should flip the dirty bit making them evictable
        for (i = 0; i < 256; i++) begin
            randOffset = $urandom_range(0, 15);
            aluResult = {20'b0, i[7:0], randOffset};
            @(posedge clk);
            // WRITE PHASE
            if (cacheMiss) begin
                $display("ERROR: should not be a miss");
            end else begin
                // write solid 1's
                read2Data = 32'hFFFFFFFF;
            end
            @(posedge clk);
            // IDLE PHASE
        end

        memWrite = 1'b0;
        memRead = 1'b0;
        // chill in idle for a while
        repeat(20) begin
            @(posedge clk);
        end

        memRead = 1'b1;
        @(posedge clk);
        // idle phase

        // test reading new blocks, evicting every block
        // should see 256 misses
        // should see 4096 hits
        for (i = 4096; i < 8192; i++) begin
            aluResult = i;
            @(posedge clk);
            // read phase
            if (cacheMiss) begin
                if (!cacheEvict) begin
                    $display("ERROR: Block should be evicted");
                    errors += 1;
                end else begin
                    @(posedge clk);
                    // evict phase
                    // wait some clock cycles till evict is done
                    repeat($urandom_range(2)) begin
                        @(posedge clk);
                        if (stallDMAMem != 1) begin
                            $display("ERROR: Cache should be stalling for DMA write");
                            errors += 1;
                        end
                    end
                    
                    // update our test mem with the evicted blocks
                    blkStartIndex = i - 4096;
                    testMemory[blkStartIndex] = mcDataOut[31:0];
                    testMemory[blkStartIndex+1] = mcDataOut[63:32];
                    testMemory[blkStartIndex+2] = mcDataOut[95:64];
                    testMemory[blkStartIndex+3] = mcDataOut[127:96];
                    testMemory[blkStartIndex+4] = mcDataOut[159:128];
                    testMemory[blkStartIndex+5] = mcDataOut[191:160];
                    testMemory[blkStartIndex+6] = mcDataOut[223:192];
                    testMemory[blkStartIndex+7] = mcDataOut[255:224];
                    testMemory[blkStartIndex+8] = mcDataOut[287:256];
                    testMemory[blkStartIndex+9] = mcDataOut[319:288];
                    testMemory[blkStartIndex+10] = mcDataOut[351:320];
                    testMemory[blkStartIndex+11] = mcDataOut[383:352];
                    testMemory[blkStartIndex+12] = mcDataOut[415:384];
                    testMemory[blkStartIndex+13] = mcDataOut[447:416];
                    testMemory[blkStartIndex+14] = mcDataOut[479:448];
                    testMemory[blkStartIndex+15] = mcDataOut[511:480];

                    evictDone = 1'b1;
                    @(posedge clk);
                    evictDone = 1'b0;
                    // load phase
                    // Wait some cycles for a DMA request
                    repeat($urandom_range(2)) begin
                        @(posedge clk);
                        if (stallDMAMem != 1) begin
                            $display("ERROR: Cache should be stalling for a DMA request");
                            errors += 1;
                        end
                    end
                    // Data requested from the MC is now valid
                    mcDataValid = 1'b1;
                    blkStartIndex = i[12:4] * 16;
                    mcDataIn = {testMemory[blkStartIndex+15],
                                testMemory[blkStartIndex+14],
                                testMemory[blkStartIndex+13],
                                testMemory[blkStartIndex+12],
                                testMemory[blkStartIndex+11],
                                testMemory[blkStartIndex+10],
                                testMemory[blkStartIndex+9],
                                testMemory[blkStartIndex+8],
                                testMemory[blkStartIndex+7],
                                testMemory[blkStartIndex+6],
                                testMemory[blkStartIndex+5],
                                testMemory[blkStartIndex+4],
                                testMemory[blkStartIndex+3],
                                testMemory[blkStartIndex+2],
                                testMemory[blkStartIndex+1],
                                testMemory[blkStartIndex]};

                    // subtract from our loop index so we can read the block we just attempted to
                    @(posedge clk);
                    mcDataValid = 1'b0;
                    // Read phase
                    if (stallDMAMem != 1'b1) begin
                        $display("ERROR: Cache should still be stalling in wait phase");
                        errors += 1;
                    end
                end
            end
            @(posedge clk);
            // BACK TO IDLE
        end       

        if (errors != 0) begin
            $display("TEST FAILED: %d ERROR(S)", errors);
        end else begin
            $display("TEST PASSED");
        end

        $stop();

    end

endmodule

