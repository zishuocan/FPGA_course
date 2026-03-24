 
module  top(
    input              clk_50m ,//时钟输入
    input              rst_n   ,//复位输入
    input              uart_rx ,
    output      [7:0]  seg     ,//段选
    output      [3:0]  sel      //位选
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s


//信号定义
wire [7:0] rx_o     ;
wire       rx_o_vld ;

//模块例化
uart_rx  u1_uart_rx(
    /*input              */.clk_50m  (clk_50m  ) ,//时钟输入
    /*input              */.rst_n    (rst_n    ) ,//复位输入
    /*input              */.rx_i     (uart_rx  ) ,//uart  接收
    /*output reg [7:0]   */.rx_o     (rx_o     ) ,//uart  输出
    /*output reg         */.rx_o_vld (rx_o_vld )  //输出有效标志
    );
seg_data  u_seg_data(
    /*input              */.clk_50m  (clk_50m  ) ,//时钟输入
    /*input              */.rst_n    (rst_n    ) ,//复位输入
    /*input              */.data_vld (rx_o_vld ) ,//接收数据有效
    /*input       [7:0]  */.data     (rx_o     ) ,//接收数据
    /*output reg  [3:0]  */.sel      (sel      ) ,//位选
    /*output reg  [7:0]  */.seg      (seg      )  //段选
);

endmodule

