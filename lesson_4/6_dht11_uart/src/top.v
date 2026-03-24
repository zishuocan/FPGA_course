
module  top(
    input         clk_50m ,//时钟输入
    input         rst_n   ,//复位输入
    inout         dht11   ,//单总线输入输出
    output        tx      ,//uart_tx 
    output [7:0]  led      //led  测试   发送数据会点亮led
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s


//信号定义
wire         key_vld    ;
wire  [31:0] data_valid ;
wire  [7:0]  data_o     ;
wire         data_o_vld ;
wire         busy       ;

//模块例化
    dht11_drive  u2_dht11_drive (
    /*input               */.clk_50m    (clk_50m    ) ,   //系统时钟
    /*input               */.rst_n      (rst_n      ) ,   //系统复位     
    /*inout               */.dht11      (dht11      ) ,   //dht11温湿度传感器单总线
    /*output reg  [31:0]  */.data_valid (data_valid )     //有效输出数据  8bit 湿度整数数据+8bit 湿度小数数据+8bit 温度整数数据+8bit 温度小数数据
    );  
    data_ctrl  u3_data_ctrl(
    /*input              */.clk_50m     (clk_50m    ) ,//时钟输入
    /*input              */.rst_n       (rst_n      ) ,//复位输入
    /*input      [31:0]  */.dht_data    (data_valid ) ,//{8bit 湿度整数数据+8bit 湿度小数数据+8bit 温度整数数据+8bit 温度小数数据}
    /*output reg [7:0]   */.data_o      (data_o     ) ,//显示数据
    /*output reg         */.data_o_vld  (data_o_vld )  //数据有效信号  使能uart_tx
    );
    uart_tx  u4_uart_tx(
    /*input               */.clk_50m    (clk_50m    ) ,//时钟输入
    /*input               */.rst_n      (rst_n      ) ,//复位输入
    /*input      [7:0]    */.data_i     (data_o     ) ,//需要发送的数据
    /*input               */.data_vld   (data_o_vld ) ,//数据有效信号
    /*output reg          */.tx_o       (tx         ) ,//串口发送
    /*output reg          */.busy       (busy       )  //1：忙碌   0：空闲       
    );
    //led
    assign led = {busy,busy,busy,busy,busy,busy,busy,busy} ;//测试   

endmodule
