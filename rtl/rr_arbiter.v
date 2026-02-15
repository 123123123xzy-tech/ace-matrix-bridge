module rr_arbiter #(
    parameter integer N = 4,
    parameter integer PTR_W = 2
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire [N-1:0]         req,
    input  wire                 advance,
    output reg  [N-1:0]         grant,
    output reg                  grant_valid,
    output reg  [PTR_W-1:0]     grant_idx
);

    reg [PTR_W-1:0] rr_ptr;
    integer k;
    integer idx;

    always @(*) begin
        grant       = {N{1'b0}};
        grant_valid = 1'b0;
        grant_idx   = {PTR_W{1'b0}};

        for (k = 0; k < N; k = k + 1) begin
            idx = rr_ptr + k;
            if (idx >= N) begin
                idx = idx - N;
            end
            if (!grant_valid && req[idx]) begin
                grant[idx]   = 1'b1;
                grant_valid  = 1'b1;
                grant_idx    = idx[PTR_W-1:0];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rr_ptr <= {PTR_W{1'b0}};
        end else if (advance && grant_valid) begin
            if (grant_idx == N-1) begin
                rr_ptr <= {PTR_W{1'b0}};
            end else begin
                rr_ptr <= grant_idx + 1'b1;
            end
        end
    end

endmodule
