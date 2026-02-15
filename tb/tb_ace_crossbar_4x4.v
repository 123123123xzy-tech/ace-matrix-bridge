`timescale 1ns/1ps

module tb_ace_crossbar_4x4;
    localparam integer N = 4;
    localparam integer DEST_W = 2;
    localparam integer ADDR_W = 32;
    localparam integer DATA_W = 64;
    localparam integer RESP_W = 2;
    localparam integer SNOOP_W = 16;

    reg clk;
    reg rst_n;

    reg  [N-1:0] mst_aw_valid;
    wire [N-1:0] mst_aw_ready;
    reg  [N*DEST_W-1:0] mst_aw_dest;
    reg  [N*ADDR_W-1:0] mst_aw_addr;
    wire [N-1:0] slv_aw_valid;
    reg  [N-1:0] slv_aw_ready;
    wire [N*DEST_W-1:0] slv_aw_src;
    wire [N*ADDR_W-1:0] slv_aw_addr;

    reg  [N-1:0] mst_w_valid;
    wire [N-1:0] mst_w_ready;
    reg  [N*DEST_W-1:0] mst_w_dest;
    reg  [N*DATA_W-1:0] mst_w_data;
    wire [N-1:0] slv_w_valid;
    reg  [N-1:0] slv_w_ready;
    wire [N*DEST_W-1:0] slv_w_src;
    wire [N*DATA_W-1:0] slv_w_data;

    reg  [N-1:0] mst_ar_valid;
    wire [N-1:0] mst_ar_ready;
    reg  [N*DEST_W-1:0] mst_ar_dest;
    reg  [N*ADDR_W-1:0] mst_ar_addr;
    wire [N-1:0] slv_ar_valid;
    reg  [N-1:0] slv_ar_ready;
    wire [N*DEST_W-1:0] slv_ar_src;
    wire [N*ADDR_W-1:0] slv_ar_addr;

    reg  [N-1:0] slv_r_valid;
    wire [N-1:0] slv_r_ready;
    reg  [N*DEST_W-1:0] slv_r_dest;
    reg  [N*(DATA_W+RESP_W)-1:0] slv_r_payload;
    wire [N-1:0] mst_r_valid;
    reg  [N-1:0] mst_r_ready;
    wire [N*DEST_W-1:0] mst_r_src;
    wire [N*(DATA_W+RESP_W)-1:0] mst_r_payload;

    reg  [N-1:0] slv_b_valid;
    wire [N-1:0] slv_b_ready;
    reg  [N*DEST_W-1:0] slv_b_dest;
    reg  [N*RESP_W-1:0] slv_b_payload;
    wire [N-1:0] mst_b_valid;
    reg  [N-1:0] mst_b_ready;
    wire [N*DEST_W-1:0] mst_b_src;
    wire [N*RESP_W-1:0] mst_b_payload;

    reg  [N-1:0] slv_snp_req_valid;
    wire [N-1:0] slv_snp_req_ready;
    reg  [N*DEST_W-1:0] slv_snp_req_dest;
    reg  [N*SNOOP_W-1:0] slv_snp_req_payload;
    wire [N-1:0] mst_snp_req_valid;
    reg  [N-1:0] mst_snp_req_ready;
    wire [N*DEST_W-1:0] mst_snp_req_src;
    wire [N*SNOOP_W-1:0] mst_snp_req_payload;

    reg  [N-1:0] mst_snp_resp_valid;
    wire [N-1:0] mst_snp_resp_ready;
    reg  [N*DEST_W-1:0] mst_snp_resp_dest;
    reg  [N*SNOOP_W-1:0] mst_snp_resp_payload;
    wire [N-1:0] slv_snp_resp_valid;
    reg  [N-1:0] slv_snp_resp_ready;
    wire [N*DEST_W-1:0] slv_snp_resp_src;
    wire [N*SNOOP_W-1:0] slv_snp_resp_payload;

    integer cyc;

    ace_crossbar_4x4 #(
        .N(N), .DEST_W(DEST_W), .ADDR_W(ADDR_W), .DATA_W(DATA_W), .RESP_W(RESP_W), .SNOOP_W(SNOOP_W)
    ) dut (
        .clk(clk), .rst_n(rst_n),
        .mst_aw_valid(mst_aw_valid), .mst_aw_ready(mst_aw_ready), .mst_aw_dest(mst_aw_dest), .mst_aw_addr(mst_aw_addr),
        .slv_aw_valid(slv_aw_valid), .slv_aw_ready(slv_aw_ready), .slv_aw_src(slv_aw_src), .slv_aw_addr(slv_aw_addr),
        .mst_w_valid(mst_w_valid), .mst_w_ready(mst_w_ready), .mst_w_dest(mst_w_dest), .mst_w_data(mst_w_data),
        .slv_w_valid(slv_w_valid), .slv_w_ready(slv_w_ready), .slv_w_src(slv_w_src), .slv_w_data(slv_w_data),
        .mst_ar_valid(mst_ar_valid), .mst_ar_ready(mst_ar_ready), .mst_ar_dest(mst_ar_dest), .mst_ar_addr(mst_ar_addr),
        .slv_ar_valid(slv_ar_valid), .slv_ar_ready(slv_ar_ready), .slv_ar_src(slv_ar_src), .slv_ar_addr(slv_ar_addr),
        .slv_r_valid(slv_r_valid), .slv_r_ready(slv_r_ready), .slv_r_dest(slv_r_dest), .slv_r_payload(slv_r_payload),
        .mst_r_valid(mst_r_valid), .mst_r_ready(mst_r_ready), .mst_r_src(mst_r_src), .mst_r_payload(mst_r_payload),
        .slv_b_valid(slv_b_valid), .slv_b_ready(slv_b_ready), .slv_b_dest(slv_b_dest), .slv_b_payload(slv_b_payload),
        .mst_b_valid(mst_b_valid), .mst_b_ready(mst_b_ready), .mst_b_src(mst_b_src), .mst_b_payload(mst_b_payload),
        .slv_snp_req_valid(slv_snp_req_valid), .slv_snp_req_ready(slv_snp_req_ready), .slv_snp_req_dest(slv_snp_req_dest), .slv_snp_req_payload(slv_snp_req_payload),
        .mst_snp_req_valid(mst_snp_req_valid), .mst_snp_req_ready(mst_snp_req_ready), .mst_snp_req_src(mst_snp_req_src), .mst_snp_req_payload(mst_snp_req_payload),
        .mst_snp_resp_valid(mst_snp_resp_valid), .mst_snp_resp_ready(mst_snp_resp_ready), .mst_snp_resp_dest(mst_snp_resp_dest), .mst_snp_resp_payload(mst_snp_resp_payload),
        .slv_snp_resp_valid(slv_snp_resp_valid), .slv_snp_resp_ready(slv_snp_resp_ready), .slv_snp_resp_src(slv_snp_resp_src), .slv_snp_resp_payload(slv_snp_resp_payload)
    );

    always #5 clk = ~clk;

    task clear_inputs;
        begin
            mst_aw_valid = 0; mst_aw_dest = 0; mst_aw_addr = 0; slv_aw_ready = 0;
            mst_w_valid = 0; mst_w_dest = 0; mst_w_data = 0; slv_w_ready = 0;
            mst_ar_valid = 0; mst_ar_dest = 0; mst_ar_addr = 0; slv_ar_ready = 0;
            slv_r_valid = 0; slv_r_dest = 0; slv_r_payload = 0; mst_r_ready = 0;
            slv_b_valid = 0; slv_b_dest = 0; slv_b_payload = 0; mst_b_ready = 0;
            slv_snp_req_valid = 0; slv_snp_req_dest = 0; slv_snp_req_payload = 0; mst_snp_req_ready = 0;
            mst_snp_resp_valid = 0; mst_snp_resp_dest = 0; mst_snp_resp_payload = 0; slv_snp_resp_ready = 0;
        end
    endtask

    task expect_eq;
        input [31:0] got;
        input [31:0] exp;
        input [127:0] msg;
        begin
            if (got !== exp) begin
                $display("[FAIL] %s got=%0d exp=%0d @%0t", msg, got, exp, $time);
                $fatal(1);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        clear_inputs();
        repeat (4) @(posedge clk);
        rst_n = 1;
        @(posedge clk);

        // Case 1: AW arbitration (4 masters -> slave0), expect round-robin 0,1,2,3
        slv_aw_ready = 4'b0001;
        for (cyc = 0; cyc < N; cyc = cyc + 1) begin
            mst_aw_valid = 4'b1111;
            mst_aw_dest  = {2'd0,2'd0,2'd0,2'd0};
            mst_aw_addr  = {32'h3000_0003, 32'h3000_0002, 32'h3000_0001, 32'h3000_0000};
            @(posedge clk);
            expect_eq(slv_aw_valid[0], 1, "AW valid slave0");
            expect_eq(slv_aw_src[1:0], cyc[1:0], "AW RR src");
        end
        mst_aw_valid = 0;

        // Case 2: B arbitration (4 slaves -> master1), expect round-robin 0,1,2,3
        mst_b_ready = 4'b0010;
        for (cyc = 0; cyc < N; cyc = cyc + 1) begin
            slv_b_valid = 4'b1111;
            slv_b_dest  = {2'd1,2'd1,2'd1,2'd1};
            slv_b_payload = {2'b11,2'b10,2'b01,2'b00};
            @(posedge clk);
            expect_eq(mst_b_valid[1], 1, "B valid master1");
            expect_eq(mst_b_src[3:2], cyc[1:0], "B RR src");
        end
        slv_b_valid = 0;

        // Case 3: Snoop request arbitration (4 slaves -> master2), RR 0,1,2,3
        mst_snp_req_ready = 4'b0100;
        for (cyc = 0; cyc < N; cyc = cyc + 1) begin
            slv_snp_req_valid = 4'b1111;
            slv_snp_req_dest  = {2'd2,2'd2,2'd2,2'd2};
            slv_snp_req_payload = {16'h4003,16'h4002,16'h4001,16'h4000};
            @(posedge clk);
            expect_eq(mst_snp_req_valid[2], 1, "SNP req valid master2");
            expect_eq(mst_snp_req_src[5:4], cyc[1:0], "SNP req RR src");
        end
        slv_snp_req_valid = 0;

        // Case 4: Snoop response arbitration (4 masters -> slave3), RR 0,1,2,3
        slv_snp_resp_ready = 4'b1000;
        for (cyc = 0; cyc < N; cyc = cyc + 1) begin
            mst_snp_resp_valid = 4'b1111;
            mst_snp_resp_dest  = {2'd3,2'd3,2'd3,2'd3};
            mst_snp_resp_payload = {16'h5003,16'h5002,16'h5001,16'h5000};
            @(posedge clk);
            expect_eq(slv_snp_resp_valid[3], 1, "SNP resp valid slave3");
            expect_eq(slv_snp_resp_src[7:6], cyc[1:0], "SNP resp RR src");
        end

        $display("[PASS] all ACE crossbar 4x4 round-robin tests passed.");
        $finish;
    end
endmodule
