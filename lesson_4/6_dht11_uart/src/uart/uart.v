/************************************
***********FPGA实验*************       
**软    件：GOwin云源软件              
**项    目：xxxx                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  uart(
    input     clk_50m ,//时钟输入
    input     rst_n   ,//复位输入
    input     rx      ,//串口接收
    output    tx       //串口发送
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s

//信号定义
wire            busy     ;
wire [7:0]      rx_o     ;
wire            rx_o_vld ;

//模块例化
uart_rx  u1_uart_rx(
    /*input             */.clk_50m  (clk_50m  ) ,//时钟输入
    /*input             */.rst_n    (rst_n    ) ,//复位输入
    /*input             */.rx_i     (rx       ) ,//uart_rx  接收
    /*output reg [7:0]  */.rx_o     (rx_o     ) ,//uart_rx  输出
    /*output reg        */.rx_o_vld (rx_o_vld )  //输出有效标志
    );

uart_tx  u2_uart_tx(
    /*input             */.clk_50m  (clk_50m  ) ,//时钟输入
    /*input             */.rst_n    (rst_n    ) ,//复位输入
    /*input      [7:0]  */.data_i   (rx_o     ) ,//需要发送的数据
    /*input             */.data_vld (rx_o_vld ) ,//数据有效信号
    /*output reg        */.tx_o     (tx       ) ,//串口发送
    /*output reg        */.busy     (busy     )  //1：忙碌   0：空闲       
    );


endmodule

