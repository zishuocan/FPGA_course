 
module key7_filter(
    input       		clk_50m ,
    input       		rst_n   ,
    input      [6:0]    key     ,
    output reg   	    key_vld ,//按键按下标志
    output reg [6:0]    key_data //按键当前值
    );
//参数定义
parameter CNT_MAX = 20'd1_000_000;          //延时时间
// parameter CNT_MAX = 20'd10;				    //测试时间 
//信号定义
reg   [6:0]   key_r1    ;//同步
reg   [6:0]   key_r2    ;//打拍 
reg   [24:0]  cnt       ;
reg           add_cnt   ;//计数器使能
wire          end_cnt   ;//计数器结束 
reg    [6:0]  stata_key ;


//key_r1
always@(posedge clk_50m or negedge rst_n)begin
    if(!rst_n)begin
        key_r1 <= 7'b111_1111;
    end
    else begin
        key_r1 <= key ;
    end
end
//key_r2
always@(posedge clk_50m or negedge rst_n)begin
    if(!rst_n)begin
        key_r2 <= 7'b111_1111;
    end
    else begin
        key_r2 <= key_r1 ;
    end
end
//add_cnt
always@(posedge clk_50m or negedge rst_n)begin
    if(!rst_n)begin
        add_cnt <= 1'b0 ;
    end
    else if(key_r1!=key_r2)begin
        add_cnt <= 1'b1 ;
    end
    else if(end_cnt)begin
        add_cnt <= 1'b0 ;
    end
end
//stata_key
always@(posedge clk_50m or negedge rst_n)begin
    if(!rst_n)begin
        stata_key <= 7'b0;
    end
    else if(end_cnt)begin
        stata_key <= key_r1;
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
assign end_cnt = add_cnt && (cnt == CNT_MAX - 1'b1) ;
//key_vld
always@(posedge clk_50m or negedge rst_n)begin
    if(!rst_n)begin
        key_vld <= 1'b1 ;
    end
    else if(end_cnt && key_r1!=7'b111_1111)begin                               //!(key_r[0]&key_r[1]&key_r[2]&key_r[3]&key_r[4]&key_r[5]&key_r[6]&)
        key_vld <= 1'b1 ;
    end
    else if(key_r1==7'b111_1111)begin
        key_vld <= 1'b0 ;
    end
end
//key_data
always@(posedge clk_50m or negedge rst_n)begin
    if(!rst_n)begin
        key_data <= 7'b0 ;
    end
    else if(end_cnt && key_r1!=7'b111_1111)begin
        key_data <= ~key_r1 ;
    end
    else begin
        key_data <= 7'b0 ;
    end
end
endmodule