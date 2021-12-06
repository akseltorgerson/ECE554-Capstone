module data_cache_tb();
    localparam BLOCKS = 1024;
    localparam BLOCK_SIZE = 512;
    localparam WORDS = 16;
    localparam WORD_SIZE = 32;
    localparam OFFSET_BITS = 4;
    localparam INDEX_BITS = 10;
    localparam TAG_BITS = 18;

    // input signals
    logic clk;
    logic rst;
    logic en;
    logic [31:0] addr;
    logic [511:0] blkIn;
    logic [31:0] dataIn;
    logic rd;
    logic wr;
    logic ld;

    // output signals
    logic [31:0] dataOut;
    logic hit;
    logic miss;
    logic evict;
    logic [511:0] blkOut;

    // other variables
    integer errors;

    always #5 clk = ~clk;

    data_cache iCache(.*);

    initial begin
        clk = 1'b0;
        rst = 1'b0;
        en = 1'b0;
        addr = 32'b0;
        blkIn = 512'b0;
        blkOut = 512'b0;
        dataIn = 32'b0;
        rd = 1'b0;
        wr = 1'b0;
        ld = 1'b0;
        rd = 1'b0;
        wr = 1'b0;
        ld = 1'b0;

        errors = 0;
    
        // RESET
        @(posedge clk);
        rst = 1'b1;
        @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        // Cache is empty, test a read
        en = 1'b1;
        rd = 1'b1;
        wr = 1'b0;
        ld = 1'b0;
        addr = 31'b00;
        @(posedge clk);

        if (miss == 1'b0 || hit == 1'b1 || evict == 1'b1 || dataOut != 32'b0 || blkOut != 512'b0) begin
            errors += 1;
        end

        // Still empty, test a write
        en = 1'b1;
        rd = 1'b0;
        wr = 1'b1;
        ld = 1'b0;
        addr = 31'b0;
        @(posedge clk);

        if (miss == 1'b0 || hit == 1'b1 || evict == 1'b1 || dataOut != 32'b0 || blkOut != 512'b0) begin
            errors += 1;
        end

        // Still empty, test no enable
        en = 1'b0;
        rd = 1'b1;
        wr = 1'b1;
        ld = 1'b0;
        addr = 31'b0;
        @(posedge clk);

        if (miss == 1'b0 || hit == 1'b1 || evict == 1'b1 || dataOut != 32'b0 || blkOut != 512'b0) begin
            errors += 1;
        end

        // Load in some blocks
        en = 1'b1;
        rd = 1'b0;
        wr = 1'b0;
        ld = 1'b1;
        // Maps to line 0
        addr = 31'b000000000000000000_0000000000_0000;
        // blkIn is 16 words, each 32 bits, 
        blkIn = {32'd15, 32'd14, 32'd13, 32'd12, 32'd11, 32'd10, 32'd9, 32'd8, 32'd7, 32'd6, 32'd5, 32'd4, 32'd3, 32'd2, 32'd1, 32'd0};
        @(posedge clk);
        // Maps to line 1
        addr = 31'b000000000000000000000001_0001_0000;
        blkIn = {32'd31, 32'd30, 32'd29, 32'd28, 32'd27, 32'd26, 32'd25, 32'd24, 32'd23, 32'd22, 32'd21, 32'd20, 32'd19, 32'd18, 32'd17, 32'd16};
        @(posedge clk);

        // Try to read some data
        en = 1'b1;
        rd = 1'b1;
        wr = 1'b0;
        ld = 1'b0;
        addr = 31'b0000_0000_0000_0000_0000_0000_0000_0000;
        @(posedge clk);

        if (dataOut != 32'b0 || hit == 1'b0 || miss == 1'b1) begin
            errors += 1;
        end

        // Read a different data
        en = 1'b1;
        rd = 1'b1;
        wr = 1'b0;
        ld = 1'b0;
        addr = 31'b000000000000000000_0000000001_0110;
        @(posedge clk);
        @(posedge clk);

        if (dataOut != 32'd22 || hit == 1'b0 || miss == 1'b1) begin
            $display("ERROR: Expected: %d, Got: %d", 22, dataOut);
            errors += 1;
        end

        // Write some data
        en = 1'b1;
        rd = 1'b0;
        wr = 1'b1;
        ld = 1'b0;
        addr = 31'b000000000000000000_0000000001_0001;
        dataIn = 32'hFFFFFFFF;
        @(posedge clk);
        @(posedge clk);

        // Read that data
        en = 1'b1;
        rd = 1'b1;
        wr = 1'b0;
        ld = 1'b0;
        addr = 31'b000000000000000000_0000000001_0001;
        @(posedge clk);
        @(posedge clk);

        if (dataOut != 32'hFFFFFFFF || hit == 1'b0 || miss == 1'b1) begin
            $display("ERROR: Expected: %h, Got: %h", 32'hFFFFFFFF, dataOut);
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