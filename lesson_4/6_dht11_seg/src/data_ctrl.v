
module  data_ctrl(
    input              clk_50m  ,//时钟输入
    input              rst_n    ,//复位输入
    input              key_i    ,//按键
    input      [31:0]  dht_data ,//{8bit 湿度整数数据+8bit 湿度小数数据+8bit 温度整数数据+8bit 温度小数数据}
    output reg [15:0]  dis_data ,//显示数据
    output     [3:0]   point    ,//小数点
    output     [7:0]   led       //全亮表示温度  全灭表示湿度
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s

//信号定义
reg           flag       ;//1：显示温度   0：显示湿度
reg   [7:0]   dis_data_h ;//暂存显示的数据  温度或者湿度  高八位  整数部分
reg   [7:0]   dis_data_l ;//暂存显示的数据  温度或者湿度  低八位  小数部分

reg   [24:0]  cnt        ;//0.5s
wire          add_cnt    ;//计数器使能
wire          end_cnt    ;//计数器结束

wire [3:0]    unit       ;//个位显示码
wire [3:0]    ten        ;//十位显示码
wire [3:0]    hun        ;//百位显示码
wire [3:0]    tho        ;//千位显示码


    //flag
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            flag <= 1'b0;
        end
        else if(key_i)begin
            flag <= ~flag;
        end
    end
    //dis_data_h
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            dis_data_h <= 16'b0;
        end
        else if(end_cnt)begin
            if(!flag )begin
                dis_data_h <= dht_data[15:8]-5;// 温度        
            end
            else begin
                dis_data_h <= dht_data[31:24];//湿度
            end
        end
        else begin
            dis_data_h <= dis_data_h ;
        end
    end
    
    //cnt计数器  0.5s
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
    assign add_cnt = 1'b1 ;
    assign end_cnt = add_cnt && (cnt == CNT_MAX - 1'b1) ;
/**************************************************************************************
***************************************************************************************/
    //给数码管值
    assign unit = dis_data_h % 4'd10            ;//个位显示码          
    assign ten  = dis_data_h / 4'd10 % 4'd10    ;//十位显示码
    assign hun  = dis_data_h / 7'd100 % 4'd10   ;//百位显示码
    assign tho  = dis_data_h / 10'd1000 % 4'd10 ;//千位显示码
    //dis_data
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            dis_data <= 16'b0;
        end
        else if(flag && dht_data[7])begin   //有符号
            if(hun>0)begin
                dis_data <= {4'd10,hun,ten,unit};
            end
            else begin
                dis_data <= {4'd10,4'd11,ten,unit};
            end
        end
        else begin
            if(tho>0)begin
                dis_data <= {tho,hun,ten,unit};
            end
            else begin
                if(hun>0)begin
                    dis_data <= {4'd11,hun,ten,unit};
                end
                else begin
                    dis_data <= {4'd11,4'd11,ten,unit};
                end
            end
        end
    end
    //point
    assign point = 4'b1111;
    //led
    assign led = (flag==1'b0)?8'h0:8'hff;
endmodule

