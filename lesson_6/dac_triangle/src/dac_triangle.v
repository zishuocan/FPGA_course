/*****************************************************************
*****************************FPGA实验************************             
**软    件:GOwin云源软件                
**项    目:DAC-三角波                      
**时    钟:100MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/ 

module dac_triangle(
    input                 clk_100m     ,  //系统时钟
    input                 rst_n        ,  //系统复位，低电平有效
    input        [9:0]    rd_data      ,  //ROM读出的数据
    output  reg  [9:0]    rd_addr      ,  //读ROM地址
    //DA接口
    output                da_clk_100m  ,  //DA驱动时钟
    output       [9:0]    da_data         //输出给DA的数据  
    );

//参数定义
//频率调节控制
parameter  FREQ_ADJ = 10'd0;  //频率调节,FREQ_ADJ的越大,最终输出的频率越低,范围0~255

//信号定义
reg    [9:0]    freq_cnt  ;  //频率调节计数器

/***********************************************************************************************/
//数据rd_data是在clk_100m的上升沿更新的，所以DA芯片在clk_100m的下降沿锁存数据是稳定的时刻                 /
//而DA实际上在da_clk_100m的上升沿锁存数据,所以时钟取反,这样clk_100m的下降沿相当于da_clk_100m的上升沿       /
/***********************************************************************************************/
    assign  da_clk_100m = ~clk_100m;
    assign  da_data = rd_data;    //将读到的ROM数据赋值给DA数据端口

    //频率调节计数器
    always @(posedge clk_100m or negedge rst_n) begin
        if(rst_n == 1'b0)
            freq_cnt <= 10'd0;
        else if(freq_cnt == FREQ_ADJ)       //10ns      MAX :f=97KHz
            freq_cnt <= 10'd0;
        else
            freq_cnt <= freq_cnt + 10'd1;
    end

    //读ROM地址
    always @(posedge clk_100m or negedge rst_n) begin
        if(rst_n == 1'b0)
            rd_addr <= 10'd0;
        else begin
            if(freq_cnt == FREQ_ADJ) begin
                rd_addr <= rd_addr + 10'd1;
            end
        end
    end




endmodule