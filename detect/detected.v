module seq_detector (
    input wire clk,
    input wire rst_n,
    input wire din,
    output reg detected
);

    // 1. 状态编码 (Mealy 版本只需要 4 个状态)
    localparam S0 = 3'd0; // 初始态: 还没看到有效的
    localparam S1 = 3'd1; // 接收到 '1'
    localparam S2 = 3'd2; // 接收到 '10'
    localparam S3 = 3'd3; // 接收到 '101'

    // 定义当前状态和下一个状态的寄存器
    reg [2:0] current_state;
    reg [2:0] next_state;

    // ==============================================================
    // 【第一段】时序逻辑：负责状态的切换（每个时钟心跳跳一次）
    // ==============================================================
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_state <= S0; // 复位时回到初始态
        end else begin
            current_state <= next_state; // 否则前往下一个状态
        end
    end

    // ==============================================================
    // 【第二段】组合逻辑：负责查“状态转移路线图”（大脑思考下一步去哪）
    // ==============================================================
    always @(*) begin
        case (current_state)
            S0: next_state = (din == 1'b1) ? S1 : S0;
            
            S1: next_state = (din == 1'b0) ? S2 : S1; // 来0去S2(10)，来1继续留S1(1)
            
            S2: next_state = (din == 1'b1) ? S3 : S0; // 来1去S3(101)，来0全毁了回S0
            
            // Mealy 核心：在 S3 且输入为1时完成 1011 检测，下一状态按重叠规则回到 S1
            S3: next_state = (din == 1'b1) ? S1 : S2;
            
            default: next_state = S0;
        endcase
    end

    // ==============================================================
    // 【第三段】组合逻辑：负责输出结果
    // ==============================================================
    always @(*) begin
        // Mealy 输出取决于“当前状态 + 当前输入”
        detected = (current_state == S3 && din == 1'b1) ? 1'b1 : 1'b0;
    end

endmodule