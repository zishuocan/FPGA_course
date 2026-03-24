/*****************************************************************
***********FPGA实验*************         
**软    件:GOwin云源软件                
**项    目:显示码转换模块                      
**时    钟:50MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
module bcd_8421(
    input             clk_50m ,
    input             rst_n   ,
    input [19:0]      data_in ,//二进制显示数据

    output reg [3:0]  unit    ,//个位
    output reg [3:0]  ten     ,//十位
    output reg [3:0]  hun     ,//百位
    output reg [3:0]  tho     ,//千位
    output reg [3:0]  t_tho   ,//万位
    output reg [3:0]  h_tho    //十万位
);
//参数
    parameter  T_CNT = 22 ;//cnt为0时赋值，移位还需要20次，总共计数21次
//信号
    reg [5:0]       cnt         ;//移位计数器
    wire            add_cnt     ;
    wire            end_cnt     ;     

    reg             shift_flag  ;//移位标志
    reg [43:0]      shift_data  ;//20位的bcd码  +  24位的8421码

    //移位计数器
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 1'b0 ;
        end
        else if(add_cnt)begin
            if(end_cnt )begin
                cnt <= 1'b0 ;
            end
            else begin
                cnt <= cnt + 1'b1 ;
            end
        end
        else begin
            cnt <= cnt ;
        end
    end
    assign add_cnt = shift_flag ;
    assign end_cnt = add_cnt && cnt==T_CNT-1'b1 ;
    //shift_flag 2分频  25mhz
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            shift_flag <= 1'b0 ;
        end
        else begin
            shift_flag <= ~shift_flag ;
        end
    end
    //shift_data   bcd码转8421码 依靠分频时钟进行循环位移判断
    //输入的数据是多少位  就需要移位相应的次数   
    always@(posedge clk_50m or negedge rst_n )begin
        if(!rst_n)begin
            shift_data <= 44'b0 ;
        end
        else if(cnt == 5'b0 )begin
            shift_data <= {24'b0,data_in} ;//计数开始前拼接  6个数码管  补24个零
        end
        else if((shift_flag==1'b0) && (cnt<=20) )begin    //判断+3
            shift_data[23:20] <= (shift_data[23:20]>4)?(shift_data[23:20]+2'd3):(shift_data[23:20]) ;
            shift_data[27:24] <= (shift_data[27:24]>4)?(shift_data[27:24]+2'd3):(shift_data[27:24]) ;
            shift_data[31:28] <= (shift_data[31:28]>4)?(shift_data[31:28]+2'd3):(shift_data[31:28]) ;
            shift_data[35:32] <= (shift_data[35:32]>4)?(shift_data[35:32]+2'd3):(shift_data[35:32]) ;
            shift_data[39:36] <= (shift_data[39:36]>4)?(shift_data[39:36]+2'd3):(shift_data[39:36]) ;
            shift_data[43:40] <= (shift_data[43:40]>4)?(shift_data[43:40]+2'd3):(shift_data[43:40]) ;
        end
        else if((shift_flag==1'b1) && (cnt<=20))begin 
            shift_data <= shift_data << 1 ;
        end
        else begin
            shift_data <= shift_data ;
        end
    end

    //输出
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            unit  <= 4'b0 ;
            ten   <= 4'b0 ;
            hun   <= 4'b0 ;
            tho   <= 4'b0 ;
            t_tho <= 4'b0 ;
            h_tho <= 4'b0 ;
        end
        else if(end_cnt)begin
            unit  <= shift_data[23:20] ;
            ten   <= shift_data[27:24] ;
            hun   <= shift_data[31:28] ;
            tho   <= shift_data[35:32] ;
            t_tho <= shift_data[39:36] ;
            h_tho <= shift_data[43:40] ;
        end
    end

    //assign  data_out <={h_tho,t_tho,tho,hun,ten,unit} ;
endmodule 