/************************************
***********易思达FPGA实验*************       
**软    件：GOwin云源软件              
**项    目：按键音乐播放实验                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  top(
    input           clk_50m ,//时钟输入
    input           rst_n   ,//复位输入
    input  [6:0]    key     ,//按键输入
    output [7:0]    led     ,//led输出
    output          beep     //蜂鸣器输出
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s

//信号定义
wire       key_vld  ;
wire [6:0] key_data ;
wire       start    ;
wire [2:0] num1     ;
wire [1:0] num2     ;

//模块例化
key7_filter u1(
    /*input       		*/.clk_50m  (clk_50m  ) ,
    /*input       		*/.rst_n    (rst_n    ) ,
    /*input      [6:0]  */.key      (key      ) ,
    /*output reg   	    */.key_vld  (key_vld  ) ,//按键按下标志
    /*output reg [6:0]  */.key_data (key_data )  //按键当前值
    );

music  u2(
    /*input             */.clk_50m  (clk_50m  ) ,//时钟输入
    /*input             */.rst_n    (rst_n    ) ,//复位输入
    /*input  [6:0]      */.key      (key_data ) ,
    /*output reg        */.start    (start    ) ,
    /*output [2:0]      */.num1     (num1     ) ,//7个音色
    /*output [1:0]      */.num2     (num2     )  //中高低调0：低   1：中   2：高
    );
    
voice_gen  u3(
    /*input             */.clk_50m  (clk_50m  ) ,//时钟输入
    /*input             */.rst_n    (rst_n    ) ,//复位输入
    /*input             */.start    (start    ) ,//起始信号
    /*input       [2:0] */.num1     (num1     ) ,//7个音色
    /*input       [1:0] */.num2     (num2     ) ,//中高低调0：低   1：中   2：高
    /*output  reg       */.beep     (beep     ) ,//蜂鸣器
    /*output  reg [7:0] */.led      (led      )  //输出led
    );

endmodule

