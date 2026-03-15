`timescale 1ns / 1ps

module tb_counter_load;

    reg clk;
    reg rst_n;
    reg load;
    reg enable;
    reg [7:0] data_in;
    wire [7:0] count;

    counter_load uut (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .enable(enable),
        .data_in(data_in),
        .count(count)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("counter_load.vcd");
        $dumpvars(0, tb_counter_load);

        clk = 0; rst_n = 0; load = 0; enable = 0; data_in = 8'h00;

        #15 rst_n = 1;

        // 1. 测试正常使能累加
        #10 enable = 1;
        #50 enable = 0;

        // 2. 测试并行载入 (瞬间跳转到 16进制的A5，也就是十进制的165)
        #10 data_in = 8'hA5;
        load = 1;
        #10 load = 0;

        // 3. 载入后继续累加，看是不是从 A5 开始往上加
        #10 enable = 1;
        #50;

        // 4. 测试“作弊”途中突然被异步复位击杀
        rst_n = 0;
        #10 rst_n = 1;
        #20;

        $finish;
    end

endmodule