/*****************************************************************
*****************************FPGA实验************************          
**软    件:GOwin云源软件                
**项    目:ADC-峰峰值检测                      
**时    钟:100MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/ 
module dac(
    input              clk_100m  ,//系统时钟
    input              rst_n    ,//系统复位，低电平有效
    //DA1接口
    output             da_clk   ,//DA驱动时钟  100m
    output      [9:0]  da_data   //输出给DA的数据    大概是200khz正玄波
);
//参数定义
parameter CNT_MAX = 10'd1012 ;

//信号定义
reg   [9:0]   cnt     ;
wire          add_cnt ;//计数器使能
wire          end_cnt ;//计数器结束

/***********************************************************************************************
/ 数据rd_data是在clk_100m的上升沿更新的，所以DA芯片在clk_100m的下降沿锁存数据是稳定的时刻                 
/ 而DA芯片实际上在da_clk的上升沿锁存数据,所以时钟取反,这样clk_100m的下降沿相当于da_clk的上升沿      
***********************************************************************************************/
    //da_clk
    assign  da_clk = ~clk_100m;      
    //cnt计数器
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 10'd12 ;
        end
        else if(add_cnt)begin
            if (end_cnt)begin
                cnt <= 10'd12 ;
            end
            else begin
                cnt <= cnt + 10'd2 ;
            end
        end
    end
    assign add_cnt = 1'b1 ;
    assign end_cnt = add_cnt && (cnt == CNT_MAX - 1'b1) ; //250个数
/*-------------------------------------------模块例化-----------------------------------*/
//正弦波  周期250*10=2500ns  2.5us  400khz
    sin_pROM sin_pROM(
        .dout  (da_data  ), //output [9:0] dout
        .clk   (clk_100m  ), //input clk
        .oce   (1'b1     ), //input oce
        .ce    (1'b1     ), //input ce
        .reset (1'b0     ), //input reset
        .ad    (cnt      ) //input [9:0] ad
    );
endmodule