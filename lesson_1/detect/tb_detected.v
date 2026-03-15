`timescale 1ns / 1ps

module tb_seq_detector;

    reg clk;
    reg rst_n;
    reg din;
    wire detected;

    seq_detector uut (
        .clk(clk),
        .rst_n(rst_n),
        .din(din),
        .detected(detected)
    );

    // 造心跳
    always #5 clk = ~clk;

    initial begin
        $dumpfile("seq_detector.vcd");
        $dumpvars(0, tb_seq_detector);

        // 初始化
        clk = 0; rst_n = 0; din = 0;
        #15 rst_n = 1; // 释放复位

        // 开始喂数据：目标是检测 1011
        // 我们喂一串连续数据: 0 -> 1 -> 0 -> 1 -> 1 -> 0 -> 1 -> 1
        #10 din = 0; 
        
        #10 din = 1; // S1
        #10 din = 0; // S2 (10)
        #10 din = 1; // S3 (101)
        #10 din = 1; // S4 (1011) -> 此时 detected 应该变成 1！
        
        #10 din = 0; // S2 (拿着上一次的尾巴1，加上这个0，变成10)
        #10 din = 1; // S3 (101)
        #10 din = 1; // S4 (1011) -> 再次重叠检测成功！detected 再次变 1！

        #10 din = 0; // 扰乱它
        #10 din = 0;
        
        #20 $finish;
    end
endmodule