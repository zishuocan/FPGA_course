module lcd_drv(
    input             rst       ,
    input             clk       ,
    input             rs_i      ,
    input             valid_i   ,
    input wire [4:0]  wlen_i    ,
    input wire [15:0] data_i    ,
    
    output reg        rs_o      ,
    output reg        cs_o      ,
    output reg        ready_o   ,
    output reg        data_bit_o
);
//信号定义
reg flag;
reg [15:0] tmp_data;
reg [5:0] bits_cnt;
reg [5:0] bits_max;
reg start_send;

always@ (*) begin
  //检测到valid为1，表示可以接收数据
  if( valid_i == 1'b1 && flag == 1'b0) begin
        flag = 1'b1;
        ready_o = 1'b0;
        rs_o    = rs_i;     //将传入的数据分别赋给相应临时变量
        bits_max = wlen_i;
        tmp_data = data_i;
        start_send = 1'b1;  //启动数据发送
    end else if(valid_i == 0)begin  //复位后，顶层（top)valid==0
        flag = 1'b0;
        ready_o = 1'b1;             //ready 拉高，表示准备好接收数据
    end else if(bits_cnt == bits_max) begin
        ready_o = 1'b1;             //发送完毕，将ready拉高，等待接收下一个数据
        start_send = 1'b0;          //将发送标志位置0
    end
end


always@ (posedge clk or negedge rst) begin
    if( !rst ) begin
        cs_o     <= 1'b1;
        bits_cnt <= 6'h0;
        data_bit_o <= 1'b0;
    end else if( start_send == 1'b1 ) begin
        bits_cnt <= bits_cnt + 1'b1;
        if(bits_cnt < bits_max) begin
            cs_o <= 1'b0;                           //cs 拉低，片选信号有效，开始传输数据
            data_bit_o <= tmp_data[15-bits_cnt];    //依次将高位数据传输出去
        end else begin
            cs_o <= 1'b1;                           //传输完成，片选信号拉高    
        end
    end else begin
        cs_o <= 1'b1;
        bits_cnt <= 1'b0;                           //清零发送位计数
    end
end


endmodule