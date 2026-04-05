module top(
    input       clk    ,
    input       rst    ,

    output wire lcd_rs ,
    output wire lcd_cs ,
    output reg  lcd_rst,
    output wire bit_o  ,
    output wire lcd_clk
);
//信号定义
reg        rs         ;
reg        valid      ;
reg        rs_next    ;
reg        wlen_next  ;
reg [14:0] cnt        ;
reg [ 4:0] wlen       ;
reg [15:0] data_i     ;
reg [23:0] clk_cnt    ;
reg [15:0] pixel_cnt  ;
reg [ 4:0] init_state ;
reg [14:0] addr_i     ;

reg        en         ;
wire       ready      ;
wire[15:0] data_o     ;

assign lcd_clk = ~clk ;
//输出彩条
wire [15:0] pixel = (pixel_cnt >= 21600) ? 16'hF800 :
					(pixel_cnt >= 10800) ? 16'h07E0 : 16'h001F;

//初始化参数
localparam INIT_CMDS = 58;
wire [8:0] lcd_init_cmd[0:INIT_CMDS];
assign lcd_init_cmd[ 0] = 9'h036;
assign lcd_init_cmd[ 1] = 9'h170;
assign lcd_init_cmd[ 2] = 9'h03A;
assign lcd_init_cmd[ 3] = 9'h105;
assign lcd_init_cmd[ 4] = 9'h0B2;
assign lcd_init_cmd[ 5] = 9'h10C;
assign lcd_init_cmd[ 6] = 9'h10C;
assign lcd_init_cmd[ 7] = 9'h100;
assign lcd_init_cmd[ 8] = 9'h133;
assign lcd_init_cmd[ 9] = 9'h133;
assign lcd_init_cmd[10] = 9'h0B7;
assign lcd_init_cmd[11] = 9'h135;
assign lcd_init_cmd[12] = 9'h0BB;
assign lcd_init_cmd[13] = 9'h119;
assign lcd_init_cmd[14] = 9'h0C0;
assign lcd_init_cmd[15] = 9'h12C;
assign lcd_init_cmd[16] = 9'h0C2;
assign lcd_init_cmd[17] = 9'h101;
assign lcd_init_cmd[18] = 9'h0C3;
assign lcd_init_cmd[19] = 9'h112;
assign lcd_init_cmd[20] = 9'h0C4;
assign lcd_init_cmd[21] = 9'h120;
assign lcd_init_cmd[22] = 9'h0C6;
assign lcd_init_cmd[23] = 9'h10F;
assign lcd_init_cmd[24] = 9'h0D0;
assign lcd_init_cmd[25] = 9'h1A4;
assign lcd_init_cmd[26] = 9'h1A1;
assign lcd_init_cmd[27] = 9'h0E0;
assign lcd_init_cmd[28] = 9'h1D0;
assign lcd_init_cmd[29] = 9'h104;
assign lcd_init_cmd[30] = 9'h10D;
assign lcd_init_cmd[31] = 9'h111;
assign lcd_init_cmd[32] = 9'h113;
assign lcd_init_cmd[33] = 9'h12B;
assign lcd_init_cmd[34] = 9'h13F;
assign lcd_init_cmd[35] = 9'h154;
assign lcd_init_cmd[36] = 9'h14C;
assign lcd_init_cmd[37] = 9'h118;
assign lcd_init_cmd[38] = 9'h10D;
assign lcd_init_cmd[39] = 9'h10B;
assign lcd_init_cmd[40] = 9'h11F;
assign lcd_init_cmd[41] = 9'h123;
assign lcd_init_cmd[42] = 9'h0E1;
assign lcd_init_cmd[43] = 9'h1D0;
assign lcd_init_cmd[44] = 9'h104;
assign lcd_init_cmd[45] = 9'h10C;
assign lcd_init_cmd[46] = 9'h111;
assign lcd_init_cmd[47] = 9'h113;
assign lcd_init_cmd[48] = 9'h12C;
assign lcd_init_cmd[49] = 9'h13F;
assign lcd_init_cmd[50] = 9'h144;
assign lcd_init_cmd[51] = 9'h151;
assign lcd_init_cmd[52] = 9'h12F;
assign lcd_init_cmd[53] = 9'h11F;
assign lcd_init_cmd[54] = 9'h11F;
assign lcd_init_cmd[55] = 9'h120;
assign lcd_init_cmd[56] = 9'h123;
assign lcd_init_cmd[57] = 9'h021;
assign lcd_init_cmd[58] = 9'h029;


localparam SIZE_CMDS = 10;
wire [8:0] lcd_size_cmd[0:SIZE_CMDS];
// assign lcd_size_cmd[ 0] = 9'h02A; // 列
// assign lcd_size_cmd[ 1] = 9'h100;
// assign lcd_size_cmd[ 2] = 9'h128;
// assign lcd_size_cmd[ 3] = 9'h101;
// assign lcd_size_cmd[ 4] = 9'h117;
// assign lcd_size_cmd[ 5] = 9'h02B; // 行
// assign lcd_size_cmd[ 6] = 9'h100;
// assign lcd_size_cmd[ 7] = 9'h135;
// assign lcd_size_cmd[ 8] = 9'h100;
// assign lcd_size_cmd[ 9] = 9'h1BB;
// assign lcd_size_cmd[10] = 9'h02C; // 开始
//图像显示位置
assign lcd_size_cmd[0] = 9'h02A; // column
assign lcd_size_cmd[1] = 9'h100; //图片起始列位置 x轴   40
assign lcd_size_cmd[2] = 9'h128; //图片起始列位置 x轴  
assign lcd_size_cmd[3] = 9'h100; //图片结束列位置 x轴   40+153-1
assign lcd_size_cmd[4] = 9'h1C0; //图片结束列位置 x轴   193-2
assign lcd_size_cmd[5] = 9'h02B; // row
assign lcd_size_cmd[6] = 9'h100; //图片起始列位置 y轴   53
assign lcd_size_cmd[7] = 9'h135; //图片起始列位置 y轴   
assign lcd_size_cmd[8] = 9'h100; //图片结束列位置 y轴   153+135-1
assign lcd_size_cmd[9] = 9'h1BC; //图片结束列位置 y轴   188
assign lcd_size_cmd[10] = 9'h02C; // start
//时序控制
localparam LCD_RESET        = 5'b00000;
localparam LCD_PREPARE      = 5'b00001;
localparam LCD_WAKEUP       = 5'b00010;
localparam LCD_STANDBY      = 5'b00011;
localparam LCD_INIT         = 5'b00100;
localparam LCD_PAGE_SIZE    = 5'b00101;
localparam LCD_PIXEL        = 5'b00110;

localparam LCD_FINSH        = 5'b11111;

localparam CNT_100MS = 32'd2700000;
localparam CNT_120MS = 32'd3240000;
localparam CNT_200MS = 32'd5400000;

/*----------------------------------------------------------模块例化---------------------------------------------------------*/
//例化lcd驱动模块
lcd_drv lcd_drv_inst(
    .rst( rst ),
    .clk( clk ),
    .valid_i( valid ),
    .wlen_i( wlen ),
    .data_i( data_i ),
    .rs_i( rs ),
    .ready_o( ready ),
    .cs_o( lcd_cs ),
    .rs_o( lcd_rs ),
    .data_bit_o( bit_o )
);
//图片数据
Gowin_pROM u_Gowin_pROM(
    .dout (data_o  ), //output [15:0] dout
    .clk  (clk     ), //input clk
    .oce  (1'b1    ), //input oce
    .ce   (en      ), //input ce
    .reset(!rst    ), //input reset
    .ad   (addr_i  ) //input [14:0] ad
);
/*------------------------------------------------状态机、初始化、输出像素值-----------------------------------------------------*/
always @(posedge clk or negedge rst) begin
    if( !rst ) begin
        cnt <= 0;
        wlen <= 0;
        valid <= 0;
        clk_cnt <= 0;
        wlen_next <= 0;
        init_state <= LCD_RESET;
		lcd_rst <= 0;               //系统复位，拉低lcd复位脚，让lcd复位
        pixel_cnt <= 0;
        data_i <= 0;
        addr_i <= 0;
    end else begin
        if( clk_cnt < 24'hFFFFFF)
            clk_cnt <= clk_cnt + 1'b1;

        case (init_state)

            LCD_RESET : begin 
                if (clk_cnt == CNT_100MS) begin
                    clk_cnt <= 0;
                    lcd_rst <= 1;               //拉低LCD复位脚后，等待100ms后拉高
                    init_state <= LCD_PREPARE;  //切换状态
                end
            end
            LCD_PREPARE : begin                 //复位脚拉高等待200ms
                if (clk_cnt == CNT_200MS) begin
                    clk_cnt <= 0;
                    init_state <= LCD_WAKEUP;
                end
            end
            LCD_WAKEUP : begin
                if( ready==1 && valid == 1'b0 ) begin//等待lcd_drv模块准备好接收数据
                    valid <= 1'b1;                   //valid 拉高，代表数据有效，然lcd_drv接收data_i数据
                    rs <= 0;                         //rs 拉低，代表传输数据为命令
                    wlen <= 8;                       //传输长度设置为8位
                    data_i[15:8] <= 8'h11;      //发送0x11命令让lcd退出睡眠，进入工作模式，发送数据不够16位，放入高8位发送
                end else if( ready && valid ) begin//等待lcd_drv传输完毕
                    valid <= 1'b0;
                    init_state <= LCD_STANDBY;
                end
                clk_cnt <= 0;
            end

            LCD_STANDBY : begin                 //等待120ms，让LCD退出休眠
                if (clk_cnt == CNT_120MS) begin
                    clk_cnt <= 0;
                    init_state <= LCD_INIT;
                end
            end

            LCD_INIT : begin                    //开始循环发送lcd初始化命令和数据
                if( ready==1 && valid == 1'b0 ) begin
                    valid <= 1'b1;
                    wlen <= 8;
                    rs <= lcd_init_cmd[cnt][8];
                    data_i[15:8] <= lcd_init_cmd[cnt][7:0];
                    cnt <= cnt + 1'b1;
                end else if( ready && valid ) begin
                    valid <= 1'b0;
                    if(cnt > INIT_CMDS) begin
                        cnt <= 0;
                        init_state <= LCD_PAGE_SIZE;
                    end
                end
            end

            LCD_PAGE_SIZE : begin               //开始发送设置行和列像素大小
                if( ready==1 && valid == 1'b0 ) begin
                    en <= 1'b0;
                    valid <= 1'b1;
                    wlen <= 8;
                    rs <= lcd_size_cmd[cnt][8];
                    data_i[15:8] <= lcd_size_cmd[cnt][7:0];
                    cnt <= cnt + 1'b1;
                end else if( ready && valid ) begin
                    en <= 1'b1;
                    valid <= 1'b0;
                    if(cnt > SIZE_CMDS) begin
                        cnt <= 0;
                        init_state <= LCD_PIXEL;
                    end
                end
            end

//            LCD_PIXEL : begin                   //开始发送像素数据，采用rgb565格式，一个像素刚好16bits
//                if( ready==1 && valid == 1'b0 ) begin
//                    valid <= 1'b1;
//                    wlen <= 16;
//                    rs <= 1;
//                    data_i <= pixel;
//                    pixel_cnt <= pixel_cnt + 1'b1;
//                end else if( ready && valid ) begin
//                    valid <= 1'b0;
//                    if(pixel_cnt == 32400) begin//135*240=32400，发送完毕后，结束
//                        pixel_cnt <= 0;
//                        init_state <= LCD_FINSH;
//                    end
//                end
//            end

            LCD_PIXEL : begin
                if( ready==1 && valid == 1'b0 ) begin
                    valid <= 1'b1;
                    wlen <= 16;
                    rs <= 1;

                    addr_i <= addr_i + 1'b1;
                    pixel_cnt <= pixel_cnt + 1'b1;
                    if(pixel_cnt>20655)begin
                        data_i <= 16'hF700;
                    end
                    else begin
                        data_i <= data_o;
                    end
                end else if( ready && valid ) begin
                    valid <= 1'b0;
                    if(addr_i == 20655) begin
                        addr_i <= 0;
                        init_state <= LCD_FINSH;
                    end
                end
            end

            LCD_FINSH : begin
				pixel_cnt <= pixel_cnt;
            end
        endcase
    end
end



endmodule