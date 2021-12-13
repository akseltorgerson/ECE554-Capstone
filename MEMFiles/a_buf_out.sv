module a_buf_out (

    // This buffer will store data from accelerator going to host memory
    input clk, rst,
    input wrEn,                     // control signal from the accelerator CU to let us know that the data is valid
    input reg [63:0] dataIn,        // data point from the accelerator
    input accelWrBlkDone,           // signal form the 
    output reg bufferFull,          // control signal to let the MC know we can start writing data
    output reg [511:0] dataOut,     // data leaving the buffer going to host mem
    output reg dataOutValid        // signal to let the MC know the data on the bus is valid
);

    localparam DEPTH = 1024;
    localparam WIDTH = 64;
    localparam DATA_OUT_WIDTH = 512;

    // Register to hold {imag, real} data members
    // 8kB
    reg [WIDTH-1:0] buffer [DEPTH];
    logic [$clog2(DEPTH)-1:0] index;
    logic [$clog2(DEPTH)-1:0] outIndex;

    integer i, j, k;

    /********************************************************
    *                     Reset Sequence                    *
    ********************************************************/
    always_ff @(posedge clk) begin
        if (rst) begin
            index <= 10'b0;
            outIndex <= 10'b0;
            bufferFull <= 1'b0;
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
            buffer[index] <= dataIn;
            if (&index) begin
                bufferFull <= 1'b1;
                dataOutValid <= 1'b1;
            end else begin
                bufferFull <= 1'b0;
            end
            index <= index + 1'b1;
        end
    end

    /********************************************************
    *                    Empty Sequence                     *
    ********************************************************/
    always_ff @(posedge clk) begin
        if (bufferFull & accelWrBlkDone) begin 
            if (outIndex == 10'h3F8) begin
                bufferFull <= 1'b0;
                dataOutValid <= 1'b0;
            end else begin
                dataOutValid <= 1'b1;
            end
            outIndex <= outIndex + 4'b1000;
        end
    end

    assign dataOut = {buffer[outIndex+7],
                            buffer[outIndex+6],
                            buffer[outIndex+5],
                            buffer[outIndex+4],
                            buffer[outIndex+3],
                            buffer[outIndex+2],
                            buffer[outIndex+1],
                            buffer[outIndex]};

endmodule