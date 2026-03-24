 `timescale 1ns/1ns 
module uart_tb();
//信号定义
reg			clk_50m			;
reg			rst_n			;
reg			rx			;
wire	 	 tx 			;
//模块例化
uart  u1_uart(
    /*input     */.clk_50m (clk_50m ),//时钟输入
    /*input     */.rst_n   (rst_n   ),//复位输入
    /*input     */.rx      (rx      ),//串口接收
    /*output    */.tx      (tx      ) //串口发送
    );


//时钟 复位初始化
    initial begin
        clk_50m = 1'b0 ;
        rst_n = 1;
        #10;
        rst_n = 0;
        #40;
        rst_n = 1;
    end
    always #10 clk_50m = ~clk_50m ;
//输入信号设置
    initial begin
    rx = 1'b1 ;
    #600;

    rx = 1'b0;//起始位
    #400;
    rx = 1'b1;//bit0     8'b0110_0001
    #400;
    rx = 1'b0;//bit1
    #400;
    rx = 1'b0;//bit2
    #400;
    rx = 1'b0;//bit3
    #400;
    rx = 1'b0;//bit4
    #400;
    rx = 1'b1;//bit5
    #400;
    rx = 1'b1;//bit6
    #400;
    rx = 1'b0;//bit7
    #400;
    rx = 1'b1;//校验位
    #400;
    rx = 1'b1;//结束位
    #400;
    #10000
    $stop;

    end
endmodule