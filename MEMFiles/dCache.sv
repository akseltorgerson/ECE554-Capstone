// 64KB instruction cache

`define BLOCKS 1024      // 128 cache lines
`define BLOCK_SIZE 512  // 512b (64B) cache line size
`define WORDS 16        // 16 words (instructions) per line
`define SIZE 32         // 32 bit words (instructions)
`define OFFSET_BITS 4
`define INDEX_BITS 10
`define TAG_BITS 18

module iCache (
    input clk,
    input rst,
    input [31:0] addr,
    input en,
    input [511:0] blkIn,
    input [31:0] dataIn,
    // readNotWrite, 1 for read, 0 for write
    input rNw,
    // indicates that we are loading a cacheLine
    input loadLine,

    output [31:0] dataOut,
    output hit,
    output miss,
    output cacheEvictValid,
    output [511:0] blkOut
    );

    reg [OFFSET_BITS-1:0] offset;
    reg [INDEX_BITS-1:0] index;
    reg [TAG_BITS-1:0] tag;

    // register array for cache
    reg [BLOCK_SIZE-1:0] dataArray [BLOCKS-1:0];
    reg [TAG_BITS-1:0] tagArray [BLOCKS-1:0];
    reg validArray [BLOCKS-1:0];

    assign offset = addr[3:0]; 
    assign index = addr[13:4];
    assign tag = addr[31:14];

    // reset
    always @(posedge rst) begin
        for (int i = 0; i < BLOCKS; i++) begin
            dataArray[i] = 512'b0;
            tagArray[i] = 21'b0;
            validArray[i] = 1'b0;
        end
    end


    always @(posedge clk) begin
        // if the cache is enabled, and were reading
        if (en && rNw && !load) begin
            // if the supplied index matches the tagArray at that index and its valid, hit
            // TODO need to work on an eviction here
            if ((index == tagArray[index]) && validArray[index]) begin
                hit = 1'b1;
                miss = 1'b0;
                // TODO might have to flop this
                instrOut = dataArray[index][offset];
            end
            // the supplied index either does not match the tag, or the valid bit is 0, either way its a miss
            else begin
                hit = 1'b0;
                miss = 1'b1;
            end    
        end

        // if the cache is enabled and were writing to the cache
        else if (en && !rNw && !load) begin
            // TODO do not think we can double index here
            dataArray[index][offset] = dataIn;
            tagArray[index] = tag;
            validArray[index] = 1'b1;
        end

        // if the cache is enabled and we are loading a line of data
        else if (en && load) begin
            // if were loading a block over a valid block
            // TODO need to evict here or something
            //if (validArray[index] == 1'b1) begin
            dataArray[index] = blkIn;
            tagArray[index] = tag;
            validArray[index] = 1'b1;
        end
    end
endmodule