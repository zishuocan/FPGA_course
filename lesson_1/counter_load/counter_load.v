module counter_load (
    input wire clk,
    input wire rst_n,
    input wire load,
    input wire enable,
    input wire [7:0] data_in,
    output reg [7:0] count
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 8'b0;
        end else if (load) begin
            count <= data_in;
        end else if (enable) begin
            count <= count + 1'b1;
        end
    end

endmodule