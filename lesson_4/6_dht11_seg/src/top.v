  
module  top(
    input         clk_50m ,//时钟输入
    input         rst_n   ,//复位输入
    inout         dht11   ,//单总线输入输出
    input  [6:0]  key     ,//按键
    output [7:0]  led     ,//led输出   //全亮表示湿度  全灭表示温度
    output [3:0]  sel     ,//位选
    output [7:0]  seg      //段选
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s


//信号定义
wire  [6:0]  key_data   ;
wire         key_vld    ;
wire  [31:0] data_valid ;
wire  [15:0] dis_data   ;
wire  [3:0]  point      ;


//模块例化
    key7_filter u1_key7_filter(
    /*input       		  */.clk_50m    (clk_50m    ) ,
    /*input       		  */.rst_n      (rst_n      ) ,
    /*input      [6:0]    */.key        (key        ) ,
    /*output reg   	      */.key_vld    (key_vld    ) ,//按键按下标志
    /*output reg [6:0]    */.key_data   (key_data   )  //按键当前值   此处不使用，不接信号
    );
    dht11_drive u2_dht11_drive (
    /*input               */.clk_50m    (clk_50m    ) ,   //系统时钟
    /*input               */.rst_n      (rst_n      ) ,   //系统复位     
    /*inout               */.dht11      (dht11      ) ,   //dht11温湿度传感器单总线
    /*output reg  [31:0]  */.data_valid (data_valid )     //有效输出数据  8bit 湿度整数数据+8bit 湿度小数数据+8bit 温度整数数据+8bit 温度小数数据
    );  
    data_ctrl  u3_data_ctrl(
    /*input               */.clk_50m    (clk_50m    ) ,//时钟输入
    /*input               */.rst_n      (rst_n      ) ,//复位输入
    /*input               */.key_i      (key_data[0]) ,//按键
    /*input      [31:0]   */.dht_data   (data_valid ) ,//{8bit 湿度整数数据+8bit 湿度小数数据+8bit 温度整数数据+8bit 温度小数数据}
    /*output     [15:0]   */.dis_data   (dis_data   ) ,//显示数据
    /*output     [3:0]    */.point      (point      ) ,//小数点
    /*ouput      [7:0]    */.led        (led)         //全亮表示湿度  全灭表示温度
    );
    seg_ctrl  u4_seg_ctrl(
    /*input               */.clk_50m    (clk_50m    ) ,//时钟输入
    /*input               */.rst_n      (rst_n      ) ,//复位输入
    /*input       [15:0]  */.data_in    (dis_data   ) ,//显示数据
    /*input       [3:0]   */.point      (point      ) ,//小数点
    /*output reg  [3:0]   */.sel        (sel        ) ,//数码管位选
    /*output reg  [7:0]   */.seg        (seg        )  //数码管段选
    );
endmodule

