/************************************
***********易思达FPGA实验*************       
**软    件：GOwin云源软件              
**项    目：静态数码管控制模块                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  seg_static(
    input            clk_50m ,
    input            rst_n   ,
    input      [1:0] din     ,//按键信号输入

    output reg [3:0] sel     ,//位选
    output reg [7:0] seg      //段选   
    );
//参数定义
localparam  zero  = 7'b1000000 ,
            one   = 7'b1111001 ,
            two   = 7'b0100100 ,
            three = 7'b0110000 ,
            four  = 7'b0011001 ,
            five  = 7'b0010010 ,
            six   = 7'b0000010 ,
            seven = 7'b1111000 ,
            eight = 7'b0000000 ,
            nine  = 7'b0010000 ,
            sign_m= 7'b0111111 ;

//信号定义
reg [3:0]  cnt1 ;

    //循环计数10次（0~9） 显示码
    always@(posedge clk_50m or negedge rst_n )begin
        if(!rst_n)begin
            cnt1 <= 4'b0 ; 
        end
        else if(cnt1 ==(10))begin
            cnt1 <= 4'b0 ;
        end
        else if(din[0])begin
            cnt1 <= cnt1 + 1'b1 ;
        end
    end

    //output    
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            sel <= 4'b1110;
        end
        else if(din[1])begin
            sel <= {sel[2:0],sel[3]} ;
        end
        else begin
            sel <= sel ;
        end
    end

    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            seg <= 8'b0000_0000 ;
        end
        else begin
            case(cnt1)
            0:seg <= {1'b1,zero } ;//最高位为小数点 1：亮     0：灭
            1:seg <= {1'b1,one  } ;//最高位为小数点 1：亮     0：灭
            2:seg <= {1'b1,two  } ;//最高位为小数点 1：亮     0：灭
            3:seg <= {1'b1,three} ;//最高位为小数点 1：亮     0：灭
            4:seg <= {1'b1,four } ;//最高位为小数点 1：亮     0：灭
            5:seg <= {1'b1,five } ;//最高位为小数点 1：亮     0：灭
            6:seg <= {1'b1,six  } ;//最高位为小数点 1：亮     0：灭
            7:seg <= {1'b1,seven} ;//最高位为小数点 1：亮     0：灭
            8:seg <= {1'b1,eight} ;//最高位为小数点 1：亮     0：灭
            9:seg <= {1'b1,nine } ;//最高位为小数点 1：亮     0：灭
            default:seg <= 8'b0000_0000 ;
            endcase
        end
    end

endmodule

