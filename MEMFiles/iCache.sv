// 8KB instruction cache

`define BLOCKS 128      // 128 cache lines
`define BLOCK_SIZE 512  // 512b (64B) cache line size
`define WORDS 16        // 16 words (instructions) per line
`define SIZE 32         // 32 bit words (instructions)
`define OFFSET_BITS 4
`define INDEX_BITS 7
`define TAG_BITS 21

module iCache (
    input clk,
    input rst,
    input [31:0] addr,
    input en,
    input [511:0] blkIn,
    // loading a line
    input loadLine,

    output [31:0] instrOut,
    output hit,
    output miss
    // TODO I don't think we need to worry about evicting blocks in the iCache
    //output [511:0] blkOut
    );

    reg [OFFSET_BITS-1:0] offset;
    reg [INDEX_BITS-1:0] index;
    reg [TAG_BITS-1:0] tag;

    // register array for cache
    reg [BLOCK_SIZE-1:0] dataArray [BLOCKS-1:0];
    reg [TAG_BITS-1:0] tagArray [BLOCKS-1:0];
    reg validArray [BLOCKS-1:0];

    assign offset = addr[3:0]; 
    assign index = addr[10:4];
    assign tag = addr[31:11];

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
        if (en && rNw) begin
            // if the supplied index matches the tagArray at that index and its valid, hit
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
        // if the cache is enabled and were writing a block of data
        else if (en && !rNw) begin
            dataArray[index] = blkIn;
            tagArray[index] = tag;
            validArray[index] = 1'b1;
        end
    end
endmodule