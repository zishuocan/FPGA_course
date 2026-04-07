/*****************************************************************
*****************************FPGA实验************************            
**软    件:GOwin云源软件                
**项    目:adc检测波形峰峰值电压数码管显示实验                   
**时    钟:100MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/  
module  top(
    input          clk_100m     ,//时钟输入
    input          rst_n       ,//复位输入
    //ad1
    input  [9:0]   ad1_data     ,//da数据
    input          ad1_ort      ,//超量程标志
    output         oe1_n        ,//ad 使能
    output         ad1_clk      ,//da时钟
    //da1
    output         da1_clk      ,//ad1时钟
    output [9:0]   da1_data     ,//ad数据
    //显示发送
    output         tx           ,
    output [7:0]   led          ,
    output [3:0]   sel          ,
    output [7:0]   seg          
);


//参数定义
parameter   CNT_MAX = 25'd25_000_000 ;//0.5s

//信号定义
wire [15:0] dis_data_vpp  ;
reg  [15:0] dis_data_vpp1 ;
reg         clk_50m       ;
wire        uart_en ;
reg         uart_en_d     ;
wire        da_clk  ; 
wire   [9:0]    da_data ; 
/*--------------------------------------------------------*/
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            clk_50m <= 1'b0;
        end
        else begin
            clk_50m <= ~clk_50m ;
        end
    end
//assign dis_data_vpp1 = dis_data_vpp ;
    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            dis_data_vpp1 <= 1'b0;
        end
        else if(uart_en)begin
            dis_data_vpp1 <= dis_data_vpp;
        end
    end

    always@(posedge clk_100m or negedge rst_n)begin
        if(!rst_n)begin
            uart_en_d <= 1'b0;
        end
        else begin
            uart_en_d <= uart_en;
        end
    end

/*--------------------------------------------模块例化------------------------------------------------*/
    //产生波形
    dac u_dac(
        /*input              */.clk_100m      (clk_100m       ),//系统时钟
        /*input              */.rst_n        (rst_n         ),//系统复位，低电平有效
        //DA1接口
        /*output             */.da_clk       (da1_clk       ),//DA驱动时钟  100m
        /*output      [9:0]  */.da_data      (da1_data      ) //输出给DA的数据    大概是200khz正弦波
    );
    //检测波形（有效值）
    adc  u_adc(
        /*input              */.clk_100m      (clk_100m       ),//时钟输入
        /*input              */.rst_n        (rst_n         ),//复位输入
        /*input      [9:0]   */.ad_data      (ad1_data      ),//ad数字信号输入
        /*input              */.ad_ort       (ad1_ort       ),//超量程标志
        /*output             */.ad_clk       (ad1_clk       ),//ad驱动时钟
        /*output             */.oe1_n        (oe1_n         ),  
        /*output             */.uart_en      (uart_en       ),
        /*output reg [15:0]  */.dis_data_vpp (dis_data_vpp  ) //有效值电压值   数码管显示   uart发送
    );
    //数码管显示
    seg_ctrl  u_seg_ctrl(
        /*input                */.clk_100m (clk_100m )  ,//时钟输入
        /*input                */.rst_n   (rst_n   )  ,//复位输入
        /*input       [15:0]   */.data_in (dis_data_vpp1)  ,//显示数据        16'h1234
        /*input       [3:0]    */.point   (4'b1011 )  ,//小数点
        /*output reg  [3:0]    */.sel     (sel     )  ,//数码管位选
        /*output reg  [7:0]    */.seg     (seg     )   //数码管段选
    );

    //串口发送：每次uart_en到来后，延迟1拍发送锁存后的显示值
    tx_ctrl #(
        .CLK_FREQ_HZ(50000000),
        .BAUD_RATE  (57600)
    ) u_tx_ctrl(
        .clk_100m (clk_100m     ),
        .rst_n    (rst_n        ),
        .send_en  (uart_en_d     ),
        .data_bcd (dis_data_vpp1 ),
        .tx       (tx           )
    );

    assign led = {ad1_ort,ad1_ort,ad1_ort,ad1_ort,ad1_ort,ad1_ort,ad1_ort,ad1_ort};


endmodule

module tx_ctrl #(
    parameter integer CLK_FREQ_HZ = 100000000,
    parameter integer BAUD_RATE   = 115200
)(
    input               clk_100m,
    input               rst_n,
    input               send_en,
    input      [15:0]   data_bcd,
    output              tx
);

localparam integer CLKS_PER_BIT = CLK_FREQ_HZ / BAUD_RATE;
localparam [3:0]   TOTAL_BYTES  = 4'd10;

reg        sending;
reg [3:0]  byte_idx;
reg [15:0] data_latched;
reg        tx_dv;
reg [7:0]  tx_byte;

wire tx_active;
wire tx_done;

function [7:0] nibble_to_ascii;
    input [3:0] din;
    begin
        if(din <= 4'd9) begin
            nibble_to_ascii = 8'h30 + din;
        end
        else begin
            nibble_to_ascii = 8'h30;
        end
    end
endfunction

function [7:0] frame_byte;
    input [3:0]  index;
    input [15:0] bcd_data;
    begin
        case(index)
            4'd0: frame_byte = 8'h52;
            4'd1: frame_byte = 8'h4D;
            4'd2: frame_byte = 8'h53;
            4'd3: frame_byte = 8'h3A;
            4'd4: frame_byte = nibble_to_ascii(bcd_data[15:12]);
            4'd5: frame_byte = nibble_to_ascii(bcd_data[11:8]);
            4'd6: frame_byte = nibble_to_ascii(bcd_data[7:4]);
            4'd7: frame_byte = nibble_to_ascii(bcd_data[3:0]);
            4'd8: frame_byte = 8'h0D;
            4'd9: frame_byte = 8'h0A;
            default: frame_byte = 8'h20;
        endcase
    end
endfunction

always @(posedge clk_100m or negedge rst_n) begin
    if(!rst_n) begin
        sending       <= 1'b0;
        byte_idx      <= 4'd0;
        data_latched  <= 16'd0;
        tx_dv         <= 1'b0;
        tx_byte       <= 8'd0;
    end
    else begin
        tx_dv <= 1'b0;
        if(!sending) begin
            if(send_en) begin
                sending      <= 1'b1;
                byte_idx     <= 4'd0;
                data_latched <= data_bcd;
                tx_byte      <= frame_byte(4'd0, data_bcd);
                tx_dv        <= 1'b1;
            end
        end
        else if(tx_done) begin
            if(byte_idx == TOTAL_BYTES - 1'b1) begin
                sending  <= 1'b0;
                byte_idx <= 4'd0;
            end
            else begin
                byte_idx <= byte_idx + 1'b1;
                tx_byte  <= frame_byte(byte_idx + 1'b1, data_latched);
                tx_dv    <= 1'b1;
            end
        end
    end
end

uart_tx #(
    .CLKS_PER_BIT(CLKS_PER_BIT)
) u_uart_tx (
    .i_clk      (clk_100m ),
    .i_rst_n    (rst_n    ),
    .i_tx_dv    (tx_dv    ),
    .i_tx_byte  (tx_byte  ),
    .o_tx_active(tx_active),
    .o_tx_serial(tx       ),
    .o_tx_done  (tx_done  )
);

endmodule

module uart_tx #(
    parameter integer CLKS_PER_BIT = 868
)(
    input              i_clk,
    input              i_rst_n,
    input              i_tx_dv,
    input      [7:0]   i_tx_byte,
    output reg         o_tx_active,
    output reg         o_tx_serial,
    output reg         o_tx_done
);

localparam [2:0] S_IDLE  = 3'd0;
localparam [2:0] S_START = 3'd1;
localparam [2:0] S_DATA  = 3'd2;
localparam [2:0] S_STOP  = 3'd3;
localparam [2:0] S_CLEAN = 3'd4;

reg [2:0]  state;
reg [31:0] clk_cnt;
reg [2:0]  bit_idx;
reg [7:0]  tx_data;

always @(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin
        state        <= S_IDLE;
        o_tx_active  <= 1'b0;
        o_tx_serial  <= 1'b1;
        o_tx_done    <= 1'b0;
        clk_cnt      <= 32'd0;
        bit_idx      <= 3'd0;
        tx_data      <= 8'd0;
    end
    else begin
        o_tx_done <= 1'b0;
        case(state)
            S_IDLE: begin
                o_tx_serial <= 1'b1;
                o_tx_active <= 1'b0;
                clk_cnt     <= 32'd0;
                bit_idx     <= 3'd0;
                if(i_tx_dv) begin
                    tx_data     <= i_tx_byte;
                    o_tx_active <= 1'b1;
                    state       <= S_START;
                end
            end

            S_START: begin
                o_tx_serial <= 1'b0;
                if(clk_cnt < CLKS_PER_BIT - 1) begin
                    clk_cnt <= clk_cnt + 1'b1;
                end
                else begin
                    clk_cnt <= 32'd0;
                    state   <= S_DATA;
                end
            end

            S_DATA: begin
                o_tx_serial <= tx_data[bit_idx];
                if(clk_cnt < CLKS_PER_BIT - 1) begin
                    clk_cnt <= clk_cnt + 1'b1;
                end
                else begin
                    clk_cnt <= 32'd0;
                    if(bit_idx < 3'd7) begin
                        bit_idx <= bit_idx + 1'b1;
                    end
                    else begin
                        bit_idx <= 3'd0;
                        state   <= S_STOP;
                    end
                end
            end

            S_STOP: begin
                o_tx_serial <= 1'b1;
                if(clk_cnt < CLKS_PER_BIT - 1) begin
                    clk_cnt <= clk_cnt + 1'b1;
                end
                else begin
                    clk_cnt     <= 32'd0;
                    o_tx_done   <= 1'b1;
                    o_tx_active <= 1'b0;
                    state       <= S_CLEAN;
                end
            end

            S_CLEAN: begin
                state <= S_IDLE;
            end

            default: begin
                state <= S_IDLE;
            end
        endcase
    end
end

endmodule

