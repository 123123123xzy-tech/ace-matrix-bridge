module ace_channel_xbar_fwd #(
    parameter integer N = 4,
    parameter integer DEST_W = 2,
    parameter integer PAYLOAD_W = 32,
    parameter integer SRC_W = 2
) (
    input  wire                        clk,
    input  wire                        rst_n,

    input  wire [N-1:0]                s_valid,
    output wire [N-1:0]                s_ready,
    input  wire [N*DEST_W-1:0]         s_dest,
    input  wire [N*PAYLOAD_W-1:0]      s_payload,

    output wire [N-1:0]                m_valid,
    input  wire [N-1:0]                m_ready,
    output wire [N*PAYLOAD_W-1:0]      m_payload,
    output wire [N*SRC_W-1:0]          m_src
);

    wire [N-1:0] req_matrix [0:N-1];
    wire [N-1:0] grant_matrix [0:N-1];
    wire [N-1:0] grant_valid;
    wire [SRC_W-1:0] grant_idx [0:N-1];
    wire [N-1:0] advance;

    genvar i, j;

    generate
        for (j = 0; j < N; j = j + 1) begin : GEN_REQ
            for (i = 0; i < N; i = i + 1) begin : GEN_REQ_INNER
                assign req_matrix[j][i] = s_valid[i] && (s_dest[i*DEST_W +: DEST_W] == j[DEST_W-1:0]);
            end

            rr_arbiter #(
                .N(N),
                .PTR_W(SRC_W)
            ) u_rr_arbiter (
                .clk(clk),
                .rst_n(rst_n),
                .req(req_matrix[j]),
                .advance(advance[j]),
                .grant(grant_matrix[j]),
                .grant_valid(grant_valid[j]),
                .grant_idx(grant_idx[j])
            );

            assign m_valid[j] = grant_valid[j];
            assign m_src[j*SRC_W +: SRC_W] = grant_idx[j];
            assign advance[j] = m_valid[j] && m_ready[j];
        end
    endgenerate

    reg [PAYLOAD_W-1:0] payload_mux [0:N-1];
    integer x, y;

    always @(*) begin
        for (x = 0; x < N; x = x + 1) begin
            payload_mux[x] = {PAYLOAD_W{1'b0}};
            for (y = 0; y < N; y = y + 1) begin
                if (grant_matrix[x][y]) begin
                    payload_mux[x] = s_payload[y*PAYLOAD_W +: PAYLOAD_W];
                end
            end
        end
    end

    generate
        for (j = 0; j < N; j = j + 1) begin : GEN_OUT_ASSIGN
            assign m_payload[j*PAYLOAD_W +: PAYLOAD_W] = payload_mux[j];
        end

        for (i = 0; i < N; i = i + 1) begin : GEN_READY
            reg ready_r;
            integer dst;
            always @(*) begin
                ready_r = 1'b0;
                dst = s_dest[i*DEST_W +: DEST_W];
                if (grant_matrix[dst][i]) begin
                    ready_r = m_ready[dst];
                end
            end
            assign s_ready[i] = ready_r;
        end
    endgenerate

endmodule
