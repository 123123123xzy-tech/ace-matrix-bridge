module ace_crossbar_4x4 #(
    parameter integer N = 4,
    parameter integer DEST_W = 2,
    parameter integer ADDR_W = 32,
    parameter integer DATA_W = 64,
    parameter integer RESP_W = 2,
    parameter integer SNOOP_W = 16
) (
    input  wire                      clk,
    input  wire                      rst_n,

    input  wire [N-1:0]              mst_aw_valid,
    output wire [N-1:0]              mst_aw_ready,
    input  wire [N*DEST_W-1:0]       mst_aw_dest,
    input  wire [N*ADDR_W-1:0]       mst_aw_addr,
    output wire [N-1:0]              slv_aw_valid,
    input  wire [N-1:0]              slv_aw_ready,
    output wire [N*DEST_W-1:0]       slv_aw_src,
    output wire [N*ADDR_W-1:0]       slv_aw_addr,

    input  wire [N-1:0]              mst_w_valid,
    output wire [N-1:0]              mst_w_ready,
    input  wire [N*DEST_W-1:0]       mst_w_dest,
    input  wire [N*DATA_W-1:0]       mst_w_data,
    output wire [N-1:0]              slv_w_valid,
    input  wire [N-1:0]              slv_w_ready,
    output wire [N*DEST_W-1:0]       slv_w_src,
    output wire [N*DATA_W-1:0]       slv_w_data,

    input  wire [N-1:0]              mst_ar_valid,
    output wire [N-1:0]              mst_ar_ready,
    input  wire [N*DEST_W-1:0]       mst_ar_dest,
    input  wire [N*ADDR_W-1:0]       mst_ar_addr,
    output wire [N-1:0]              slv_ar_valid,
    input  wire [N-1:0]              slv_ar_ready,
    output wire [N*DEST_W-1:0]       slv_ar_src,
    output wire [N*ADDR_W-1:0]       slv_ar_addr,

    input  wire [N-1:0]              slv_r_valid,
    output wire [N-1:0]              slv_r_ready,
    input  wire [N*DEST_W-1:0]       slv_r_dest,
    input  wire [N*(DATA_W+RESP_W)-1:0] slv_r_payload,
    output wire [N-1:0]              mst_r_valid,
    input  wire [N-1:0]              mst_r_ready,
    output wire [N*DEST_W-1:0]       mst_r_src,
    output wire [N*(DATA_W+RESP_W)-1:0] mst_r_payload,

    input  wire [N-1:0]              slv_b_valid,
    output wire [N-1:0]              slv_b_ready,
    input  wire [N*DEST_W-1:0]       slv_b_dest,
    input  wire [N*RESP_W-1:0]       slv_b_payload,
    output wire [N-1:0]              mst_b_valid,
    input  wire [N-1:0]              mst_b_ready,
    output wire [N*DEST_W-1:0]       mst_b_src,
    output wire [N*RESP_W-1:0]       mst_b_payload,

    input  wire [N-1:0]              slv_snp_req_valid,
    output wire [N-1:0]              slv_snp_req_ready,
    input  wire [N*DEST_W-1:0]       slv_snp_req_dest,
    input  wire [N*SNOOP_W-1:0]      slv_snp_req_payload,
    output wire [N-1:0]              mst_snp_req_valid,
    input  wire [N-1:0]              mst_snp_req_ready,
    output wire [N*DEST_W-1:0]       mst_snp_req_src,
    output wire [N*SNOOP_W-1:0]      mst_snp_req_payload,

    input  wire [N-1:0]              mst_snp_resp_valid,
    output wire [N-1:0]              mst_snp_resp_ready,
    input  wire [N*DEST_W-1:0]       mst_snp_resp_dest,
    input  wire [N*SNOOP_W-1:0]      mst_snp_resp_payload,
    output wire [N-1:0]              slv_snp_resp_valid,
    input  wire [N-1:0]              slv_snp_resp_ready,
    output wire [N*DEST_W-1:0]       slv_snp_resp_src,
    output wire [N*SNOOP_W-1:0]      slv_snp_resp_payload
);

    ace_channel_xbar_fwd #(.N(N), .DEST_W(DEST_W), .PAYLOAD_W(ADDR_W), .SRC_W(DEST_W)) u_aw (
        .clk(clk), .rst_n(rst_n),
        .s_valid(mst_aw_valid), .s_ready(mst_aw_ready), .s_dest(mst_aw_dest), .s_payload(mst_aw_addr),
        .m_valid(slv_aw_valid), .m_ready(slv_aw_ready), .m_payload(slv_aw_addr), .m_src(slv_aw_src)
    );

    ace_channel_xbar_fwd #(.N(N), .DEST_W(DEST_W), .PAYLOAD_W(DATA_W), .SRC_W(DEST_W)) u_w (
        .clk(clk), .rst_n(rst_n),
        .s_valid(mst_w_valid), .s_ready(mst_w_ready), .s_dest(mst_w_dest), .s_payload(mst_w_data),
        .m_valid(slv_w_valid), .m_ready(slv_w_ready), .m_payload(slv_w_data), .m_src(slv_w_src)
    );

    ace_channel_xbar_fwd #(.N(N), .DEST_W(DEST_W), .PAYLOAD_W(ADDR_W), .SRC_W(DEST_W)) u_ar (
        .clk(clk), .rst_n(rst_n),
        .s_valid(mst_ar_valid), .s_ready(mst_ar_ready), .s_dest(mst_ar_dest), .s_payload(mst_ar_addr),
        .m_valid(slv_ar_valid), .m_ready(slv_ar_ready), .m_payload(slv_ar_addr), .m_src(slv_ar_src)
    );

    ace_channel_xbar_rev #(.N(N), .DEST_W(DEST_W), .PAYLOAD_W(DATA_W+RESP_W), .SRC_W(DEST_W)) u_r (
        .clk(clk), .rst_n(rst_n),
        .s_valid(slv_r_valid), .s_ready(slv_r_ready), .s_dest(slv_r_dest), .s_payload(slv_r_payload),
        .m_valid(mst_r_valid), .m_ready(mst_r_ready), .m_payload(mst_r_payload), .m_src(mst_r_src)
    );

    ace_channel_xbar_rev #(.N(N), .DEST_W(DEST_W), .PAYLOAD_W(RESP_W), .SRC_W(DEST_W)) u_b (
        .clk(clk), .rst_n(rst_n),
        .s_valid(slv_b_valid), .s_ready(slv_b_ready), .s_dest(slv_b_dest), .s_payload(slv_b_payload),
        .m_valid(mst_b_valid), .m_ready(mst_b_ready), .m_payload(mst_b_payload), .m_src(mst_b_src)
    );

    ace_channel_xbar_rev #(.N(N), .DEST_W(DEST_W), .PAYLOAD_W(SNOOP_W), .SRC_W(DEST_W)) u_snp_req (
        .clk(clk), .rst_n(rst_n),
        .s_valid(slv_snp_req_valid), .s_ready(slv_snp_req_ready), .s_dest(slv_snp_req_dest), .s_payload(slv_snp_req_payload),
        .m_valid(mst_snp_req_valid), .m_ready(mst_snp_req_ready), .m_payload(mst_snp_req_payload), .m_src(mst_snp_req_src)
    );

    ace_channel_xbar_fwd #(.N(N), .DEST_W(DEST_W), .PAYLOAD_W(SNOOP_W), .SRC_W(DEST_W)) u_snp_resp (
        .clk(clk), .rst_n(rst_n),
        .s_valid(mst_snp_resp_valid), .s_ready(mst_snp_resp_ready), .s_dest(mst_snp_resp_dest), .s_payload(mst_snp_resp_payload),
        .m_valid(slv_snp_resp_valid), .m_ready(slv_snp_resp_ready), .m_payload(slv_snp_resp_payload), .m_src(slv_snp_resp_src)
    );

endmodule
