//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.03 Education 
//Created Time: 2026-04-07 17:38:21
create_clock -name clk_100m -period 10 -waveform {0 5} [get_ports {clk_100m}]
create_clock -name tck_pad_i -period 10 -waveform {0 5} [get_ports {tck_pad_i}]
