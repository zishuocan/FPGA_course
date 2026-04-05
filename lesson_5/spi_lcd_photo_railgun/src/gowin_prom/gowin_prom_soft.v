module Gowin_pROM (
    output reg [15:0] dout,
    input            clk,
    input            oce,
    input            ce,
    input            reset,
    input      [14:0] ad
);

localparam integer ROM_DEPTH = 20655;
reg [15:0] rom_mem [0:ROM_DEPTH-1];
integer i;

initial begin
    for (i = 0; i < ROM_DEPTH; i = i + 1) begin
        rom_mem[i] = 16'h0000;
    end
    $readmemh("src/gowin_prom/1_153x135.mem", rom_mem);
end

always @(posedge clk) begin
    if (reset) begin
        dout <= 16'h0000;
    end else if (ce && oce) begin
        if (ad < ROM_DEPTH) begin
            dout <= rom_mem[ad];
        end else begin
            dout <= 16'h0000;
        end
    end
end

endmodule
