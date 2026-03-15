module breather_led (
    input  wire       clk_50m,   // 对应约束文件: 时钟 50MHz
    input  wire       rst_n,     // 对应约束文件: 复位按键 k8
    input  wire       sw_key,    // 对应约束文件: 拨码开关 sw1 (必须声明以防报错，哪怕内部悬空不用)
    output wire [7:0] led        // 对应约束文件: 8个LED输出
);

    // 定义寄存器
    reg [5:0] cnt_1us;      // 1us 计数器 (0~49)
    reg [9:0] cnt_1ms;      // 1ms 计数器 (0~999)，兼作 PWM 周期计数
    reg [10:0] cnt_1000ms;    // 1s 计数器 (0~999)，控制占空比变化
    reg       inc_dec_flag; // 呼吸方向标志：0为渐亮，1为渐暗

    // 1. 产生 1us 的时基 (50MHz时钟计数50次为1us)
    /*
    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n)
            cnt_1us <= 6'd0;
        else if (cnt_1us == 6'd49)
            cnt_1us <= 6'd0;
        else
            cnt_1us <= cnt_1us + 1'b1;
    end
    */

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n)
            cnt_1us <= 6'd0;
        else if (cnt_1us == 6'd4)
            cnt_1us <= 6'd0;
        else
            cnt_1us <= cnt_1us + 1'b1;
    end


    // 2. 产生 1ms 的时基 (PWM 周期，即1000个1us)
    /*
    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n)
            cnt_1ms <= 10'd0;
        else if (cnt_1us == 6'd49) begin
            if (cnt_1ms == 10'd999)
                cnt_1ms <= 10'd0;
            else
                cnt_1ms <= cnt_1ms + 1'b1;
        end
    end
    */

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n)
            cnt_1ms <= 10'd0;
        else if (cnt_1us == 6'd4) begin
            if (cnt_1ms == 10'd9)
                cnt_1ms <= 10'd0;
            else
                cnt_1ms <= cnt_1ms + 1'b1;
        end
    end


// 3. 产生 1s 的占空比控制时基，并翻转呼吸方向
/*
    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            cnt_1000ms <= 11'd0;
            inc_dec_flag <= 1'b0;
        end
        else if (cnt_1us == 6'd49 && cnt_1ms == 10'd999) begin
            if (cnt_1000ms == 11'd999) begin // 从 499 改成 999
                cnt_1000ms <= 11'd0;
                inc_dec_flag <= ~inc_dec_flag; // 1s 到了，翻转渐亮/渐暗状态
            end
            else begin
                cnt_1000ms <= cnt_1000ms + 1'b1;
            end
        end
    end
    */

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            cnt_1000ms <= 11'd0;
            inc_dec_flag <= 1'b0;
        end
        else if (cnt_1us == 6'd4 && cnt_1ms == 10'd9) begin
            if (cnt_1000ms == 11'd9) begin // 从 499 改成 999
                cnt_1000ms <= 11'd0;
                inc_dec_flag <= ~inc_dec_flag; // 1s 到了，翻转渐亮/渐暗状态
            end
            else begin
                cnt_1000ms <= cnt_1000ms + 1'b1;
            end
        end
    end


// 4. 核心逻辑：生成 PWM 信号
    // cnt_1000ms 的范围已经是 0~999，直接与 PWM 周期(cnt_1ms)比较即可
    //wire [9:0] pwm_threshold = inc_dec_flag ? (10'd999 - cnt_1000ms[9:0]) : cnt_1000ms[9:0];
    wire [9:0] pwm_threshold = inc_dec_flag ? (10'd9 - cnt_1000ms[9:0]) : cnt_1000ms[9:0];
    
    // 当 PWM 计数器小于阈值时输出高电平（点亮），否则输出低电平
    wire pwm_out = (cnt_1ms < pwm_threshold) ? 1'b1 : 1'b0;

    // 8个 LED 同时显示同样的呼吸效果
    assign led = {8{pwm_out}};

endmodule