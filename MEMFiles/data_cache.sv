// 32KB instruction cache

localparam BLOCKS = 256;       // 1024 cache lines
localparam BLOCK_SIZE = 512;    // 512b (64B) cache line size
localparam WORDS = 16;          // 16 words per line
localparam WORD_SIZE = 32;      // 32 bit words
localparam OFFSET_BITS = 4;     // 2^4 = 16 (words per line)
localparam INDEX_BITS = 8;     // 2^10 = 1024
localparam TAG_BITS = 20;       // 32 - 4 - 10 = 18

module data_cache (
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
    output reg [31:0] dataOut,

    // request was a hit
    output reg hit,

    // request was a miss
    output reg miss,

    // block needs to be evicted
    output reg evict,

    // block that is getting evicted
    output reg [511:0] blkOut
    );

    // TODO talk to winor or josh about cache coherency
    genvar i, j, k;

    // register arrays for cache
    reg [WORD_SIZE-1:0] dataArray [BLOCKS-1:0][WORDS-1:0];
    reg [TAG_BITS-1:0] tagArray [BLOCKS-1:0];
    reg validArray [BLOCKS-1:0];
    reg dirtyArray [BLOCKS-1:0];

    // internal signals
    logic [OFFSET_BITS-1:0] offset;
    logic [INDEX_BITS-1:0] index;
    logic [TAG_BITS-1:0] tag;
    logic [WORD_SIZE-1:0] blkInUnpacked [WORDS-1:0];
    logic [BLOCK_SIZE:0] blkOutPacked;
    logic valid;
    logic dirty;
    logic tagMatch;
    logic read;
    logic write;
    logic load;

    // output signals that need to be flopped
    //logic [WORD_SIZE-1:0] dataOutInt;
    //logic hitInt;
    //logic missInt;
    //logic evictInt;
    //logic [BLOCK_SIZE:0] blkOutInt;

    // internal assignments
    assign offset = addr[OFFSET_BITS-1:0]; 
    assign index = addr[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS];
    assign tag = addr[WORD_SIZE-1:OFFSET_BITS+INDEX_BITS];
    assign valid = validArray[index];
    assign dirty = dirtyArray[index];
    assign tagMatch = (tag == tagArray[index]);
    assign read = (en & rd & !wr & !ld);
    assign write = (en & !rd & wr & !ld);
    assign load = (en & !rd & !wr & ld);

    // Unpack blkIn
    assign blkInUnpacked[0] = blkIn[31:0];
    assign blkInUnpacked[1] = blkIn[63:32];
    assign blkInUnpacked[2] = blkIn[95:64];
    assign blkInUnpacked[3] = blkIn[127:96];
    assign blkInUnpacked[4] = blkIn[159:128];
    assign blkInUnpacked[5] = blkIn[191:160];
    assign blkInUnpacked[6] = blkIn[223:192];
    assign blkInUnpacked[7] = blkIn[255:224];
    assign blkInUnpacked[8] = blkIn[287:256];
    assign blkInUnpacked[9] = blkIn[319:288];
    assign blkInUnpacked[10] = blkIn[351:320];
    assign blkInUnpacked[11] = blkIn[383:352];
    assign blkInUnpacked[12] = blkIn[415:384];
    assign blkInUnpacked[13] = blkIn[447:416];
    assign blkInUnpacked[14] = blkIn[479:448];
    assign blkInUnpacked[15] = blkIn[511:480];

    // Pack blkOut
    assign blkOutPacked = { dataArray[index][15],
                            dataArray[index][14],
                            dataArray[index][13],
                            dataArray[index][12],
                            dataArray[index][11],
                            dataArray[index][10],
                            dataArray[index][9],
                            dataArray[index][8],
                            dataArray[index][7],
                            dataArray[index][6],
                            dataArray[index][5],
                            dataArray[index][4],
                            dataArray[index][3],
                            dataArray[index][2],
                            dataArray[index][1],
                            dataArray[index][0]};

    // Cache assignments
    // Update tag array
    always @(posedge clk) begin
        if (load) begin
            tagArray[index] = tag;
        end
    end      

    // Update dirty array
    always @(posedge clk) begin
        if (load) begin
            dirtyArray[index] = 1'b0;
        end else if (write & hit) begin
            dirtyArray[index] = 1'b1;
        end
    end

    // Update valid array
    always @(posedge clk) begin
        if (load) begin
            validArray[index] = 1'b1;
        end
    end

    // Update data array
    generate
    for (i = 0; i < WORDS; i++) begin
        always @(posedge clk) begin
            if (write & hit && offset == i) begin
                dataArray[index][i] = dataIn;
            end else if (load) begin
                dataArray[index][i] = {blkInUnpacked[i]};
            end
        end
    end
    endgenerate

    // Reset sequence
    generate
        for (j = 0; j < BLOCKS; j++) begin
            for (k = 0; k < WORDS; k++) begin
                always @(posedge rst) begin
                    if (rst) begin
                        dataArray[j][k] = 32'b0;
                        tagArray[j] = {TAG_BITS{1'b0}};
                        dirtyArray[j] = 1'b0;
                        validArray[j] = 1'b0;
                    end
                end
            end
        end
    endgenerate


    // output assignments
    assign dataOut = (read & hit) ? dataArray[index][offset] : 32'h0;
    assign hit = (valid & tagMatch);
    assign miss = (~hit);
    assign evict = (miss & dirty & valid);
    assign blkOut = (evict) ? blkOutPacked : 512'b0;

    // Flop outputs
    //always @(posedge clk) begin
    //    dataOut <= dataOutInt;
    //    hit <= hitInt;
    //    miss <= missInt;
    //    evict <= evictInt;
    //    blkOut <= blkOutInt;
    //end

endmodule