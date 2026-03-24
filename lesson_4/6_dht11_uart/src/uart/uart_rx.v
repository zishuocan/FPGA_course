/************************************
***********FPGA实验*************              
**软    件：GOwin云源软件              
**项    目：xxxx                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  uart_rx(
    input             clk_50m ,//时钟输入
    input             rst_n   ,//复位输入
    input             rx_i    ,//uart  接收
    output reg [7:0]  rx_o    ,//uart  输出
    output reg        rx_o_vld //输出有效标志
    );
//参数定义
parameter   CNT_50M = 'd50_000_000 ;//50mhz
parameter   CNT_BPS1 = CNT_50M/115200 ,
            CNT_BPS4 = 20             ,//测试
            CNT_BPS2 = CNT_50M/48000  , 
            CNT_BPS3 = CNT_50M/9600   ;

//信号定义
reg   [1:0]   rx_i_r  ;//同步打拍
wire          nege    ;
reg           rx_flag ;//接收标志  高电平
reg   [10:0]  data_r  ;//带校验位的一帧数据寄存器

reg   [24:0]  cnt_bps     ;//波特率计数器
wire          add_cnt_bps ;//计数器使能
wire          end_cnt_bps ;//计数器结束

reg   [3:0]   cnt_bit     ;//bit计数器
wire          add_cnt_bit ;//计数器使能
wire          end_cnt_bit ;//计数器结束

    //rx_i_r
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            rx_i_r <= 2'b11 ;
        end
        else begin
            rx_i_r <= {rx_i_r[0],rx_i };
        end
    end
    //nege
    assign nege = ~rx_i_r[0]&rx_i_r[1] ;
    //rx_flag
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            rx_flag <= 1'b0 ;
        end
        else if(end_cnt_bit)begin
            rx_flag <= 1'b0 ;
        end
        else if(nege)begin
            rx_flag <= 1'b1 ;
        end
    end
    //data_r
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            data_r <= 11'b0;
        end
        else if(cnt_bps == (CNT_BPS3>>1) - 1'b1)begin
            data_r[cnt_bit] <= rx_i_r[0] ;
        end
    end
    //cnt_bps   计数器
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt_bps <= 1'b0 ;
        end
        else if(add_cnt_bps)begin
            if (end_cnt_bps)begin
                cnt_bps <= 1'b0 ;
            end
            else begin
                cnt_bps <= cnt_bps + 1'b1 ;
            end
        end
    end
    assign add_cnt_bps = rx_flag ;
    assign end_cnt_bps = add_cnt_bps && (cnt_bps == CNT_BPS3 - 1'b1) ;//接收过程中确保第一个bit是低电平
    //cnt_bit   计数器
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt_bit <= 1'b0 ;
        end
        else if(add_cnt_bit)begin
            if (end_cnt_bit)begin
                cnt_bit <= 1'b0 ;
            end
            else begin
                cnt_bit <= cnt_bit + 1'b1 ;
            end
        end
    end
    assign add_cnt_bit = end_cnt_bps ;
    assign end_cnt_bit = add_cnt_bit && ((cnt_bit == 11 - 1'b1) || data_r[0]);//接收过程中确保第一个bit是低电平
    //rx_o
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            rx_o <= 8'b0 ;
        end
        else if(cnt_bit == 10 && (^data_r[8:1] == data_r[9]))begin    //偶校验
            rx_o <= data_r[8:1] ;
        end
    end
    //rx_o_vld
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            rx_o_vld <= 1'b0 ;
        end
        else if(end_cnt_bit)begin
            rx_o_vld <= 1'b1 ;
        end
        else begin
            rx_o_vld <= 1'b0 ;
        end
    end


endmodule

