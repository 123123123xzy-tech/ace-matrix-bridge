# 4x4 ACE Crossbar (Verilog)

本仓库实现了一个 **4x4 ACE crossbar**，采用模块化设计，支持：

- AW / W / AR 前向路由（Master -> Slave）
- R / B 反向路由（Slave -> Master）
- Snoop Request（Slave -> Master）
- Snoop Response（Master -> Slave）
- 每个目标端口独立 **Round-Robin 仲裁**

## 目录

- `rtl/rr_arbiter.v`：通用 RR 仲裁器
- `rtl/ace_channel_xbar_fwd.v`：前向通道复用/仲裁
- `rtl/ace_channel_xbar_rev.v`：反向通道复用/仲裁
- `rtl/ace_crossbar_4x4.v`：4x4 ACE crossbar 顶层
- `tb/tb_ace_crossbar_4x4.v`：testbench（包含 RR 轮询检查）

## 仿真

示例（Icarus Verilog）：

```bash
iverilog -g2012 -o simv tb/tb_ace_crossbar_4x4.v rtl/*.v
vvp simv
```

