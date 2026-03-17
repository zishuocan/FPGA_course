/************************************
***********易思达FPGA实验*************    
**软    件：GOwin云源软件              
**项    目：动态数码管显示                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  top(
    input            clk_50m ,//时钟输入
    input            rst_n   ,//复位输入
    input            key     ,//按键输入
    output  [3:0]    sel       ,//数码管位选
    output  [7:0]    seg        //数码管段选
    );
//参数定义

//信号定义
wire        key_o    ;
wire [15:0] dis_data ;
//模块例化
    key_filter u1_key_filter(
    /*input           */.clk_50m  (clk_50m ) ,
    /*input           */.rst_n    (rst_n   ) ,
    /*input           */.key_i    (key     ) ,//按键输入
    /*output  reg     */.key_o    (key_o   )  //按键输出
    );

    counter  u2_counter(
    /*input           */.clk_50m  (clk_50m ) ,//时钟
    /*input           */.rst_n    (rst_n   ) ,//复位
    /*input           */.key_vld  (key_o   ) ,//暂停
    /*output  [15:0]  */.dis_data (dis_data)  //{千位，个位，十位，个位}
    );
    seg_ctrl  u3_seg_ctrl(
    /*input           */.clk_50m  (clk_50m ) ,//时钟输入
    /*input           */.rst_n    (rst_n   ) ,//复位输入
    /*input   [15:0]  */.data_in  (dis_data) ,//显示数据
    /*output  [3:0]   */.sel      (sel     ) ,//数码管位选
    /*output  [7:0]   */.seg      (seg     )  //数码管段选
    );
endmodule

