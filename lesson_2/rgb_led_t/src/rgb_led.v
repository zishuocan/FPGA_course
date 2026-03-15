module rgb_led (
    input  wire       clk_50m,   // 系统时钟 50MHz
    input  wire       rst_n,     // 复位按键
    input  wire       sw_key,    // 拨码开关 (防报错悬空引脚)
    output wire [2:0] rgb1       // RGB输出: [0]红, [1]绿, [2]蓝
);

    // 基础计时器
    reg [5:0] cnt_1us;      // 1us 计数器 (0~49)
    reg [9:0] cnt_1ms;      // 1ms PWM周期计数 (0~999)
    
    // 呼吸控制
    // 题目要求 0.5s 呼吸周期，即 0.25s变亮，0.25s变暗
    // 0.25s = 250ms，所以我们需要一个 0~249 的计数器
    reg [7:0] cnt_250ms;    
    reg       inc_dec_flag; // 0为渐亮，1为渐暗

    // 色彩状态机：0代表红，1代表绿，2代表蓝
    reg [2:0] color_state;

    // 1. 产生 1us 时基
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


    // 2. 产生 1ms PWM 周期
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

    // 3. 产生 0.25s 的占空比控制时基，并切换颜色状态
    /*
    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            cnt_250ms <= 8'd0;
            inc_dec_flag <= 1'b0;
            color_state <= 3'd0;
        end
        else if (cnt_1us == 6'd49 && cnt_1ms == 10'd999) begin
            if (cnt_250ms == 8'd249) begin
                cnt_250ms <= 8'd0;
                inc_dec_flag <= ~inc_dec_flag; // 0.25s到了，翻转亮暗方向
                
                // 如果刚刚完成了一次完整的呼吸（渐亮+渐暗 = 0.5s），则切换颜色
                if (inc_dec_flag == 1'b1) begin 
                    if (color_state == 3'd2)
                        color_state <= 3'd0; // 蓝完变红
                    else
                        color_state <= color_state + 1'b1;
                end
            end
            else begin
                cnt_250ms <= cnt_250ms + 1'b1;
            end
        end
    end
    */

    always @(posedge clk_50m or negedge rst_n) begin
        if (!rst_n) begin
            cnt_250ms <= 8'd0;
            inc_dec_flag <= 1'b0;
            color_state <= 3'd0;
        end
        else if (cnt_1us == 6'd4 && cnt_1ms == 10'd9) begin
            if (cnt_250ms == 8'd9) begin
                cnt_250ms <= 8'd0;
                inc_dec_flag <= ~inc_dec_flag; // 0.25s到了，翻转亮暗方向
                
                // 如果刚刚完成了一次完整的呼吸（渐亮+渐暗 = 0.5s），则切换颜色
                if (inc_dec_flag == 1'b1) begin 
                    if (color_state == 3'd2)
                        color_state <= 3'd0; // 蓝完变红
                    else
                        color_state <= color_state + 1'b1;
                end
            end
            else begin
                cnt_250ms <= cnt_250ms + 1'b1;
            end
        end
    end


    // 4. 计算 PWM 阈值
    // cnt_250ms 是 0~249。为了匹配 0~999 的 PWM 周期，我们将其乘以 4 (左移2位) 变成 0~996
    //wire [9:0] pwm_threshold = inc_dec_flag ? (10'd996 - {cnt_250ms, 2'b00}) : {cnt_250ms, 2'b00};
    wire [9:0] pwm_threshold = inc_dec_flag ? (10'd9 - cnt_250ms) : cnt_250ms;
    
    // 5. 生成 PWM 信号 (注意：共阳极 RGB，0 为亮，1 为灭)
    // 当计数器小于阈值时，输出 0 (点亮)，否则输出 1 (熄灭)
    wire pwm_active = (cnt_1ms < pwm_threshold) ? 1'b0 : 1'b1;
    wire pwm_idle   = 1'b1; // 不工作的颜色保持全灭 (输出 1)

    // 6. 根据状态机把 PWM 信号分配给对应的颜色引脚
    assign rgb1[0] = (color_state == 3'd0) ? pwm_active : pwm_idle; // 红
    assign rgb1[1] = (color_state == 3'd1) ? pwm_active : pwm_idle; // 绿
    assign rgb1[2] = (color_state == 3'd2) ? pwm_active : pwm_idle; // 蓝

endmodule