`timescale 1ns/1ns
module key_filter_tb;
defparam u1.CNT_MAX = 10 ;
reg clk_50m;
reg rst_n;
reg [6:0]key;
 
wire [6:0]  key_data ;
wire key_vld;
wire [6:0] key_dd ;
 
key_filter u1(
    /*input        */.clk_50m (clk_50m )    ,
    /*input        */.rst_n   (rst_n   )    ,
    /*input        */.key     (key     )    ,//按键输入
    /*output  reg  */.key_data (key_data )  ,   //按键输出
    /*output  reg  */.key_vld  (key_vld )     //按键输出
);
 
always #10 clk_50m = !clk_50m ;
initial begin    
    rst_n   <= 1'b0;
    clk_50m <= 1'b0;
    key = 1'b1; 
    #100
rst_n   <= 1'b1;
    key_press(7'b111_1110);
    #1000 
$stop ;
end
task key_press;
    input [6:0] key_dd;
    begin
        #100
        key = key_dd ;
        #30
        key = 7'b111_1111;
        #10
        key = key_dd ;
        #10
        key = 7'b111_1111;
        #20
        key = key_dd;
        #1000 
        key = 7'b111_1111;
        #10
        key = key_dd ;
        #10
        key = 7'b111_1111;
        #1000                //模拟一个按键


        key = key_dd ;
        #30
        key = 7'b111_1111;
        #10
        key = key_dd ;
        #10
        key = 7'b111_1111;
        #20
        key = key_dd;
        #300
        key = 7'b111_0110;
        #30
        key = 7'b111_1110;
        #30
        key = 7'b111_0110;
        #1000
        key = 7'b111_0111;
        #30
        key = 7'b111_0110;
        #20
        key = 7'b111_0111;
        #500
        key = 7'b111_1111;
        #30
        key = 7'b111_0111;
        #20
        key = 7'b111_1111;
        #500      ;         //模拟一个按键被按下时另外一个按键
    end


endtask


endmodule