/*****************************************************************
*****************************FPGA实验************************     
**软    件:GOwin云源软件                
**项    目:按键控制 SPI LCD屏幕显示彩条实验                      
**时    钟:50MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
module  top(
    input         clk_50m    ,//时钟输入
    input         rst_n      ,//复位输入
    input  [6:0]  key        ,
	output        res        ,//spi lcd 复位
	output        sclk       ,//SPI 时钟
	output        cs         ,//片选
	output        dc         ,//命令/数据控制信号
	output        sda        ,//数据  mosi
    output        bl          //背光   可悬空
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s


//信号定义
wire [6:0] key_data ;

//模块例化
key7_filter u_key7_filter(
    /*input       		  */.clk_50m   (clk_50m      ),
    /*input       		  */.rst_n     (rst_n        ),
    /*input      [6:0]    */.key       (key          ),
    /*output reg   	      */.key_vld   (             ),//按键按下标志
    /*output reg [6:0]    */.key_data  (key_data     ) //按键当前值
    );

spi_lcd u_spi_lcd(
	/*input               */.clk_50m   (clk_50m      ) ,     
	/*input               */.rst_n     (rst_n        ) ,
	/*input               */.key_flag  (key_data[0]  ) ,
   
	/*output              */.res       (res          ) ,//spi lcd 复位
	/*output              */.sclk      (sclk         ) ,//SPI 时钟
	/*output              */.cs        (cs           ) ,//片选
	/*output              */.dc        (dc           ) ,//命令/数据控制信号
	/*output              */.sda       (sda          ) ,//数据  mosi
    /*output              */.bl        (bl           )  //背光   可悬空
); 

endmodule

