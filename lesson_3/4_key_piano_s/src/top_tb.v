`timescale 1ns/1ns
module top_tb;

reg        clk_50m;
reg        rst_n  ;
reg  [6:0] key    ;

wire [7:0] led    ;
wire [6:0] key_dd ;
wire       beep   ;
top  u_top(
    /*input             */.clk_50m(clk_50m) ,//时钟输入
    /*input             */.rst_n  (rst_n  ) ,//复位输入
    /*input  [6:0]      */.key    (key    ) ,
    /*output reg [7:0]  */.led    (led    ) ,
    /*output            */.beep   (beep   )   
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