/************************************
***********易思达FPGA实验*************
**日    期：2023.06.13               
**软    件：GOwin云源软件              
**项    目：按键电子琴                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  top(
    input              clk_50m ,//时钟输入
    input              rst_n   ,//复位输入
    input      [6:0]   key     ,
    output reg [7:0]   led     ,
    output             beep      
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s


//信号定义


    //led
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            led <= 8'b0;
        end
        else if(key!=7'b111_1111)begin
            led <= 8'b1111_1111 ;
        end
        else begin
            led <= 8'b0;
        end
    end

/*----------------------模块例化-------------------------------------*/
    //电子琴
    piano  u2(
        /*input              */.clk_50m  (clk_50m  ),//时钟输入
        /*input              */.rst_n    (rst_n    ),//复位输入
        /*input       [6:0]  */.key_data (key      ),//按键有效值
        /*output reg         */.beep     (beep     )//蜂鸣器输出
    );

endmodule

