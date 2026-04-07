/*****************************************************************
*****************************FPGA实验************************            
**软    件:GOwin云源软件                
**项    目:adc检测波形峰峰值电压数码管显示实验                   
**时    钟:100MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
module  top(
    input          clk_100m     ,//时钟输入
    input          rst_n       ,//复位输入
    //ad1
    input  [9:0]   ad1_data     ,//da数据
    input          ad1_ort      ,//超量程标志
    output         oe1_n        ,//ad 使能
    output         ad1_clk      ,//da时钟
    //da1
    output         da1_clk      ,//ad1时钟
    output [9:0]   da1_data     ,//ad数据
    //显示发送
    output [7:0]   led          ,
    output [3:0]   sel          ,
    output [7:0]   seg          
);


//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s

//信号定义
wire [15:0] dis_data_vpp  ;
reg  [15:0] dis_data_vpp1 ;
reg         clk_50m       ;
wire        uart_en ;
wire        da_clk  ; 
wire   [9:0]    da_data ; 
/*--------------------------------------------------------*/
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            clk_50m <= 1'b0;
        end
        else begin
            clk_50m <= ~clk_50m ;
        end
    end
//assign dis_data_vpp1 = dis_data_vpp ;
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            dis_data_vpp1 <= 1'b0;
        end
        else if(uart_en)begin
            dis_data_vpp1 <= dis_data_vpp;
        end
    end

/*--------------------------------------------模块例化------------------------------------------------*/
    //产生波形
    dac u_dac(
        /*input              */.clk_100m      (clk_100m       ),//系统时钟
        /*input              */.rst_n        (rst_n         ),//系统复位，低电平有效
        //DA1接口
        /*output             */.da_clk       (da1_clk       ),//DA驱动时钟  100m
        /*output      [9:0]  */.da_data      (da1_data      ) //输出给DA的数据    大概是200khz正弦波
    );
    //检测波形
    adc  u_adc(
        /*input              */.clk_100m      (clk_100m       ),//时钟输入
        /*input              */.rst_n        (rst_n         ),//复位输入
        /*input      [9:0]   */.ad_data      (ad1_data      ),//ad数字信号输入
        /*input              */.ad_ort       (ad1_ort       ),//超量程标志
        /*output             */.ad_clk       (ad1_clk       ),//ad驱动时钟
        /*output             */.oe1_n        (oe1_n         ),  
        /*output             */.uart_en      (uart_en       ),
        /*output reg [15:0]  */.dis_data_vpp (dis_data_vpp  ) //峰峰值电压值   数码管显示   uart发送
    );
    //数码管显示
    seg_ctrl  u_seg_ctrl(
        /*input                */.clk_100m (clk_100m )  ,//时钟输入
        /*input                */.rst_n   (rst_n   )  ,//复位输入
        /*input       [15:0]   */.data_in (dis_data_vpp1)  ,//显示数据        16'h1234
        /*input       [3:0]    */.point   (4'b1011 )  ,//小数点
        /*output reg  [3:0]    */.sel     (sel     )  ,//数码管位选
        /*output reg  [7:0]    */.seg     (seg     )   //数码管段选
    );

    assign led = {ad1_ort,ad1_ort,ad1_ort,ad1_ort,ad1_ort,ad1_ort,ad1_ort,ad1_ort};


endmodule

