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

    // output signals
    logic [31:0] memoryOut;
    logic cacheMiss;
    logic cacheEvict;
    logic [511:0] mcDataOut;
    logic stallDMAMem;

    // other signals
    integer errors;
    integer numMisses, numHits;
    integer blkStartIndex;
    integer i;

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

        errors = 0;
        numMisses = 0;
        numHits = 0;
        blkStartIndex = 0;

        // Load test memory with ascending data
        for (i = 0; i < 8192; i++) begin
            testMemory[i] = i;
        end

        // RESET
        rst = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        memRead = 1'b1;
        @(posedge clk);
        for (i = 0; i < 4096; i++) begin

            // test reading the cache
            aluResult = i;
            @(posedge clk);
            // should see a miss on the first access of each block
            if (cacheMiss) begin
                numMisses += 1;
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
                    // TODO blkStartIndex will need to be changed for when accessing blocks larger
                    // than the cache size, for now this should work
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

                    @(posedge clk);
                    mcDataValid = 1'b0;
                    // WAIT PHASE
                    if (stallDMAMem != 1'b1) begin
                        $display("ERROR: Cache should still be stalling in wait phase");
                        errors += 1;
                    end
                    @(posedge clk);
                    // BACK TO IDLE; BLOCK SHOULD BE IN CACHE
                    if (cacheMiss) begin
                        $display("ERROR: Cache should not be missing after block is loaded");
                    end else begin
                        numHits += 1;
                    end
                end
            end else begin
                numHits += 1;
            end
        end

        if (numMisses != 256) begin
            $display("ERROR: Number of misses expected: %4d, Got: %4d", 256, numMisses);
            errors += 1;
        end

        if (numHits != 4096) begin
            $display("ERROR: Number of hits expected: %4d, Got: %4d", 4096, numHits);
            errors += 1;
        end

        if (errors != 0) begin
            $display("TEST FAILED: %d ERROR(S)", errors);
        end else begin
            $display("TEST PASSED");
        end

        $stop();

    end

endmodule

