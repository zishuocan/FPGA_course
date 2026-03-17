`timescale 1ns/1ns
module key_filter_tb;
defparam u1.CNT_MAX = 10 ;//参数重定义
//信号定义
reg clk_50m;
reg rst_n;
reg key;
 
wire key_vld;
wire data   ;
//模块例化
key_filter u1(
    /*input        */.clk_50m (clk_50m )    ,
    /*input        */.rst_n   (rst_n   )    ,
    /*input        */.key     (key     )    ,//按键输入
    /*output  reg  */.key_vld (key_vld )    ,//按键输出
    /*output       */.key_data(key_data)     //按键值输出
);
//时钟
always #10 clk_50m = !clk_50m ;
//赋值激励信号
initial begin    
    rst_n   <= 1'b0;
    clk_50m <= 1'b0;
    key = 1'b1; 
    #100
rst_n   <= 1'b1;
    key = 1'b0;
    #30

    key = 1'b1;
    #10

    key = 1'b0;
    #10

    key = 1'b1;
    #20
    key = 1'b0;
    #1000    

    key = 1'b1;
    #20
    key = 1'b0;
    #20
    key = 1'b1;
    #1000 
$stop ;
    
end
endmodule