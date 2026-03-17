/************************************
***********易思达FPGA实验*************            
**软    件：GOwin云源软件              
**项    目：按键消抖模块                     
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module key_filter(
    input        clk_50m     ,
    input        rst_n       ,
    input        key_i       ,//按键输入
    output  reg  key_o        //按键输出
);
//参数定义
parameter CN_MAX = 1000_000 ;//20ms延时计数器最大值

//信号定义
reg [19:0] cn      ;
reg [1:0]  key_i_r ;//对按键信号同步打拍
reg        nege    ;//下降沿检查

    //20ms延时计数器
    always@(posedge clk_50m or negedge rst_n )begin
        if(!rst_n)
            cn <= 20'b0 ;
        else if(nege == 1'b0 )
                cn <= 20'b0 ;
        else if(nege == 1'b1)
                cn <= cn + 1'b1 ;
    end
    //key_i_r  同步打拍
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)
            key_i_r <= 2'b00 ;
        else 
            key_i_r <= {key_i_r[0],key_i };
    end
    //nege
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)
            nege <= 1'b0;
        else if(cn == (CN_MAX -1'b1))
            nege <= 1'b0 ;
        else if(!key_i_r[0]&key_i_r[1])
            nege <= 1'b1;
    end
    //key_o
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            key_o <= 1'b0 ;
        end
        else if(cn==(CN_MAX -1'b1) && !key_i_r[0])begin
            key_o <= 1'b1 ;
        end
        else begin
            key_o <= 1'b0 ;
        end
    end


endmodule
