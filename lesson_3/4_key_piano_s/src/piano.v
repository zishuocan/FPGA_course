/************************************
***********易思达FPGA实验*************
**日    期：2023.06.13               
**软    件：GOwin云源软件              
**项    目：电子琴模块                     
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  piano(
    input              clk_50m  ,//时钟输入
    input              rst_n    ,//复位输入
    input       [6:0]  key_data ,//按键有效值
    output reg         beep     //蜂鸣器输出
    );
//参数定义
// parameter   CNT_MAX = 25'd25_000_000 ;//0.5s
localparam      DO = 18'd190839 ,//"哆"音调分频计数值（频率262）190839
                RE = 18'd170067 ,//"来"音调分频计数值（频率294）170067
                MI = 18'd151514 ,//"咪"音调分频计数值（频率330）151514
                FA = 18'd143265 ,//"发"音调分频计数值（频率349）143265
                SO = 18'd127550 ,//"梭"音调分频计数值（频率392）127550
                LA = 18'd113635 ,//"拉"音调分频计数值（频率440）113635
                XI = 18'd101214 ;//"西"音调分频计数值（频率494）101214
//参数定义
reg   [24:0]  cnt     ;
wire          add_cnt ;//计数器使能
wire          end_cnt ;//计数器结束
reg   [24:0]  CNT_MAX ;

    //CNT_MAX
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            CNT_MAX = 18'b0 ;
        end
        else if(!key_data[0])begin
            CNT_MAX <= DO ;
        end
        else if(!key_data[1])begin
            CNT_MAX <= RE ;
        end
        else if(!key_data[2])begin
            CNT_MAX <= MI ;
        end
        else if(!key_data[3])begin
            CNT_MAX <= FA ;
        end
        else if(!key_data[4])begin
            CNT_MAX <= SO ;
        end
        else if(!key_data[5])begin
            CNT_MAX <= LA ;
        end
        else if(!key_data[6])begin
            CNT_MAX <= XI ;
        end
        else begin
            CNT_MAX = 18'b0 ;
        end  
    end
    //计数器
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
    assign add_cnt = key_data!=7'b111_1111 ;
    assign end_cnt = add_cnt && (cnt == (CNT_MAX>>1) - 1'b1) ;
    //beep
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            beep <= 1'b0 ;
        end
        else if(end_cnt )begin
            beep <= ~beep ;
        end
    end


endmodule

