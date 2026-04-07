/*****************************************************************
*****************************FPGA实验************************
**软    件:GOwin云源软件
**项    目:ad数据处理，正弦波有效值检测(RMS)
**时    钟:100MHz
**板卡型号:GW1N-UV9EQ144C6I5
*****************************************************************/
module  ad_data_ctrl1(
    input               clk_100m   ,//时钟输入
    input               rst_n     ,//复位输入
    input       [9:0]   data_in   ,//ad采集数据
    output reg  [31:0]  data_vpp   //有效值（RMS）数值输出
);

//参数定义
parameter [13:0] SAMPLE_NUM  = 14'd10000; //100MHz下约100us窗口
parameter [9:0]  ADC_MID     = 10'd512;   //10bit ADC 中值
parameter [9:0]  NOISE_FLOOR = 10'd3;     //小信号抑制阈值

//信号定义
reg   [13:0]  sample_cnt       ;
reg   [35:0]  square_sum       ;
reg   [21:0]  mean_square      ;

wire signed [10:0] data_offset ;
wire signed [21:0] data_square_s;
wire        [21:0] data_square ;
wire        [35:0] sum_with_sample;
wire        [35:0] mean_square_full;
wire        [21:0] mean_square_next;
wire               window_done ;
wire        [9:0]  rms_next    ;

function [9:0] int_sqrt_u22;
    input [21:0] din;
    integer i;
    reg [9:0] root;
    reg [9:0] candidate;
    reg [21:0] square;
    begin
        root = 10'd0;
        for(i = 9; i >= 0; i = i - 1) begin
            candidate = root | (10'd1 << i);
            square = candidate * candidate;
            if(square <= din) begin
                root = candidate;
            end
        end
        int_sqrt_u22 = root;
    end
endfunction

assign data_offset      = $signed({1'b0,data_in}) - $signed({1'b0,ADC_MID});
assign data_square_s    = data_offset * data_offset;
assign data_square      = data_square_s[21:0];
assign sum_with_sample  = square_sum + {{14{1'b0}},data_square};
assign window_done      = (sample_cnt == SAMPLE_NUM - 1'b1);
assign mean_square_full = sum_with_sample / SAMPLE_NUM;
assign mean_square_next = mean_square_full[21:0];
assign rms_next         = int_sqrt_u22(mean_square_next);

always@(posedge clk_100m or negedge rst_n)begin
    if(!rst_n)begin
        sample_cnt   <= 14'd0;
        square_sum   <= 36'd0;
        mean_square  <= 22'd0;
        data_vpp     <= 32'd0;
    end
    else if(window_done)begin
        sample_cnt  <= 14'd0;
        square_sum  <= 36'd0;
        mean_square <= mean_square_next;
        if(rms_next < NOISE_FLOOR)begin
            data_vpp <= 32'd0;
        end
        else begin
            data_vpp <= {22'd0,rms_next};
        end
    end
    else begin
        sample_cnt  <= sample_cnt + 1'b1;
        square_sum  <= sum_with_sample;
    end
end

endmodule