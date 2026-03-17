/************************************
***********易思达FPGA实验*************
**日    期：2023.07.20               
**软    件：GOwin云源软件              
**项    目：按键消抖模块                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module key_filter(
    input        clk_50m     ,
    input        rst_n       ,
    input        key         ,//按键输入
    output reg   key_vld     ,//按键有效标志
    output reg   key_data     //按键值输出
);
//参数定义
parameter CNT_MAX = 100_0000 ;//20ms延时计数器最大值

//信号定义
reg   [1:0]   key_r     ;//同步打拍
wire          nege      ;//下降沿
wire          pose      ;//上升沿

reg   [24:0]  cnt       ;
reg           add_cnt   ;//计数器使能
wire          end_cnt   ;//计数器结束

    //key_r
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            key_r <= 2'b11 ;
        end
        else begin
            key_r <= {key_r[0],key};
        end
    end
    //nege
    assign nege = (!key_r[0])&key_r[1] ;
    //pose
    assign pose = (!key_r[1])&key_r[0] ;
    //add_cnt
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            add_cnt <= 1'b0;
        end
        else if(end_cnt)begin
            add_cnt <= 1'b0;
        end
        else if(nege)begin
            add_cnt <= 1'b1;
        end
    end
    //cnt 计数器
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 1'b0 ;
        end
        else if(add_cnt)begin
            if (end_cnt)begin
                cnt <= 1'b0 ;
            end
            else begin
                cnt <= cnt + 1'b1 ;
            end
        end
    end
    assign end_cnt = (cnt == CNT_MAX - 1'b1) ;
    //key_vld
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            key_vld <= 1'b0 ;
        end
        else if(end_cnt&(!key_r[0]))begin
            key_vld <= 1'b1;
        end
        else if(end_cnt&(key_r[0]))begin
            key_vld <= 1'b0;
        end
        else if(pose)begin
            key_vld <= 1'b0;
        end
    end
    //key_data
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            key_data <= 1'b0 ;
        end
        else if(end_cnt&(!key_r[0]))begin
            key_data <= 1'b1 ;
        end
        else begin
            key_data <= 1'b0 ;
        end
    end

endmodule
