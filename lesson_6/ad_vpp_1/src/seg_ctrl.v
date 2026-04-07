/*****************************************************************
*****************************FPGA实验************************           
**软    件:GOwin云源软件                
**项    目:数码管显示控制                      
**时    钟:100mHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
module  seg_ctrl(
    input                clk_100m   ,//时钟输入
    input                rst_n     ,//复位输入
    input       [15:0]   data_in   ,//显示数据
    input       [3:0]    point     ,//小数点
    output reg  [3:0]    sel       ,//数码管位选
    output reg  [7:0]    seg        //数码管段选
    );
//参数定义
parameter   CNT_MAX = 16'd50_000 ;//1ms  
localparam  zero  = 7'b1000000 ,//0
            one   = 7'b1111001 ,//1
            two   = 7'b0100100 ,//2
            three = 7'b0110000 ,//3
            four  = 7'b0011001 ,//4
            five  = 7'b0010010 ,//5
            six   = 7'b0000010 ,//6
            seven = 7'b1111000 ,//7
            eight = 7'b0000000 ,//8
            nine  = 7'b0010000 ,//9
            sign_m= 7'b0111111 ;//减号
//信号定义
reg   [15:0]  cnt1          ;
wire          add_cnt1      ;//计数器使能
wire          end_cnt1      ;//计数器结束

reg   [1:0]   cnt2          ;
wire          add_cnt2      ;//计数器使能
wire          end_cnt2      ;//计数器结束

reg   [3:0]   seg_r = 11    ;
reg           dian          ;
    //计数器  1ms
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
    assign end_cnt1 = add_cnt1 && (cnt1 == CNT_MAX - 1'b1) ;
    //计数器  0~3
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            cnt2 <= 1'b0 ;
        end
        else if (end_cnt1)begin
            cnt2 <= cnt2 + 1'b1 ;
        end
    end
    //sel
    always@(*)begin
        case(cnt2)
            2'd0: sel <= 4'b1110 ;
            2'd1: sel <= 4'b1101 ;
            2'd2: sel <= 4'b1011 ;
            2'd3: sel <= 4'b0111 ;
            default:sel = 4'b1111 ;
        endcase
    end
    //seg_r  dian
    always@(*)begin
        case(cnt2)
            2'd0:begin seg_r = data_in[3:0]   ;dian <= point[cnt2] ;end
            2'd1:begin seg_r = data_in[7:4]   ;dian <= point[cnt2] ;end
            2'd2:begin seg_r = data_in[11:8]  ;dian <= point[cnt2] ;end
            2'd3:begin seg_r = data_in[15:12] ;dian <= point[cnt2] ;end
            default:begin seg_r = 4'b1011   ;dian <= 1'b1 ;end
        endcase
    end
    //seg 
    always@(*)begin
        case(seg_r)
            4'd0: seg = {dian,zero  } ;
            4'd1: seg = {dian,one   } ;
            4'd2: seg = {dian,two   } ;
            4'd3: seg = {dian,three } ;
            4'd4: seg = {dian,four  } ;
            4'd5: seg = {dian,five  } ;
            4'd6: seg = {dian,six   } ;
            4'd7: seg = {dian,seven } ;
            4'd8: seg = {dian,eight } ;
            4'd9: seg = {dian,nine  } ;
            4'd10:seg = {dian,sign_m} ;
            4'd11:seg = 8'hff ;
        default:seg = 8'hff ;
        endcase
    end
endmodule

