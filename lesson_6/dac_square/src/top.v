/*****************************************************************
*****************************FPGA实验************************             
**软    件:GOwin云源软件                
**项    目:DAC-方波                      
**时    钟:100MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/ 
module  top(
    input        clk_50m     ,//时钟输入
    input        rst_n       ,//复位输入
    output       da_clk_100m ,
    output [9:0] da_data     
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s


//信号定义
wire [9:0]   rd_addr ;
wire [9:0]   rd_data ;


//模块例化
    Gowin_rPLL u_Gowin_rPLL(
        .clkout(clk_100m), //output clkout
        .clkin (clk_50m) //input clkin
    );

    Gowin_pROM u_Gowin_pROM(
        .dout  (rd_data    ), //output [9:0] dout
        .clk   (clk_100m   ), //input clk
        .oce   (1'b1       ), //input oce
        .ce    (1'b1       ), //input ce
        .reset (1'b0       ), //input reset
        .ad    (rd_addr    ) //input [9:0] ad
    );


    dac_square u_dac_square(
    /*input                 */.clk_100m      (clk_100m      )  ,  //系统时钟
    /*input                 */.rst_n         (rst_n         )  ,  //系统复位，低电平有效

    /*input        [9:0]    */.rd_data       (rd_data       )  ,  //ROM读出的数据
    /*output  reg  [9:0]    */.rd_addr       (rd_addr       )  ,  //读ROM地址
//DA接口
    /*output                */.da_clk_100m   (da_clk_100m   )  ,  //DA驱动时钟
    /*output       [9:0]    */.da_data       (da_data       )     //输出给DA的数据  
    );

    
endmodule

