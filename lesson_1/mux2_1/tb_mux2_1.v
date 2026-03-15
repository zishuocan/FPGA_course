`timescale 1ns/1ps

module tb_mux2_1;

    reg in0;
    reg in1;
    reg sel;
    wire out1;
    wire out2;
    wire out3;

    mux2_1 uut (
        .in0(in0),
        .in1(in1),
        .sel(sel),
        .out1(out1),
        .out2(out2),
        .out3(out3)
    );

    initial begin
        $dumpfile("mux2_1.vcd");
        $dumpvars(0, tb_mux2_1);
        {sel,in1,in0} = 3'b000;
        #10 {sel,in1,in0} = 3'b001;
        #10 {sel,in1,in0} = 3'b010;
        #10 {sel,in1,in0} = 3'b011;
        #10 {sel,in1,in0} = 3'b100;
        #10 {sel,in1,in0} = 3'b101;
        #10 {sel,in1,in0} = 3'b110;
        #10 {sel,in1,in0} = 3'b111;
        #10 $finish;
    end

endmodule