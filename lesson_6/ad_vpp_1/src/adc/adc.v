/*****************************************************************
*****************************FPGA实验************************              
**软    件:GOwin云源软件                
**项    目:adc接口控制模块                      
**时    钟:100MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
module  adc(
    input              clk_100m      ,//时钟输入
    input              rst_n        ,//复位输入
    input      [9:0]   ad_data      ,//ad数字信号输入
    input              ad_ort       ,//超量程标志
    output             ad_clk       ,//ad驱动时钟
    output             oe1_n        ,//ad使能
    output             uart_en      ,//串口发送使能
    output reg [15:0]  dis_data_vpp  //峰峰值电压值   数码管显示   uart发送
);
//参数定义
parameter   CNT_MAX = 26'd50_000_000 ;//1s

//信号定义
reg   [25:0]   cnt      ;
wire           add_cnt  ;//计数器使能
wire           end_cnt  ;//计数器结束
wire  [31:0]   data_vpp ;//峰峰值
reg   [1:0]    cnt1     ;

reg   [9:0]    ad_data_r;
reg            ad_clk_r   ;


/*-----------------------------------------调试-----------------------------------------*/
    //ad_clk 分频  25兆
    //assign ad_clk = cnt1[0] ;
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            cnt1 <= 1'b0;
        end
        else begin
            cnt1 <= cnt1 + 1'b1;
        end
    end
/*------------------------------------------------------------------------------------------*/
    //ad驱动时钟   50MHz
    assign ad_clk = ad_clk_r ;//50MHz
    //25mhz
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            ad_clk_r <= 1'b0;
        end
        else begin
            ad_clk_r <= ~ad_clk_r;
        end
    end
    //ad_data_r  打拍，将采到的信号同步到工程时钟下
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            ad_data_r <= 10'b0;
        end
        else begin
            if(cnt1==0)begin
                ad_data_r <= ad_data;
            end
        end
    end
    assign uart_en = end_cnt;  
/*---------------------------------------------------------------------------------------------------------*/
    //oe1_n
    assign oe1_n = 1'b0;
    //cnt计数器
    always@(posedge clk_100m or negedge rst_n)begin
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
    assign add_cnt = 1'b1 ;
    assign end_cnt = add_cnt && (cnt == CNT_MAX - 1'b1) ;
    //dis_data_vpp
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            dis_data_vpp <= 1'b0;
        end
        else if(end_cnt)begin
            dis_data_vpp[3:0]   <= (data_vpp)%10    ;//个位  //20为偏移校正值
            dis_data_vpp[7:4]   <= (data_vpp)/10%10 ;//十位  //20为偏移校正值
            dis_data_vpp[11:8]  <= (data_vpp)/100%10;//百位  //20为偏移校正值
            dis_data_vpp[15:12] <= (data_vpp)/1000  ;//
        end
    end


/*-------------------------------------------调用数据处理模块------------------------------------------*/
    ad_data_ctrl1  u_ad_data_ctrl1(
        /*input               */.clk_100m   (clk_100m   ),//时钟输入
        /*input               */.rst_n     (rst_n     ),//复位输入
        /*input       [9:0]   */.data_in   (ad_data_r ),//ad采集数据
        /*output reg  [31:0]  */.data_vpp  (data_vpp  )//峰峰值电压值（已转化，实际电压值）   8us更新一次
    );

endmodule

