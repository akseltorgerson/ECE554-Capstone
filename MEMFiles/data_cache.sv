// 64KB instruction cache

`define BLOCKS 1024     // 128 cache lines
`define BLOCK_SIZE 512  // 512b (64B) cache line size
`define WORDS 16        // 16 words per line
`define WORD_SIZE 32    // 32 bit words
`define OFFSET_BITS 4   // 2^4 = 16 (words per line)
`define INDEX_BITS 10   // 2^10 = 1024
`define TAG_BITS 18     // 32 - 4 - 10 = 18

module iCache (
    input clk,
    input rst,

    // enables the cache
    input en,

    // address of request
    input [31:0] addr,

    // block that is getting stored to a cache line
    input [511:0] blkIn,

    // data coming into cache
    input [31:0] dataIn,

    // indicates we want a cache read
    input rd,

    // indicates we want a cache write
    input wr,

    // indicates that we are loading a cache line
    input ld,

    // output data read from cache
    output [31:0] dataOut,

    // request was a hit
    output hit,

    // request was a miss
    output miss,

    // block needs to be evicted
    output evict,

    // block that is getting evicted
    output [511:0] blkOut
    );

    // TODO talk to winor or josh about cache coherency

    // register arrays for cache
    reg [BLOCK_SIZE-1:0] dataArray [BLOCKS-1:0];
    reg [TAG_BITS-1:0] tagArray [BLOCKS-1:0];
    reg validArray [BLOCKS-1:0];
    reg dirtyArray [BLOCKS-1:0];

    // internal signals
    logic [OFFSET_BITS-1:0] offset;
    logic [INDEX_BITS-1:0] index;
    logic [TAG_BITS-1:0] tag;
    logic valid;
    logic dirty;
    logic tagMatch;
    logic read;
    logic write;
    logic load;

    // output signals that need to be flopped
    logic [WORD_SIZE-1:0] dataOutInt;
    logic hitInt;
    logic missInt;
    logic evictInt;
    logic [BLOCK_SIZE:0] blkOutInt;

    // internal assignments
    assign offset = addr[OFFSET_BITS-1:0]; 
    assign index = addr[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS];
    assign tag = addr[WORD_SIZE-1:OFFSET_BITS+INDEX_BITS];
    assign valid = validArray[index];
    assign dirty = dirtyArray[index];
    assign tagMatch = (index == tagArray[index]);
    assign read = (en & rd & !wr & !ld);
    assign write = (en & !rd & wr & !ld);
    assign load = (en & !rd & !wr & ld);
    // TODO this might be a bitch, might need to use a generate loop here
    assign dataArray[index][offset] = (write & hit) ? dataIn : dataArray[index][offset];
    // TODO i think this one is right
    assign dataArray[index] = (load) ? blkIn : dataArray[index];

    // output assignments
    // TODO need to unpack this
    assign dataOutInt = (read & hit) ? dataArray[index][offset] : 32'b0;
    assign hitInt = (valid & tagMatch);
    assign missInt = (~hit);
    assign evictInt = (miss & dirty & valid);
    assign blkOutInt = (evictInt) ? dataArray[index] : 512'b0;

    // reset
    always @(posedge rst) begin
        for (int i = 0; i < BLOCKS; i++) begin
            dataArray[i] <= 512'b0;
            tagArray[i] <= 18'b0;
            validArray[i] <= 1'b0;
            dirtyArray[i] <= 1'b0;
        end
    end

    // assign these at the clock to ensure no ?metastability?
    always @(posedge clk) begin
        dataOut <= dataOutInt;
        hit <= hitInt;
        miss <= missInt;
        evict <= evictInt;
        blkOut <= blkOutInt;
    end




/* TODO I think this is right, untested, but above is using assign statements
    always @(posedge clk) begin
        
        // if the cache is enabled, and we want to READ, not write, and not load
        if (read) begin
            // if the cache line is valid, and the tag matches the tag array at the given index, hit
            if (validArray[index] && (index == tagArray[index])) begin
                hit <= 1'b1;
                miss <= 1'b0;
                evict <= 1'b0;
                // TODO need to unpack  dataArray[index] just only to grab the 32 bits we want
                dataOut <= dataArray[index][offset];
            end
            // if the cache line is not valid, or the tag array does not match, its a miss
            else begin
                miss <= 1'b1;
                hit <= 1'b0;
                // we only need to evict if the dirty (modified) bit is 1 and its valid
                if (dirtyArray[index] && validArray[index]) begin
                    evict <= 1'b1;
                    blkOut <= dataArray[index];
                end
                // if we don't need to evict, we can just overwrite that block
                else begin
                    evict <= 1'b0;
                end
            end
        end

        // if the cache is enabled, and we want to WRITE, not read, and not load
        else if (write) begin
            // if the cache line is valid, and the tag matches the tag array at the given index, hit
            if (validArray[index] && (index == tagArray[index])) begin
                hit <= 1'b1;
                miss <= 1'b0;
                evict <= 1'b0;
                // TODO will need to unpack
                dataArray[index][offset] <= dataIn;
                dirtyArray[index] <= 1;
            end
            // if the cache line is not valid, or the tag array does not match, its a miss
            else begin
                miss <= 1'b1;
                hit <= 1'b0;
                // we will only need to evict if its dirty and valid
                if (dirtyArray[index] && validArray[index]) begin
                    evict <= 1'b1;
                    blkOut <= dataArray[index];
                end
                // if we dont need to evict, we can just overwrite that block with the correct one
                else begin
                    evict <= 1'b0;
                end
            end=
        end

        // if the cache is enabled, and we want to LOAD a line, not read, or write
        else if (write) begin
            // we will only be loading a block after evicting it if needed
            dataArray[index] <= blkIn;
            tagArray[index] <= tag;
            validArray[index] <= 1'b1;
            dirtyArray[index] <= 1'b0;
        end

    end
    */
endmodule