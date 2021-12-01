// 8KB instruction cache

`define BLOCKS 128      // 128 cache lines
`define BLOCK_SIZE 512  // 512b (64B) cache line size
`define WORDS 16        // 16 words (instructions) per line
`define WORD_SIZE 32    // 32 bit words (instructions)
`define OFFSET_BITS 4
`define INDEX_BITS 7
`define TAG_BITS 21

module iCache (
    input clk,
    input rst,
    input [31:0] addr,
    input [511:0] blkIn,
    // loading a line
    input ld,

    output [31:0] instrOut,
    output hit,
    output miss

    );

    // register array for cache
    reg [BLOCK_SIZE-1:0] dataArray [BLOCKS-1:0];
    reg [TAG_BITS-1:0] tagArray [BLOCKS-1:0];
    reg validArray [BLOCKS-1:0];

    // internal signals
    reg [OFFSET_BITS-1:0] offset;
    reg [INDEX_BITS-1:0] index;
    reg [TAG_BITS-1:0] tag;
    logic valid;
    logic tagMatch;

    // output signals that need to be flopped
    logic [WORD_SIZE-1:0] instrOutInt;
    logic hitInt;
    logic missInt;

    // internal assignments
    assign offset = addr[OFFSET_BITS-1:0]; 
    assign index = addr[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS];
    assign tag = addr[WORD_SIZE-1:OFFSET_BITS+INDEX_BITS];
    assign valid = validArray[index];
    assign tagMatch = (index == tagArray[index]);
    // TODO check if this is right
    assign dataArray[index] = (ld) ? blkIn : dataArray[index];

    // output assignments
    // TODO will need to unpack, do we want it to hold here in the cache?
    assign instrOutInt = (hit) ? dataArray[index][offset] : instrOutInt;
    assign hitInt = (valid & tagMatch);
    assign missInt = (~hitInt);
    
    // reset
    always @(posedge rst) begin
        for (int i = 0; i < BLOCKS; i++) begin
            dataArray[i] <= 512'b0;
            tagArray[i] <= 21'b0;
            validArray[i] <= 1'b0;
        end
    end

    always @(posedge clk) begin
        instrOut <= instrOutInt;
        hit <= hitInt;
        miss <= missInt;
    end

/*
    always @(posedge clk) begin
        // if the cache is enabled, and were reading
        if (!loadLine) begin
            // if the supplied index matches the tagArray at that index and its valid, hit
            if (validArray[index] && index == tagArray[index])) begin
                hit <= 1'b1;
                miss <= 1'b0;
                // TODO might have to flop this
                instrOut = dataArray[index][offset];
            end
            // the supplied index either does not match the tag, or the valid bit is 0, either way its a miss
            else begin
                hit <= 1'b0;
                miss <= 1'b1;
            end    
        end
        // if the cache is enabled and were writing a block of data
        else if (loadLine) begin
            dataArray[index] <= blkIn;
            tagArray[index] <= tag;
            validArray[index] <= 1'b1;
        end
    end
    */
endmodule