module a_buf_in ( 

    // This buffer will store data from host memory to accelerator
    input clk, rst, wrEn, dequeue;
    input [511:0] dataIn;
    input mcDataValid;
    output reg dataReady;
    output reg [63:0] dataOut;

);

    localparam DEPTH = 1024;
    localparam WIDTH = 64;
   
    // Register to hold {imag, real} data members
    // 8kB
    reg [WIDTH-1:0] buffer [DEPTH];
    logic [WIDTH-1:0] dataInUnpacked [7:0][1:0];
    logic [$clog2(DEPTH)-1:0] index;
    logic [$clog2(DEPTH)-1:0] outIndex;

    // every data in holds 8 data points, 128 dataIn cycles fill buffer
    // dataIn formatting
    // {7th imag data, 7th real data, ..... 0th imag data, 0th real data}
    // {[511:480], [479: 448], ... , [63:32], [31:0]}
    integer i, j, k;
    
    assign dataInUnpacked[0][0] = {dataIn[31:0]};
    assign dataInUnpacked[0][1] = {dataIn[63:32]};
    assign dataInUnpacked[1][0] = {dataIn[95:64]};
    assign dataInUnpacked[1][1] = {dataIn[127:96]};
    assign dataInUnpacked[2][0] = {dataIn[159:128]};
    assign dataInUnpacked[2][1] = {dataIn[191:160]};
    assign dataInUnpacked[3][0] = {dataIn[223:192]};
    assign dataInUnpacked[3][1] = {dataIn[255:224]};
    assign dataInUnpacked[4][0] = {dataIn[287:256]};
    assign dataInUnpacked[4][1] = {dataIn[319:288]};
    assign dataInUnpacked[5][0] = {dataIn[351:320]};
    assign dataInUnpacked[5][1] = {dataIn[383:352]};
    assign dataInUnpacked[6][0] = {dataIn[415:384]};
    assign dataInUnpacked[6][1] = {dataIn[447:416]};
    assign dataInUnpacked[7][0] = {dataIn[479:448]};
    assign dataInUnpacked[7][1] = {dataIn[511:480]};

    // reset sequence
    always_ff @(posedge rst) begin
        if (rst) begin
            index <= 0;
            outIndex <= 0;
            dataRead <= 0;
            for (i = 0; i < DEPTH; i++) begin
                buffer[i] <= 64'b0;
            end
        end
    end

    // Buffer fill proccess
    always_ff @(posedge clk) begin
        if (wrEn && mcDataValid) begin
            for (j = 0; j < 8; j++) begin
                buffer[index + j] <= {dataInUnpacked[index + j][1], dataInUnpacked[index + j][0]};
            end
            if (index == 12'h3F8) begin
                dataReady <= 1'b1;
            end else begin
                dataReady <= 1'b0;
            end
            index <= index + 8;
        end
    end

    // Buffer empty process
    always_ff @(posedge clk) begin
        if (dequeue) begin
            outIndex <= outIndex + 1;
        end
    end

    assign dataOut = buffer[outIndex];

endmodule
