/*****************************************************************
***********FPGA实验*************                  
**软    件:GOwin云源软件                
**项    目:modelsim仿真测试文件                      
**时    钟:50MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
 `timescale 1ns/1ns 
module top_tb();
//信号定义
reg			clk_50m			;
reg			rst_n			;

reg			uart_rx			;
wire	 [7:0]	 seg			;
wire	 [3:0]	 sel			;
//模块例化
top  u1_top(
    /*input              */.clk_50m (clk_50m ) ,//时钟输入
    /*input              */.rst_n   (rst_n   ) ,//复位输入
    /*input              */.uart_rx (uart_rx ) ,
    /*output      [7:0]  */.seg     (seg     ) ,//段选
    /*output      [3:0]  */.sel     (sel     )  //位选
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
    uart_rx = 1'b1 ;
    #600;

    uart_rx = 1'b0;//起始位
    #400;
    uart_rx = 1'b1;//bit0
    #400;
    uart_rx = 1'b0;//bit1
    #400;
    uart_rx = 1'b0;//bit2
    #400;
    uart_rx = 1'b0;//bit3
    #400;
    uart_rx = 1'b0;//bit4
    #400;
    uart_rx = 1'b1;//bit5
    #400;
    uart_rx = 1'b1;//bit6
    #400;
    uart_rx = 1'b0;//bit7
    #400;
    uart_rx = 1'b1;//校验位
    #400;
    uart_rx = 1'b1;//结束位
    #400;
    #1000
    $stop;

    end
endmodule