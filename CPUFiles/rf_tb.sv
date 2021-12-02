//`timescale 1ns/1ps
module rf_tb();

    logic clk, rst, write;
    logic [3:0] read1RegSel;
    logic [3:0] read2RegSel;
    logic [3:0] writeRegSel;
    logic [31:0] writeData;
    
    logic [31:0] read1DataActual;
    logic [31:0] read2DataActual;
    logic errActual;
    logic [31:0] read1DataExpected;
    logic [31:0] read2DataExpected;
    logic errExpected;

    int errors = 0;

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
        //-------------Test 1--------------------------
	clk = 1'b0;
        rst = 1'b1;
        write = 1'b0;
        read1RegSel = 4'b0000;
        read2RegSel = 4'b0000;
        writeRegSel = 4'b0000;
        writeData = 32'h00000000;
        read1DataExpected = 32'h00000000;
        read2DataExpected = 32'h00000000;
	@(posedge clk);
        @(negedge clk);
        if(read1DataActual != read1DataExpected || read2DataActual != read2DataExpected)begin
            $display("Test 1 Failed");
            errors++;
        end
        //-----------------Test 2-----------------------
        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        write = 1'b1;
        writeData = 32'hABCD1234;
        writeRegSel = 4'b1010;
        @(posedge clk);
        @(negedge clk);
        write = 1'b0;
        read1RegSel = 4'b1010;
        read2RegSel = 4'b1111;
        read1DataExpected = 32'hABCD1234;
        read2DataExpected = 32'h00000000;
	@(posedge clk);
        @(negedge clk);
        if(read1DataActual != read1DataExpected || read2DataActual != read2DataExpected)begin
            $display("Test 2 Failed");
            errors++;
        end
        //-----------------Test 3-----------------------
        @(negedge clk);
        write = 1'b1;
        writeData = 32'h1234ABCD;
        writeRegSel = 4'b1010;
        @(posedge clk);
        @(negedge clk);
        write = 1'b0;
        read1RegSel = 4'b1010;
        read2RegSel = 4'b1110;
        read1DataExpected = 32'h1234ABCD;
        read2DataExpected = 32'h00000000;
	@(posedge clk);
        @(negedge clk);
        if(read1DataActual != read1DataExpected || read2DataActual != read2DataExpected)begin
            $display("Test 3 Failed");
            errors++;
        end
	//-----------------Test 4-----------------------
        @(negedge clk);
        write = 1'b1;
        writeData = 32'h00000666;
        writeRegSel = 4'b0100;
        @(posedge clk);
        @(negedge clk);
        write = 1'b0;
        read1RegSel = 4'b0100;
        read2RegSel = 4'b1010;
        read1DataExpected = 32'h00000666;
        read2DataExpected = 32'h1234ABCD;
	@(posedge clk);
        @(negedge clk);
        if(read1DataActual != read1DataExpected || read2DataActual != read2DataExpected)begin
            $display("Test 4 Failed");
            errors++;
        end
	//-----------------Test 5-----------------------
        @(negedge clk);
        write = 1'b1;
        writeData = 32'h00000665;
        writeRegSel = 4'b0000;
        @(posedge clk);
        @(negedge clk);
        write = 1'b0;
        read1RegSel = 4'b0000;
        read2RegSel = 4'b0100;
        read1DataExpected = 32'h00000665;
        read2DataExpected = 32'h00000666;
	@(posedge clk);
        @(negedge clk);
        if(read1DataActual != read1DataExpected || read2DataActual != read2DataExpected)begin
            $display("Test 5 Failed");
            errors++;
        end
	//-----------------Test 6-----------------------
        @(negedge clk);
        write = 1'b1;
        writeData = 32'h00000020;
        writeRegSel = 4'b0001;
        @(posedge clk);
        @(negedge clk);
        write = 1'b0;
        read1RegSel = 4'b0001;
        read2RegSel = 4'b0100;
        read1DataExpected = 32'h00000020;
        read2DataExpected = 32'h00000666;
	@(posedge clk);
        @(negedge clk);
        if(read1DataActual != read1DataExpected || read2DataActual != read2DataExpected)begin
            $display("Test 6 Failed");
            errors++;
        end
	//-----------------Test 7-----------------------
        @(negedge clk);
	//Thesting to see if on the cycle it will get the old data then overwrite it after old data is used
	write = 1'b1;
	writeData = 32'h00001234;
	writeRegSel = 4'b0001;
        if(read1DataActual != read1DataExpected || read2DataActual != read2DataExpected)begin
            $display("Test 7 Failed");
            errors++;
        end
	@(posedge clk);
	@(negedge clk);
	read1DataExpected = 32'h00001234;
	if(read1DataActual != read1DataExpected || read2DataActual != read2DataExpected)begin
            $display("Test 69 Failed");
            errors++;
        end
        if(errors == 0)begin
            $display("YAHOO! All tests passed");
        end else begin
            $display("ARG! Your Code be Blasted");
        end

        $stop();
    end

    always #5 clk = ~clk;

endmodule