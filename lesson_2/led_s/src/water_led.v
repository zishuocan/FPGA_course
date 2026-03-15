/************************************
***********FPGA基础实验*************
**项    目：拨码开关控制led流水灯                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  water_led(
    input  wire        clk_50m ,//时钟输入
    input  wire        rst_n   ,//复位输入
    input  wire        sw_key  ,//拨码开关输入
    output wire [7:0]  led      //led输出
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s

//信号定义
reg   [24:0]  cnt     ;
wire          add_cnt ;
wire          end_cnt ;

reg   [7:0]   led_r = 8'b0000_0001 ;

    //cnt 计数器
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            cnt <= 1'b0 ;
        end
        else if(add_cnt)begin
            if (end_cnt)begin
                cnt <= 1'b0 ;
            end
            else begin
                cnt <= cnt + 1'b1 ;
            end
        end
        else begin
            cnt <= 1'b0 ;
        end
    end
    assign add_cnt = sw_key ;
    assign end_cnt = add_cnt && (cnt == CNT_MAX - 1'b1) ;
    //led_r
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            led_r <= 8'b0000_0001 ;
        end
//-------------------移位拼接--------------
//        else if(sw_key & end_cnt)begin
//            led_r <= {led_r[6:0],led_r[7]} ;//移位拼接
//    
//        end
//--------------------左移---------------------
         else if(sw_key & end_cnt)begin
            if(led_r==8'b1000_0000)begin
                led_r <=8'b0000_0001 ;
            end
            else begin
                led_r <= (led_r <<1 )        ;//左移     
            end       
         end
    end
    //led
    assign led = sw_key?led_r:8'b0 ;
endmodule

