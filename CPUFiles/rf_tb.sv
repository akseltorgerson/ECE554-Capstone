module rf_tb();

    logic clk, rst, write;
    logic [3:0] read1RegSel;
    logic [3:0] read2RegSel;
    logic [3:0] writeRegSel;
    logic [31:0] writeData;
    
    logic [31:0] read1Data;
    logic [31:0] read2Data;
    logic err;

    rf iRegFile(.clk(clk), 
                .rst(rst), 
                .read1Data(read1Data), 
                .read2Data(read2Data), 
                .err(err), 
                .read1RegSel(read1RegSel), 
                .read2RegSel(read2RegSel), 
                .writeRegSel(writeRegSel), 
                .writeData(writeData), 
                .write(write));

    initial begin
        
    end

endmodule