# FPGA Verilog 课程代码

本仓库用于展示 FPGA 实验课程足迹

## 仓库结构

```text
FPGA_github/
+-- lesson_1/
|   +-- adder/
|   +-- basic_gates/
|   +-- counter_4bit/
|   +-- detect/
|   +-- mux2_1/
|   +-- mux4_1/
+-- lesson_2/
|   +-- led_s/
|   +-- breather_led_t/
|   +-- rgb_led_t/
+-- lesson_3/
|   +-- 3_static_seg_s/
|   +-- 3_trends_seg_t/
|   +-- 4_key_music_s/
|   +-- 4_key_piano_s/
+-- lesson_4/
    +-- 5_uart_loop/
    +-- 5_uart_seg/
    +-- 6_uart_add/
    +-- 6_dht11_seg/
    +-- 6_dht11_uart/
```

## 实验索引

| 课程阶段 | 实验           | 核心内容                             | 路径                          | Testbench                |
| -------- | -------------- | ------------------------------------ | ----------------------------- | ------------------------ |
| lesson_1 | adder          | 半加器与全加器的层次化组合           | `lesson_1/adder`              | 有 (`tb_add.v`)          |
| lesson_1 | basic_gates    | 与/或/非/与非/或非/异或/同或逻辑验证 | `lesson_1/basic_gates`        | 有 (`tb_basic_gates.v`)  |
| lesson_1 | counter_4bit   | 带使能与复位的 4 位同步计数器        | `lesson_1/counter_4bit`       | 有 (`tb_counter_4bit.v`) |
| lesson_1 | detect         | 基于 Mealy FSM 的 `1011` 序列检测    | `lesson_1/detect`             | 有 (`tb_detected.v`)     |
| lesson_1 | mux2_1         | 2 选 1 多路选择器的多种实现方式      | `lesson_1/mux2_1`             | 有 (`tb_mux2_1.v`)       |
| lesson_1 | mux4_1         | 4 选 1 多路选择器与选择信号路由      | `lesson_1/mux4_1`             | 有 (`tb_mux4_1.v`)       |
| lesson_2 | led_s          | LED 流水灯控制                       | `lesson_2/led_s/src`          | 有 (`tb_water_led.v`)    |
| lesson_2 | breather_led_t | 基于 PWM 的呼吸灯效果                | `lesson_2/breather_led_t/src` | 有 (`tb_breather_led.v`) |
| lesson_2 | rgb_led_t      | RGB 呼吸与颜色状态切换               | `lesson_2/rgb_led_t/src`      | 有 (`tb_rgb_led.v`)      |
| lesson_3 | 3_static_seg_s | 静态数码管显示                       | `lesson_3/3_static_seg_s/src` | 无                       |
| lesson_3 | 3_trends_seg_t | 动态数码管扫描显示                   | `lesson_3/3_trends_seg_t/src` | 无                       |
| lesson_3 | 4_key_music_s  | 按键音乐输出                         | `lesson_3/4_key_music_s/src`  | 有 (`key7_filter_tb.v`)  |
| lesson_3 | 4_key_piano_s  | 按键钢琴与音调控制                   | `lesson_3/4_key_piano_s/src`  | 有 (`top_tb.v`)          |
| lesson_4 | 5_uart_loop    | UART 回环通信                        | `lesson_4/5_uart_loop/src`    | 有 (`uart_tb.v`)         |
| lesson_4 | 5_uart_seg     | UART 接收与数码管显示                | `lesson_4/5_uart_seg/src`     | 有 (`top_tb.v`)          |
| lesson_4 | 6_uart_add     | UART 数据加法处理                    | `lesson_4/6_uart_add/src`     | 有 (`uart_tb.v`)         |
| lesson_4 | 6_dht11_seg    | DHT11 采集与数码管显示               | `lesson_4/6_dht11_seg/src`    | 有 (`key7_filter_tb.v`)  |
| lesson_4 | 6_dht11_uart   | DHT11 采集与 UART 发送               | `lesson_4/6_dht11_uart/src`   | 有 (`data_ctrl_tb.v`)    |

## 硬件与工具快照

- FPGA 目标器件系列：Gowin GW1N-9C。
- 工程文件中使用的封装型号：`GW1N-UV9EQ144C6/I5`。
- lesson_2 ~ lesson_4 上板实验包含 Gowin 工程文件（`*.gprj`）与引脚约束文件（`F1_CST.cst`）。
- 板级设计时钟基准为 50 MHz（`clk_50m`）。

## 验证状态概览

- 仓库内大部分实验提供独立 testbench（见实验索引）。
- 已提供的 testbench 默认支持生成 `.vcd` 波形文件，便于时序与信号行为观察。
- lesson_2 ~ lesson_4 实验均具备上板工程资源，便于与综合实现流程对齐。

## 后续扩展方向

- 增加更多算术与状态机相关实验，扩展边界场景覆盖。
- 补充 UART/SPI 等协议级小模块练习。
- 进一步参数化板级 Demo，沉淀可复用的通用模块。
