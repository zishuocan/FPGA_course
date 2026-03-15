//==============================================================================
// File Name    : basic_gates.v
// Description  : Basic logic gates implementation
//==============================================================================

`timescale 1ns/1ps

module basic_gates (
    input  wire a,
    input  wire b,
    output wire y_and,
    output wire y_or,
    output wire y_not,
    output wire y_nand,
    output wire y_nor,
    output wire y_xor,
    output wire y_xnor
);

    // 基本逻辑门实现
    assign y_and  = a & b;      // 与门
    assign y_or   = a | b;      // 或门
    assign y_not  = ~a;         // 非门
    assign y_nand = ~(a & b);   // 与非门
    assign y_nor  = ~(a | b);   // 或非门
    assign y_xor  = a ^ b;      // 异或门
    assign y_xnor = ~(a ^ b);   // 同或门

endmodule