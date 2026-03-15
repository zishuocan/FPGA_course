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
    +-- led_s/
    |   +-- 1_led.gprj
    |   +-- src/
    +-- breather_led_t/
    |   +-- 1_breather_led.gprj
    |   +-- src/
    +-- rgb_led_t/
        +-- 1_rgb_led.gprj
        +-- src/
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

## 硬件与工具快照

- FPGA 目标器件系列：Gowin GW1N-9C。
- 工程文件中使用的封装型号：`GW1N-UV9EQ144C6/I5`。
- lesson_2 上板实验包含 Gowin 工程文件（`*.gprj`）与引脚约束文件（`F1_CST.cst`）。
- 板级设计时钟基准为 50 MHz（`clk_50m`）。

## 验证状态概览

- 仓库内所有实验均提供独立 testbench。
- testbench 默认支持生成 `.vcd` 波形文件，便于时序与信号行为观察。
- lesson_2 实验同时具备仿真与上板工程资源，便于与综合实现流程对齐。

## 后续扩展方向

- 增加更多算术与状态机相关实验，扩展边界场景覆盖。
- 补充 UART/SPI 等协议级小模块练习。
- 进一步参数化板级 Demo，沉淀可复用的通用模块。
