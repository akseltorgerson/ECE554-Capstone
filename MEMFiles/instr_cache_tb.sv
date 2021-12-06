module instr_cache_tb();
    localparam BLOCKS = 128;
    localparam BLOCK_SIZE = 512;
    localparam WORDS = 16;
    localparam WORD_SIZE = 32;
    localparam OFFSET_BITS = 4;
    localparam INDEX_BITS = 7;
    localparam TAG_BITS = 21;

    // input signals
    logic clk;
    logic rst;
    logic [31:0] addr;
    logic [511:0] blkIn;
    logic ld;

    // output signals
    logic [31:0] instrOut;
    logic hit;
    logic miss;

    // other variables
    integer errors, testNum;
    logic [WORD_SIZE-1:0] refDataArray [BLOCKS-1:0][WORDS-1:0];
    logic [TAG_BITS-1:0] refTagArray [BLOCKS-1:0];
    logic refValidArray [BLOCKS-1:0];
    bit reqType;
    logic [BLOCK_SIZE-1:0] refBlkIn;
    logic [TAG_BITS-1:0] tag;
    logic [INDEX_BITS-1:0] index;
    logic [OFFSET_BITS-1:0] offset; 
    integer i, j;

    always #5 clk = ~clk;

    instr_cache iCache(.*);

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        addr = 32'b0;
        blkIn = 512'b0;
        ld = 1'b0;

        // Clear our references
        for (i = 0; i < BLOCKS; i++) begin
            for (j = 0; j < WORDS; j++) begin
                refDataArray[i][j] = 32'b0;
            end
            refTagArray[i] = {TAG_BITS{1'b0}};
            refValidArray[i] = 1'b0;
        end

        errors = 0;
        testNum = 1;

        // RESET
        @(posedge clk);
        rst = 1'b1;
        @(posedge clk);
        rst = 1'b0;

        repeat (16384) begin
            blkIn = {$urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom(), $urandom()};

            // INSTR cache is always a read
            reqType = $urandom_range(0);
            
            tag = $urandom();
            index = $urandom() % BLOCKS;
            offset = $urandom_range(0, WORDS);
            addr = {tag, index, offset};

            $display("TEST %2d | %s | ADDR: %h", testNum, ((reqType == 0) ? "READ" : "WRITE"), addr);
            
            if (reqType == 0) begin
                // Reading          
                ld = 1'b0;

                @(posedge clk);

                // If its a miss, load in a line
                // TODO add a tag check to make sure its supposed to be a miss
                if (miss) begin
                    //$display("READ MISS");

                    // Load the line now
                    //$display("READ LOAD | LINE: %2d", index);
                    ld = 1'b1;
                    @(posedge clk);
                    
                    refDataArray[index][0] = blkIn[31:0];
                    refDataArray[index][1] = blkIn[63:32];
                    refDataArray[index][2] = blkIn[95:64];
                    refDataArray[index][3] = blkIn[127:96];
                    refDataArray[index][4] = blkIn[159:128];
                    refDataArray[index][5] = blkIn[191:160];
                    refDataArray[index][6] = blkIn[223:192];
                    refDataArray[index][7] = blkIn[255:224];
                    refDataArray[index][8] = blkIn[287:256];
                    refDataArray[index][9] = blkIn[319:288];
                    refDataArray[index][10] = blkIn[351:320];
                    refDataArray[index][11] = blkIn[383:352];
                    refDataArray[index][12] = blkIn[415:384];
                    refDataArray[index][13] = blkIn[447:416];
                    refDataArray[index][14] = blkIn[479:448];
                    refDataArray[index][15] = blkIn[511:480];

                    refTagArray[index] = tag;
                    refValidArray[index] = 1'b1;

                    @(posedge clk);

                end

                // Now check to see if we got a hit
                ld = 1'b0;
                @(posedge clk);

                if (hit) begin
                    //$display("READ HIT");
                    if (instrOut != refDataArray[index][offset]) begin
                        $display("ERROR | READ HIT: dataOut Expected: %h, Got: %h", refDataArray[index][offset], instrOut);
                        errors += 1;
                    end
                end else if (miss) begin
                    $display("ERROR: Should see HIT after loading new line");
                    errors += 1;
                end
                
                // try to read all the words in the line that was just loaded
                for (integer i = 0; i < 16; i++) begin
                    offset = i;
                    addr = {tag, index, offset};
                    @(posedge clk);

                    if (miss) begin
                        $display("ERROR: Should be able to read all words in the block that was just loaded");
                    end else begin
                        //$display("HIT");
                        if (instrOut != refDataArray[index][offset]) begin
                            $display("ERROR | READ HIT: dataOut Expected: %h, Got: %h", refDataArray[index][offset], instrOut);
                            errors += 1;
                        end
                    end
                end
            end
            testNum += 1;
        end

        if (errors != 0) begin
            $display("TEST FAILED: %d ERROR(S)", errors);
        end else begin
            $display("TEST PASSED");
        end

        $stop();

    end    

endmodule