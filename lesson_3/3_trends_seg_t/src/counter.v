/************************************
***********易思达FPGA实验*************             
**软    件：GOwin云源软件              
**项    目：时钟产生模块                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  counter(
    input           clk_50m     ,//时钟
    input           rst_n       ,//复位
    input           key_vld     ,//暂停
    output  [15:0]  dis_data     //{千位，个位，十位，个位}
    );
//参数定义
parameter   CNT_100MS = 24'd5_000_000 ,//100ms 最大计数值
            CNT_1S    = 4'd10         ,//1s
            CNT_10S   = 4'd10         ,//10s
            CNT_100S  = 4'd10         ,//60秒
            CNT_1000S = 4'd10         ;//10分钟
//信号定义
reg           add_en      ;//计数器使能

reg   [23:0]  cnt1        ;//100ms计数器
wire          add_cnt1    ;
wire          end_cnt1    ;

reg   [3:0]   cnt2        ;//1s计数器
wire          add_cnt2    ;
wire          end_cnt2    ;

reg   [3:0]   cnt3        ;//10s计数器
wire          add_cnt3    ;
wire          end_cnt3    ;

reg   [3:0]   cnt4        ;//1min计数器
wire          add_cnt4    ;
wire          end_cnt4    ;

reg   [3:0]   cnt5        ;//10min计数器
wire          add_cnt5    ;
wire          end_cnt5    ;


    //add_en
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            add_en <= 1'b1 ;
        end
        else if(key_vld)begin
            add_en <= ~add_en;
        end
    end
    //计数器  100ms
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt1 <= 1'b0;
        end
        else if(add_cnt1)begin
            if (end_cnt1)begin
                cnt1 <= 1'b0;
            end
            else begin
                cnt1 <= cnt1 + 1'b1;
            end
        end
    end
    assign add_cnt1 = add_en ;
    assign end_cnt1 = add_cnt1 && (cnt1 == CNT_100MS - 1'b1);

    //计数器 1s
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt2 <= 1'b0;
        end
        else if(add_cnt2)begin
            if (end_cnt2)begin
                cnt2 <= 1'b0;
            end
            else begin
                cnt2 <= cnt2 + 1'b1;
            end
        end
    end
    assign add_cnt2 = end_cnt1 ;
    assign end_cnt2 = add_cnt2 && (cnt2 == CNT_1S - 1'b1);

    //计数器 10s
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt3 <= 1'b0;
        end
        else if(add_cnt3)begin
            if (end_cnt3)begin
                cnt3 <= 1'b0;
            end
            else begin
                cnt3 <= cnt3 + 1'b1;
            end
        end
    end
    assign add_cnt3 = end_cnt2 ;
    assign end_cnt3 = add_cnt3 && (cnt3 == CNT_10S - 1'b1);

    //计数器 100s
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt4 <= 1'b0;
        end
        else if(add_cnt4)begin
            if (end_cnt4)begin
                cnt4 <= 1'b0;
            end
            else begin
                cnt4 <= cnt4 + 1'b1;
            end
        end
    end
    assign add_cnt4 = end_cnt3 ;
    assign end_cnt4 = add_cnt4 && (cnt4 == CNT_100S - 1'b1);

    //计数器 1000s
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt5 <= 1'b0;
        end
        else if(add_cnt5)begin
            if (end_cnt5)begin
                cnt5 <= 1'b0;
            end
            else begin
                cnt5 <= cnt5 + 1'b1;
            end
        end
    end
    assign add_cnt5 = end_cnt4 ;
    assign end_cnt5 = add_cnt5 && (cnt5 == CNT_1000S - 1'b1);

    assign dis_data = {cnt5,cnt4,cnt3,cnt2} ;


endmodule

