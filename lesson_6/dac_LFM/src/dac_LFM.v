/*****************************************************************
*****************************FPGA实验************************             
**软    件:GOwin云源软件                
**项    目:DAC-LFM                     
**时    钟:100MHz                      
**板卡型号:GW1N-UV9EQ144C6I5           
*****************************************************************/ 

module dac_LFM(
    input                 clk_100m      ,  //系统时钟
    input                 rst_n         ,  //系统复位，低电平有效
    input        [9:0]    rd_data      ,  //ROM读出的数据
    output  reg  [9:0]    rd_addr      ,  //读ROM地址
    //DA接口
    output                da_clk_100m   ,  //DA驱动时钟
    output       [9:0]    da_data         //输出给DA的数据  
    );

//参数定义（100MHz时钟下：脉宽20us，周期100us，2MHz线性扫频到5MHz）
parameter [13:0] PULSE_CYCLES = 14'd2000;    //20us
parameter [13:0] PRI_CYCLES   = 14'd10000;   //100us
parameter [23:0] STEP_START   = 24'd335544;  //2MHz: 2e6*2^24/1e8
parameter [23:0] STEP_STOP    = 24'd838861;  //5MHz: 5e6*2^24/1e8
parameter [39:0] STEP_DELTA_Q = 40'd16492691; //((STEP_STOP-STEP_START)<<16)/PULSE_CYCLES
parameter [9:0]  DAC_MID_DATA = 10'd512;

//信号定义
reg  [13:0] pri_cnt;
reg  [23:0] phase_acc;
reg  [39:0] phase_step_q;
wire        pulse_en;

assign pulse_en = (pri_cnt < PULSE_CYCLES);

/***********************************************************************************************/
//数据rd_data是在clk_100m的上升沿更新的，所以DA芯片在clk_100m的下降沿锁存数据是稳定的时刻                 /
//而DA实际上在da_clk_100m的上升沿锁存数据,所以时钟取反,这样clk_100m的下降沿相当于da_clk_100m的上升沿       /
/***********************************************************************************************/
    assign  da_clk_100m = ~clk_100m;
    assign  da_data = pulse_en ? rd_data : DAC_MID_DATA;

    //LFM脉冲串与DDS相位控制
    always @(posedge clk_100m or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            pri_cnt     <= 14'd0;
            phase_acc   <= 24'd0;
            phase_step_q<= {STEP_START,16'd0};
            rd_addr <= 10'd0;
        end
        else begin
            //脉冲周期计数
            if(pri_cnt == PRI_CYCLES - 1'b1)
                pri_cnt <= 14'd0;
            else
                pri_cnt <= pri_cnt + 14'd1;

            //脉冲有效区间内做2MHz->5MHz线性扫频，脉冲外输出直流中值
            if(pri_cnt < PULSE_CYCLES) begin
                rd_addr   <= phase_acc[23:14];
                phase_acc <= phase_acc + phase_step_q[39:16];

                if(pri_cnt == 14'd0)
                    phase_step_q <= {STEP_START,16'd0};
                else
                    phase_step_q <= phase_step_q + STEP_DELTA_Q;
            end
            else begin
                rd_addr      <= 10'd0;
                phase_acc    <= 24'd0;
                phase_step_q <= {STEP_START,16'd0};
            end
        end
    end




endmodule