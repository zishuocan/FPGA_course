//==============================================================================
// File Name    : tb_basic_gates.v
// Description  : Testbench for basic_gates
//==============================================================================

`timescale 1ns/1ps

module tb_basic_gates;

    // 测试信号声明
    reg  a, b;
    wire y_and, y_or, y_not, y_nand, y_nor, y_xor, y_xnor;
    
    // 实例化待测模块
    basic_gates uut (
        .a(a),
        .b(b),
        .y_and(y_and),
        .y_or(y_or),
        .y_not(y_not),
        .y_nand(y_nand),
        .y_nor(y_nor),
        .y_xor(y_xor),
        .y_xnor(y_xnor)
    );
    
    // 生成VCD波形文件
    initial begin
        $dumpfile("basic_gates.vcd");
        $dumpvars(0, tb_basic_gates);
    end
    
    // 测试激励
    initial begin
        $display("===== Basic Gates Test =====");
        $display("Time\ta\tb\tAND\tOR\tNOT\tNAND\tNOR\tXOR\tXNOR");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b", 
                 $time, a, b, y_and, y_or, y_not, y_nand, y_nor, y_xor, y_xnor);
        
        // 遍历所有输入组合
        a = 0; b = 0; #10;
        a = 0; b = 1; #10;
        a = 1; b = 0; #10;
        a = 1; b = 1; #10;
        
        $display("===== Test Completed =====");
        $finish;
    end

endmodule