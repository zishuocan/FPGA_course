
module  uart(
    input     clk_50m ,//时钟输入
    input     rst_n   ,//复位输入
    input     rx      ,//串口接收
    output    tx       //串口发送
    );
//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s

//信号定义
wire            busy     ;
wire [7:0]      rx_o     ;
wire            rx_o_vld ;
reg  [7:0]      data_r   ;
reg             data_vld ;
reg             tx_en    ;
//模块例化
uart_rx  u1_uart_rx(
    /*input             */.clk_50m  (clk_50m  ) ,//时钟输入
    /*input             */.rst_n    (rst_n    ) ,//复位输入
    /*input             */.rx_i     (rx       ) ,//uart_rx  接收
    /*output reg [7:0]  */.rx_o     (rx_o     ) ,//uart_rx  输出
    /*output reg        */.rx_o_vld (rx_o_vld )  //输出有效标志
    );

uart_tx  u2_uart_tx(
    /*input             */.clk_50m  (clk_50m  ) ,//时钟输入
    /*input             */.rst_n    (rst_n    ) ,//复位输入
    /*input      [7:0]  */.data_i   (data_r   ) ,//需要发送的数据
    /*input             */.tx_en    (tx_en    ) ,//数据有效信号
    /*output reg        */.tx_o     (tx       ) ,//串口发送
    /*output reg        */.busy     (busy     )  //1：忙碌   0：空闲       
    );
//---------------------------------------------------------
    //data_r  寄存rx接收的值，准备发送
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            data_r <= 8'b0;
        end
        else if(rx_o_vld)begin
            data_r <= rx_o;
        end
    end
    //data_vld
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            data_vld <= 1'b0;
        end
        else if(rx_o_vld)begin
            data_vld <= 1'b1;
        end
        else if(!busy)begin
            data_vld <= 1'b0;
        end
    end
    //tx_en
    always@(posedge clk_50m or negedge rst_n)begin
        if(!rst_n)begin
            tx_en <= 1'b0;
        end
        else if(data_vld & (!busy))begin
            tx_en <= 1'b1;
        end
        else begin
            tx_en <= 1'b0 ;
        end
    end

endmodule

