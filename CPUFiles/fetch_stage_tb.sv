module fetch_stage_tb();

    localparam BLOCKS = 128;        // 128 cache lines
    localparam BLOCK_SIZE = 512;    // 512b (64B) cache line size
    localparam WORDS = 16;          // 16 words (instructions) per line
    localparam WORD_SIZE = 32;      // 32 bit words (instructions)
    localparam OFFSET_BITS = 4;
    localparam INDEX_BITS = 7;
    localparam TAG_BITS = 21;

    // input signals
    logic clk, rst, halt;
    logic stallDMAMem;
    logic blockInstruction;
    logic mcDataValid;
    logic [511:0] mcDataIn;
    logic [31:0] nextPC;
    
    // output signals
    logic [31:0] instr;
    logic [31:0] pcPlus4;
    logic cacheMiss;
   

    // other signals
    integer errors;
    integer i, j;
    integer numMisses, numHits;
    integer blkStartIndex;
    bit jump;
    logic [31:0] jumpAddr;

 
    // Create a test RAM
    logic [WORD_SIZE-1:0] testMemory [2048];
    // addr 32'00000000 = testMemory[0]     | Start of address space
    // addr 32'000007FF = testMemory[2047]  | End of address space

    // mock address space
    // 0x00000000 - 0x0000000F testMemory[0] - testMemory[15]       Line 0
    // 0x00000010 - 0x0000001F testMemory[16] - testMemory[31]      Line 1
    //          ...
    // 0x00000700 - 0x000007FF testMemory[2032] - testMemory[2047]  Line 127

    fetch_stage iFetchStage(.*);

    always #5 clk = ~clk;

    // TODO need to test halt, stallDMAMem, blockInstruction
    initial begin
        clk = 1'b0;
        rst = 1'b0;
        halt = 1'b0;
        stallDMAMem = 1'b0;
        blockInstruction = 1'b0;
        mcDataValid = 1'b0;
        mcDataIn = 512'b0;
        //nextPC = 32'b0;
        blkStartIndex = 0;
        jump = 1'b0;
        jumpAddr = 32'b0;

        errors = 0;
        numMisses = 0;
        numHits = 0;

        // Load test memory with random data
        for (i = 0; i < 2048; i++) begin
            testMemory[i] = $urandom();
        end

        // RESET
        @(posedge clk);
        @(negedge clk);
        rst = 1'b1;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;

        // Attempt to read all instructions
        // There should be 128 cold misses
        // There should be 2048 hits (assuming we count a cold miss as a hit on the next cycle)
        for (i = 0; i < 2048; i++) begin

            @(posedge clk);

            if (cacheMiss) begin
                numMisses += 1;
                // Wait for a number of clock cycles for DMA request
                repeat($urandom_range(1, 20)) begin
                    @(posedge clk);
                    if (cacheMiss != 1) begin
                        $display("ERROR: Cache should be asserting a miss during DMA request");
                        errors += 1;
                    end
                    if (instr != 32'h08000000) begin
                        $display("ERROR: Cache should be outputting NOP on a miss");
                    end
                end

                mcDataValid = 1'b1;
                blkStartIndex = i[10:4] * 16;
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

                i -= 1;

                @(posedge clk);
                mcDataValid = 1'b0;
            end
            
            // the data has been loaded in, should see a hit now
            else begin
                numHits += 1;
                if (instr != testMemory[nextPC-1]) begin
                    $display("ERROR: Expected: %4h, Got: %4h", testMemory[nextPC-1], instr);
                    errors += 1;
                end
            end 

        end

        if (numMisses != 128) begin
            $display("ERROR: Number of misses expected: %4d, Got: %4d", 128, numMisses);
            errors += 1;
        end

        if (numHits != 2048) begin
            $display("ERROR: Number of hits expected: %4d, Got: %4d", 2048, numHits);
            errors += 1;
        end

        // test a bunch of random addresses (jumps)
        for (i = 0; i < 2048; i++) begin
            jump = 1'b1;
            jumpAddr = $urandom_range(0, 2031);
            @(posedge clk);
            // read the next 16 instr after the jump
            // should get all hits
            for (j = 0; j < 16; j++) begin
                if (cacheMiss) begin
                    $display("ERROR: Cache should be full");
                    errors += 1;
                end 
                @(posedge clk);
                jumpAddr += 1;
            end
        end

        if (errors != 0) begin
            $display("TEST FAILED: %d ERROR(S)", errors);
        end else begin
            $display("TEST PASSED");
        end

        $stop();

    end

    // PC stuff
    assign nextPC = (jump) ? jumpAddr : pcPlus4 % 2048;

endmodule