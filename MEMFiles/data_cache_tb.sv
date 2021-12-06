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
        @(posedge clk);

        // Cache is empty, test a read
        en = 1'b1;
        rd = 1'b1;
        wr = 1'b0;
        ld = 1'b0;
        addr = 31'b0000_0000_0000_0000;
        @(posedge clk);

        if (miss == 1'b0 || hit == 1'b1 || evict == 1'b1 || dataOut != 32'b0 || blkOut != 512'b0) begin
            errors += 1;
        end

    

    
    
    
    
    
    
    
    
        if (errors != 0) begin
            $display("TEST FAILED: %d ERRORS", errors);
        end
    
    end
    

endmodule