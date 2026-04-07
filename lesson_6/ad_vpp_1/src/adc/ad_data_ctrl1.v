/*****************************************************************
*****************************FPGA实验************************               
**软    件:GOwin云源软件                
**项    目:ad数据处理，检测峰峰值，检测频率                      
**时    钟:100MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
module  ad_data_ctrl1(
    input               clk_100m   ,//时钟输入
    input               rst_n     ,//复位输入
    input       [9:0]   data_in   ,//ad采集数据
    output reg  [31:0]  data_vpp   //峰峰值电压值（已转化，实际电压值）   80us更新一次   
);
//参数定义
parameter   CNT_MAX = 30'd100_000_000 ;//1s
parameter   CNT1_MAX = 26'd1_000_000 ;//0.01s
//信号定义   
reg   [29:0]  cnt                ;
wire          add_cnt            ;//计数器使能
wire          end_cnt            ;//计数器结束
reg   [25:0]  cnt1               ;
wire          add_cnt1           ;//计数器使能
wire          end_cnt1           ;//计数器结束
//cnt_byte
reg  [25:0]   cnt_byte           ;
wire          add_cnt_byte       ;
wire          end_cnt_byte       ;
reg   [9:0]   data_in_r1         ;//打拍
reg   [9:0]   data_in_r2         ;//打拍
reg   [9:0]   data_max = 10'd512 ;//锁存最大值
reg   [9:0]   data_min = 10'd511 ;//锁存最小值
reg   [31:0]  data_vpp_r         ;//差值

    assign data_freq = 1'b0;

    //cnt 计数器
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
    //cnt1 计数器
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            cnt1 <= 1'b0 ;
        end
        else if(add_cnt1)begin
            if (end_cnt1)begin
                cnt1 <= 1'b0 ;
            end
            else begin
                cnt1 <= cnt1 + 1'b1 ;
            end
        end
    end
    assign add_cnt1 = 1'b1 ;
    assign end_cnt1 = add_cnt1 && (cnt1 == CNT1_MAX - 1'b1) ;
    //byte_cnt   byte计数器
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            cnt_byte <= 0;
        end
        else if(add_cnt_byte)begin
            if(end_cnt_byte)begin
                cnt_byte <= 0;
            end
            else begin
                cnt_byte <= cnt_byte + 1'b1;
            end
        end
    end
    assign add_cnt_byte = end_cnt1;
    assign end_cnt_byte = add_cnt_byte && (cnt_byte == 10 - 1);
    //data_in_r1 data_in_r2
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            data_in_r1 <= 1'b0;
            data_in_r2 <= 1'b0;
        end
        else begin
            // data_in_r1 <= (data_in/10)*10;//去掉个位
            data_in_r1 <= data_in;//不去个位
            data_in_r2 <= data_in_r1;
        end
    end
    //data_max  
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            data_max <= 10'd512;
        end
        else if(end_cnt1)begin
            data_max <= 10'd512;
        end
        else if(data_in_r1>=data_max)begin
            data_max <= data_in_r2;
        end
    end
    //data_min
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            data_min <= 10'd511;
        end
        else if(end_cnt1)begin
            data_min <= 10'd511;
        end
        else if(data_in_r1<=data_min)begin
            data_min <= data_in_r2;
        end
    end
    //data_vpp
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            data_vpp <= 1'b0;
        end
        else if(data_vpp_r<50)begin
            data_vpp <= 1'b0;
        end
        else begin
            data_vpp <= data_vpp_r ;      //90为校准值
        end
    end
    //data_vpp_r
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            data_vpp_r <= 1'b0;
        end
        else begin
            data_vpp_r <= ((data_max-data_min)*'d94)/'d100;//数值转换
        end
    end

endmodule