// 8KB instruction cache

localparam BLOCKS = 128;        // 128 cache lines
localparam BLOCK_SIZE = 512;    // 512b (64B) cache line size
localparam WORDS = 16;          // 16 words (instructions) per line
localparam WORD_SIZE = 32;      // 32 bit words (instructions)
localparam OFFSET_BITS = 4;
localparam INDEX_BITS = 7;
localparam TAG_BITS = 21;

module instr_cache (
    input clk,
    input rst,
    input [31:0] addr,
    input [511:0] blkIn,
    // loading a line
    input ld,

    output reg [31:0] instrOut,
    output reg hit,
    output reg miss

    );

    genvar i, j, k;

    // register array for cache
    reg [WORD_SIZE-1:0] dataArray [BLOCKS-1:0][WORDS-1:0];
    reg [TAG_BITS-1:0] tagArray [BLOCKS-1:0];
    reg validArray [BLOCKS-1:0];

    // internal signals
    reg [OFFSET_BITS-1:0] offset;
    reg [INDEX_BITS-1:0] index;
    reg [TAG_BITS-1:0] tag;
    logic [WORD_SIZE-1:0] blkInUnpacked [WORDS-1:0];
    logic valid;
    logic tagMatch;

    // output signals that need to be flopped
    //logic [WORD_SIZE-1:0] instrOutInt;
    //logic hitInt;
    //logic missInt;

    // internal assignments
    assign offset = addr[OFFSET_BITS-1:0]; 
    assign index = addr[OFFSET_BITS+INDEX_BITS-1:OFFSET_BITS];
    assign tag = addr[WORD_SIZE-1:OFFSET_BITS+INDEX_BITS];
    assign valid = validArray[index];
    assign tagMatch = (tag == tagArray[index]);

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
    assign blkInUnpacked[9] = blkIn[329:288];
    assign blkInUnpacked[10] = blkIn[351:320];
    assign blkInUnpacked[11] = blkIn[383:352];
    assign blkInUnpacked[12] = blkIn[415:384];
    assign blkInUnpacked[13] = blkIn[447:416];
    assign blkInUnpacked[14] = blkIn[479:448];
    assign blkInUnpacked[15] = blkIn[511:480];

    // Cache assignments
    // Update tag array
    always @(posedge clk) begin
        if (ld) begin
            tagArray[index] = tag;
        end
    end

    // Update valid array
    always @(posedge clk) begin
        if (ld) begin
            validArray[index] = 1'b1;
        end
    end

    // Update data array
    generate
    for (i = 0; i < WORDS; i++) begin
        always @(posedge clk) begin
            if (ld) begin
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
                        validArray[j] = 1'b0;
                    end
                end
            end
        end
    endgenerate

    // output assignments
    // instrOut is a NOP on a miss
    assign instrOut = (hit) ? dataArray[index][offset] : 32'h08000000;
    assign hit = (valid & tagMatch);
    assign miss = (~hit);

    // Flop outputs
    //always @(posedge clk) begin
    //    instrOut <= instrOutInt;
    //    hit <= hitInt;
    //    miss <= missInt;
    //end

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