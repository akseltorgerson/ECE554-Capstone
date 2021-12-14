module fft_ram_tb();


    logic clk, rst;
    logic load, externalLoad;
    logic [9:0] indexA, indexB;
    logic [31:0] A_real_i, A_imag_i, B_real_i, B_imag_i;
    logic [31:0] A_real_o, A_imag_o, B_real_o, B_imag_o;

    fft_ram iRAM(.clk(clk),
                 .rst(rst),
                 .load(load),
                 .externalLoad(externalLoad),
                 .indexA(indexA),
                 .indexB(indexB),
                 .A_real_i(A_real_i),
                 .A_imag_i(A_imag_i),
                 .B_real_i(B_real_i),
                 .B_imag_i(B_imag_i),
                 .A_real_o(A_real_o),
                 .A_imag_o(A_imag_o),
                 .B_real_o(B_real_o),
                 .B_imag_o(B_imag_o));
    initial begin
        clk = 1'b0;
        rst = 1'b0;
        load = 1'b0; //Load data from the butterfly unit
        externalLoad = 1'b0; //data coming in from the fifo, fifo wants to load data into the ram
        indexA = 10'b0; //index of where to store the data
        indexB = 10'b0; //index of where to store the data
        A_real_i = 32'b0;
        B_imag_i = 32'b0;
        A_real_i = 32'b0;
        B_imag_i = 32'b0;

        //RESET
        rst = 1'b1;

        @(posedge clk);
        @(negedge clk);
        rst = 1'b0;
        
    end

    always #5 clk = ~clk;

endmodule