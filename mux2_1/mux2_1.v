module mux2_1 (
    input wire in0,
    input wire in1,
    input wire sel,
    output wire out1,
    output reg out2,
    output wire out3
);
    assign out1=sel?in1:in0;

    always @(*)begin
        if(sel==1'b1)begin
            out2=in1;
        end else begin
            out2=in0;
        end
    end

    wire not_sel;
    wire and_0_out;
    wire and_1_out;
    not u_not(not_sel, sel);
    and u_and0(and_0_out, in0, not_sel);
    and u_and1(and_1_out, in1, sel);
    or u_or(out3, and_0_out, and_1_out);
    
endmodule