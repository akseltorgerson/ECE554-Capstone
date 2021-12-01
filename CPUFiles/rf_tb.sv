module rf_tb();

    logic clk, rst, write;
    logic [3:0] read1RegSel;
    logic [3:0] read2RegSel;
    logic [3:0] writeRegSel;
    logic signed [31:0] writeData;
    
    logic signed [31:0] read1DataActual;
    logic signed [31:0] read2DataActual;
    logic errActual;
    logic signed [31:0] read1DataExpected;
    logic signed [31:0] read2DataExpected;
    logic errExpected;

    rf iRegFile(.read1Data(read1DataActual), 
                .read2Data(read2DataActual), 
                .err(errActual),
                //Inputs 
                .clk(clk), 
                .rst(rst), 
                .read1RegSel(read1RegSel), 
                .read2RegSel(read2RegSel), 
                .writeRegSel(writeRegSel), 
                .writeData(writeData), 
                .write(write));

    initial begin
        //Initialize values and reset signals
        rst = 1'b1;
        write = 1'b0;
        read1RegSel = 4'h0;
        read2RegSel = 4'h0;
        writeRegSel = 4'h0;
        writeData = 32'h0000;
        read1DataExpected = 32'h0000;
        read2DataExpected = 32'h0000;
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        write = 1'b1;
        writedata = $random();
        //LEFT OFF here


    end

    always #5 clk = ~clk;

endmodule