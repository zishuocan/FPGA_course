/************************************
***********易思达FPGA实验*************       
**软    件：GOwin云源软件              
**项    目：按键累加数码管静态显示                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  top(
    input         clk_50m ,
    input         rst_n   ,
    input  [1:0]  key     ,
    output [3:0]  sel   ,
    output [7:0]  seg      
    );
//parameter define


//reg or wire define
wire key_i1    ;
wire key_i2    ;
wire key_o1    ;
wire key_o2    ;
wire [1:0] din ;

    //阻塞赋值
    assign key_i1 = key[0] ;
    assign key_i2 = key[1] ;
    assign din = {key_o2,key_o1} ;
    //模块例化
    key_filter u1(
        /*input            */.clk_50m(clk_50m ),
        /*input            */.rst_n  (rst_n   ),
        /*input            */.key_i  (key_i1  ),//按键输入
        /*output  reg      */. key_o ( key_o1 )  //按键输出
    );

    key_filter u2(
        /*input            */.clk_50m(clk_50m ),
        /*input            */.rst_n  (rst_n   ),
        /*input            */.key_i  (key_i2  ),//按键输入
        /*output  reg      */. key_o ( key_o2 )  //按键输出
    );

    seg_static u3 (
        /*input            */.clk_50m(clk_50m) ,
        /*input            */.rst_n  (rst_n  ) ,
        /*input [1:0]      */.din    (din    ) ,//按键信号输入

        /*output reg [3:0] */.sel    (sel    ) ,//位选
        /*output     [7:0] */.seg    (seg    )  //段选   
    );

endmodule

