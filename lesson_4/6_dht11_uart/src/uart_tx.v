 
module  uart_tx(
    input             clk_50m  ,//时钟输入
    input             rst_n    ,//复位输入
    input      [7:0]  data_i   ,//需要发送的数据
    input             data_vld ,//数据有效信号  使能
    output reg        tx_o     ,//串口发送
    output reg        busy      //1：忙碌   0：空闲       
    );
//参数定义
parameter   CNT_50M = 'd50_000_000 ;//50mhz
parameter   CNT_BPS1 = CNT_50M/115200 ,
            CNT_BPS2 = CNT_50M/57600  , 
            CNT_BPS3 = CNT_50M/9600   ,
            CNT_BPS4 = 20             ;//测试
//信号定义
reg   [24:0]  cnt_bps     ;//波特率计数器
wire          add_cnt_bps ;//计数器使能
wire          end_cnt_bps ;//计数器结束

reg   [3:0]   cnt_bit     ;//bit计数器
wire          add_cnt_bit ;//计数器使能
wire          end_cnt_bit ;//计数器结束
reg   [10:0]  data_r      ;//组装一帧数据

    //data_r
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            data_r <= 11'b111_1111_1111 ;
        end
        else if(data_vld)begin
            data_r <= {1'b1,(^data_i),data_i,1'b0} ;//{结束位，偶校验位，数据位8bit，起始位}
        end
    end
    //busy
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            busy <= 1'b0 ;
        end
        else if(data_vld)begin
            busy <= 1'b1 ;
        end
        else if(end_cnt_bit)begin
            busy <= 1'b0 ;
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
    assign add_cnt_bps = busy ;
    assign end_cnt_bps = add_cnt_bps && (cnt_bps == CNT_BPS2 - 1'b1) ;
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
    assign end_cnt_bit = add_cnt_bit && ((cnt_bit == 11 - 1'b1) || data_r[0]);//发送过程中确保第一个bit是低电平
    //tx_o
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            tx_o <= 1'b1 ;
        end
        else if(busy)begin
            tx_o <= data_r[cnt_bit] ;
        end
        else begin
            tx_o <= 1'b1 ;
        end
    end
    
endmodule

