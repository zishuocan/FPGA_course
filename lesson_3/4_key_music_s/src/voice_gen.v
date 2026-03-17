/************************************
***********易思达FPGA实验*************            
**软    件：GOwin云源软件              
**项    目：蜂鸣器发声模块                      
**时    钟：50MHz                     
**板卡型号：GW1N-UV9EQ144C6I5          
*************************************/  
module  voice_gen(
    input                clk_50m ,//时钟输入
    input                rst_n   ,//复位输入
    input                start   ,//起始信号
    input        [2:0]   num1    ,//7个音色
    input        [1:0]   num2    ,//中高低调0：低   1：中   2：高
    output  reg          beep    ,//蜂鸣器
    output  reg  [7:0]   led      //输出led
    );
//参数定义
parameter   CNT_MAX  = 25'd25_000_000 ,//0.5s
            CNT_1KHZ = 25'd50_000     ;//1khz  1ms

//信号定义
// 中音各音符的半周期计数阈值（50MHz时钟，半周期 = 25_000_000 / 频率）
localparam TH_DO_MID = 95420;   // do  ~262Hz
localparam TH_RE_MID = 85034;   // re  ~294Hz
localparam TH_MI_MID = 75757;   // mi  ~330Hz
localparam TH_FA_MID = 71633;   // fa  ~349Hz
localparam TH_SO_MID = 63775;   // so  ~392Hz
localparam TH_LA_MID = 56818;   // la  ~440Hz
localparam TH_SI_MID = 50607;   // si  ~494Hz

reg [19:0] cnt;          // 方波周期计数器
reg [19:0] thresh;      // 当前音符对应的半周期计数阈值

// 根据 num1 和 num2 计算阈值
always @(*) begin
    case(num1)
        3'd1: begin // do
            case(num2)
                2'd0: thresh = TH_DO_MID * 2;      // 低音
                2'd1: thresh = TH_DO_MID;          // 中音
                2'd2: thresh = TH_DO_MID / 2;      // 高音
                default: thresh = 20'd0;
            endcase
        end
        3'd2: begin // re
            case(num2)
                2'd0: thresh = TH_RE_MID * 2;
                2'd1: thresh = TH_RE_MID;
                2'd2: thresh = TH_RE_MID / 2;
                default: thresh = 20'd0;
            endcase
        end
        3'd3: begin // mi
            case(num2)
                2'd0: thresh = TH_MI_MID * 2;
                2'd1: thresh = TH_MI_MID;
                2'd2: thresh = TH_MI_MID / 2;
                default: thresh = 20'd0;
            endcase
        end
        3'd4: begin // fa
            case(num2)
                2'd0: thresh = TH_FA_MID * 2;
                2'd1: thresh = TH_FA_MID;
                2'd2: thresh = TH_FA_MID / 2;
                default: thresh = 20'd0;
            endcase
        end
        3'd5: begin // so
            case(num2)
                2'd0: thresh = TH_SO_MID * 2;
                2'd1: thresh = TH_SO_MID;
                2'd2: thresh = TH_SO_MID / 2;
                default: thresh = 20'd0;
            endcase
        end
        3'd6: begin // la
            case(num2)
                2'd0: thresh = TH_LA_MID * 2;
                2'd1: thresh = TH_LA_MID;
                2'd2: thresh = TH_LA_MID / 2;
                default: thresh = 20'd0;
            endcase
        end
        3'd7: begin // si
            case(num2)
                2'd0: thresh = TH_SI_MID * 2;
                2'd1: thresh = TH_SI_MID;
                2'd2: thresh = TH_SI_MID / 2;
                default: thresh = 20'd0;
            endcase
        end
        default: thresh = 20'd0;  // num1=0 或其他，静音
    endcase
end

// 计数器与蜂鸣器输出
always @(posedge clk_50m or negedge rst_n) begin
    if (!rst_n) begin
        cnt <= 20'd0;
        beep <= 1'b0;
    end else if (!start) begin
        cnt <= 20'd0;
        beep <= 1'b0;
    end else begin
        if (thresh == 20'd0) begin  // 静音
            cnt <= 20'd0;
            beep <= 1'b0;
        end else begin
            if (cnt >= thresh - 1) begin
                cnt <= 20'd0;
                beep <= ~beep;
            end else begin
                cnt <= cnt + 1'b1;
            end
        end
    end
end

// LED 显示：低5位显示当前音符（num2[1:0], num1[2:0]），高3位固定为0
always @(*) begin
    led = {3'b0, num2, num1};
end

endmodule

