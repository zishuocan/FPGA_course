 `timescale 1ns/1ns 
module ad_ctrl_tb();
//信号定义
reg			 clk_50m		;
reg			 rst_n			;

reg	[9:0]	 data_in		;
reg			 din2			;
wire[9:0]	 data_vpp 		;
wire[9:0]	 data_freq		;

//模块例化
ad_data_ctrl  u_ad_data_ctrl(
    /*input               */.clk_50m   (clk_50m   ),//时钟输入
    /*input               */.rst_n     (rst_n     ),//复位输入
    /*input       [9:0]   */.data_in   (data_in   ),//ad采集数据
    /*output wire [9:0]   */.data_vpp  (data_vpp  ),//峰峰值电压值（已转化，实际电压值）   80us更新一次
    /*output wire [9:0]   */.data_freq (data_freq )//被测信号的频率   
);



//时钟 复位初始化
    initial begin
        clk_50m = 1'b0 ;
        rst_n = 1;
        #10;
        rst_n = 0;
        #40;
        rst_n = 1;
    end
    always #10 clk_50m = ~clk_50m ;
//输入信号设置
    initial begin
    data_in = 10'd0;
    #200;
    data_in = 10'd511;
    #20;
    data_in = 10'd512;
    #20;
    data_in = 10'd513;
    #20;
    data_in = 10'd516;
    #20;
    data_in = 10'd518;//////////////////////////////////
    #20;
    data_in = 10'd516;
    #20;
    data_in = 10'd515;
    #20;
    data_in = 10'd514;
    #20;
    data_in = 10'd512;
    #20;
    data_in = 10'd511;
    #20;
    data_in = 10'd510;
    #20;
    data_in = 10'd509;
    #20;
    data_in = 10'd507;
    #20;
    data_in = 10'd506;
    #20;
    data_in = 10'd505;///////////////////////////////////
    #20;
    data_in = 10'd506;
    #20;
    data_in = 10'd507;
    #20;
    data_in = 10'd508;
    #20;
    data_in = 10'd510;
    #20;
    data_in = 10'd509;//////
    #20;
    data_in = 10'd512;
    #20;
    data_in = 10'd513;
    #20;
    data_in = 10'd516;
    #20;
    data_in = 10'd518;//////////////////////////////////////
    #20;
    data_in = 10'd516;
    #20;
    data_in = 10'd515;
    #20;
    data_in = 10'd514;
    #20;
    data_in = 10'd512;
#200
$stop;

    end
endmodule