/*****************************************************************
***********FPGA实验*************         
**软    件:GOwin云源软件                
**项    目:数码管显示模块                      
**时    钟:50MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
module seg_display(
    input                clk_50m ,
    input                rst_n   ,

    input        [13:0]  data    ,//二进制显示值
    input        [3:0]   point   ,//小数点
    input                sign    ,//高电平使能为负数
    input                seg_en  ,//数码管使能

    output  wire [3:0]   sel     ,//位选
    output  wire [7:0]   seg      //段选
);
//参数
    parameter T_DLY = 30_000 ;//1ms 
    localparam  zero  = 7'b1000000,
                one   = 7'b1111001,
                two   = 7'b0100100,
                three = 7'b0110000,
                four  = 7'b0011001,
                five  = 7'b0010010,
                six   = 7'b0000010,
                seven = 7'b1111000,
                eight = 7'b0000000,
                nine  = 7'b0010000,
                sign_m= 7'b0111111;//减号
//信号
    reg         add_flag;
    reg [15:0]  cnt     ;//1ms
    wire        add_cnt ;
    wire        end_cnt ;

    reg  [15:0] data_r  ;//拼接
    reg  [3:0]  data_seg;
    reg  [2:0]  cnt_sel ;
    reg  [3:0]  sel_r   ;//数码管位选
    reg  [7:0]  seg_r   ;//数码管段选

    wire  [3:0]   unit  ;
    wire  [3:0]   ten   ;
    wire  [3:0]   hun   ;
    wire  [3:0]   tho   ;
//例化bcd_8421模块
    bcd_8421 bcd_8421_inst(
    /*input               */.clk_50m (clk_50m    ) ,
    /*input               */.rst_n   (rst_n      ) ,
    /*input [19:0]        */.data_in (data       ) ,
    /*output reg [3:0]    */.unit    (unit       ) ,//个位
    /*output reg [3:0]    */.ten     (ten        ) ,//十位
    /*output reg [3:0]    */.hun     (hun        ) ,//百位
    /*output reg [3:0]    */.tho     (tho        ) ,//千位
    /*output reg [3:0]    */.t_tho   (           ) ,//万位
    /*output reg [3:0]    */.h_tho   (           )  //十万位
    );


    //data_r
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            data_r <= 16'b0;
        end
        else if((tho   || point[3]) && (!sign))begin  //说明有四位需要显示
            data_r <= {tho,hun,ten,unit} ;//{百万。。个位}
        end
        else if((tho   || point[3]) && (sign))begin  //有符号
            data_r <= {4'd10,hun,ten,unit} ; 
        end
        else if((hun   || point[2]) && (!sign))begin  //说明有三位需要显示
            data_r <= {4'b0,hun,ten,unit} ;//{百万。。个位}
        end
        else if((hun   || point[2]) && (sign))begin  //有符号
            data_r <= {4'd10,hun,ten,unit} ; 
        end
        else if((ten   || point[1]) && (!sign))begin  //说明有二位需要显示
            data_r <= {16'b0,ten,unit} ;//{百万。。个位}
        end
        else if((ten   || point[1]) && (sign))begin  //有符号
            data_r <= {4'd10,4'b0,ten,unit} ; 
        end
        else if((unit  || point[0]) && (!sign))begin  //说明有一位需要显示
            data_r <= {12'b0,unit} ;//{百万。。个位}
        end
        else if((unit  || point[0]) && (sign))begin  //有符号
            data_r <= {4'd10,8'b0,unit} ; 
        end
    end 
    //add_flag
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            add_flag <= 1'b0 ;
        end
        else begin
            add_flag <= seg_en ;
        end
    end
    //显示延时计数器
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 16'b0 ;
        end
        else if(add_cnt)begin
            if(end_cnt)begin
                cnt <= 16'b0 ;
            end
            else begin
                cnt <= cnt + 1'b1 ;
            end
        end
    end
    assign add_cnt = add_flag ;
    assign end_cnt = add_cnt && cnt==(T_DLY-1'b1) ;//1ms结束
    //cnt_sel
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt_sel <= 2'd0 ;
        end
        else if((cnt_sel == 3'd3) && end_cnt)begin
            cnt_sel <= 2'd0 ; 
        end
        else if(end_cnt )begin
            cnt_sel <= cnt_sel + 1'b1 ;
        end
        else begin
            cnt_sel <= cnt_sel ;
        end
    end
    //sel_r
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            sel_r <= 4'b0_000 ;
        end
        else if((cnt_sel == 3'b0) && end_cnt )begin  //复位
            sel_r <= 4'b0_001 ;
        end
        else if(end_cnt)begin
            sel_r <= sel_r << 1 ; //显示的数码管移位，循环显示
        end
        else begin
            sel_r <= sel_r ;
        end
    end
    //data_seg
    always@(posedge clk_50m or negedge rst_n )begin
        if(!rst_n)begin
            data_seg <= 4'b0000 ; 
        end
        else if(end_cnt && seg_en )begin
            case(cnt_sel)
                3'd0:begin data_seg <= data_r[3:0  ] ;end
                3'd1:begin data_seg <= data_r[7:4  ] ;end
                3'd2:begin data_seg <= data_r[11:8 ] ;end
                3'd3:begin data_seg <= data_r[15:12] ;end
                default:begin data_seg <= 4'b0000    ;end 
            endcase
        end
    end
    //小数点
    always@(posedge clk_50m or negedge rst_n )begin
        if(!rst_n)begin
            seg_r[7] <= 1'b1 ; 
        end
        else if(end_cnt && seg_en )begin
            case(cnt_sel)
                3'd0:begin seg_r[7] <= point[cnt_sel];end
                3'd1:begin seg_r[7] <= point[cnt_sel];end
                3'd2:begin seg_r[7] <= point[cnt_sel];end
                3'd3:begin seg_r[7] <= point[cnt_sel];end
                default:begin seg_r[7] <= 1'b1 ;end 
            endcase
        end
    end
    //显示码转换
    always@(*)begin
        case(data_seg)
            4'd0 :begin seg_r[6:0] <= zero  ;end
            4'd1 :begin seg_r[6:0] <= one   ;end
            4'd2 :begin seg_r[6:0] <= two   ;end
            4'd3 :begin seg_r[6:0] <= three ;end
            4'd4 :begin seg_r[6:0] <= four  ;end
            4'd5 :begin seg_r[6:0] <= five  ;end
            4'd6 :begin seg_r[6:0] <= six   ;end
            4'd7 :begin seg_r[6:0] <= seven ;end
            4'd8 :begin seg_r[6:0] <= eight ;end
            4'd9 :begin seg_r[6:0] <= nine  ;end
            4'd10:begin seg_r[6:0] <= sign_m ;end
            default:begin seg_r[6:0] = 7'b111_1111 ;end
        endcase
    end
    //sel  seg
    assign sel = sel_r ;
    assign seg = seg_r ;
endmodule 