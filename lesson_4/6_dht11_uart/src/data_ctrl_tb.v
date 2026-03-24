 `timescale 1ns/1ns 
module data_ctrl_tb();
//信号定义
reg			clk_50m			;
reg			rst_n			;

reg	[31:0]	 dht_data	    ;
reg			 din2			;
wire [7:0]	 data_o     	;
wire		 data_o_vld 	;
//模块例化

data_ctrl  u_data_ctrl(
    /*input              */.clk_50m    (clk_50m    ),//时钟输入
    /*input              */.rst_n      (rst_n      ),//复位输入
    /*input      [31:0]  */.dht_data   (dht_data   ),//{8bit 湿度整数数据+8bit 湿度小数数据+8bit 温度整数数据+8bit 温度小数数据}
    /*output reg [7:0]   */.data_o     (data_o     ),//显示数据
    /*output reg         */.data_o_vld (data_o_vld ) //数据有效信号  使能uart_tx
    );


//时钟 复位初始化
    initial begin
        clk_50m = 1'b0 ;
        rst_n = 1;
        dht_data = 32'b11110000_11110000_11110000_11110000;
        #100;
        rst_n = 0;
        #100
        rst_n = 1;
        #400000;
        
        $stop;
    end
    always #10 clk_50m = ~clk_50m ;

endmodule