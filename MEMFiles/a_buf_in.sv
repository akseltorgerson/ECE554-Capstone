module a_buf_in ( 

    // This buffer will store data from host memory to accelerator
    input clk, rst,
    input wrEn,                 // control signal from MC that the data is valid to be written
    input [511:0] dataIn,       // data going into the buffer
    output reg bufferFull,      // signals to accel that the buffer can start being emptied
    output reg [63:0] dataOut,  // data going to accelerator
    output reg dataOutValid,    // signal to let the accelerator know the data on the bus is valid
    output reg fifoEmpty        // signal to let accelerator and mc know that is empty

);

    localparam DEPTH = 1024;
    localparam WIDTH = 64;
   
    // Register to hold {imag, real} data members
    // 8kB
    reg [WIDTH-1:0] buffer [DEPTH-1:0];
    logic [(WIDTH/2)-1:0] dataInUnpacked [7:0][1:0];
    logic [$clog2(DEPTH)-1:0] index;
    logic [$clog2(DEPTH)-1:0] outIndex;

    // every data in holds 8 data points, 128 dataIn cycles fill buffer
    // dataIn formatting
    // {7th imag data, 7th real data, ..... 0th imag data, 0th real data}
    // {[511:480], [479: 448], ... , [63:32], [31:0]}
    integer i, j;
    
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

    /********************************************************
    *                     Reset Sequence                    *
    ********************************************************/
    always_ff @(posedge rst) begin
        if (rst) begin
            index <= 10'b0;
            outIndex <= 10'b0;
            bufferFull <= 1'b0;
            fifoEmpty <= 1'b1;
            dataOutValid <= 1'b0;
            for (i = 0; i < DEPTH; i++) begin
                buffer[i] <= 64'b0;
            end
        end
    end

    /********************************************************
    *                     Fill Sequence                     *
    ********************************************************/
    always_ff @(posedge clk) begin
        if (wrEn) begin
            for (j = 0; j < 8; j++) begin
                buffer[index + j] <= {dataInUnpacked[j][1], dataInUnpacked[j][0]};
            end
            if (index == 10'h3F8) begin
                bufferFull <= 1'b1;
                dataOutValid <= 1'b1;
            end else begin
                bufferFull <= 1'b0;
            end
            index <= index + 4'b1000;
        end
    end

    /********************************************************
    *                    Empty Sequence                     *
    ********************************************************/
    always_ff @(posedge clk) begin
        if (bufferFull) begin
            if (&outIndex) begin
                bufferFull <= 1'b0;
                fifoEmpty <= 1'b1;
                dataOutValid <= 1'b0;
            end else begin
                fifoEmpty <= 1'b0;
                dataOutValid <= 1'b1;
            end
            outIndex <= outIndex + 1'b1;
        end
    end

    assign dataOut = buffer[outIndex];

endmodule
