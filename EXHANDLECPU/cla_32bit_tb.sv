module cla_32bit_tb();

    logic [31:0] input1;
    logic [31:0] input2;
    logic P, G, Cin, Cout;
    logic [31:0] actualSum;
    logic [31:0] expectedSum;

    int errors = 0;

    cla_32bit iCLA(.A(input1), 
                   .B(input2), 
                   .Cin(Cin), 
                   .Sum(actualSum), 
                   .Cout(Cout),
                   .P(P),
                   .G(G));

    initial begin
        
        for(int i = 0; i < 100; i++)begin
            input1 = $random();
            input2 = $random();
            Cin = 1'b0;
            expectedSum = input1 + input2;

            #5;

            if(expectedSum != actualSum) begin
                errors++;
                $display("Expected sum did not equal actual sum");
            end
        end

        if(errors == 0) begin
            $display("YAHOO! All tests passed");
        end else begin
            $display("MESSED UP");
        end

        $stop();
    end

endmodule