`timescale 1ns / 1ps

module tb_rgb_led();

    // 输入信号用 reg
    reg clk_50m;
    reg rst_n;
    reg sw_key;
    
    // 输出信号用 wire
    wire [2:0] rgb1;

    // 实例化我们要测试的模块
    rgb_led u_rgb_led (
        .clk_50m(clk_50m),
        .rst_n(rst_n),
        .sw_key(sw_key),
        .rgb1(rgb1)
    );

    // 生成 50MHz 时钟 (周期 20ns)
    initial begin
        clk_50m = 0;
        forever #10 clk_50m = ~clk_50m; 
    end

    // 给定激励信号，并生成 GTKWave 需要的 .vcd 文件
    initial begin
        $dumpfile("rgb_wave.vcd"); // 声明波形文件名
        $dumpvars(0, tb_rgb_led);  // 记录该模块下所有信号

        // 初始化
        rst_n = 0;
        sw_key = 1;
        
        // 延时释放复位
        #100;
        rst_n = 1;

        // 运行足够长的时间以观察颜色切换
        // 因为我们上面缩短了计数器，这里跑 50000ns 就足够看到好几次颜色循环了
        #50000; 
        
        $finish; // 结束仿真
    end

endmodule