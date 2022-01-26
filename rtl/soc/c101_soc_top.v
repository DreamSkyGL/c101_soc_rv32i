//-----------------------------------------------------------------------------
//   Copyright 2022 GanLing, 1577959692@qq.com
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
//-----------------------------------------------------------------------------

module c101_soc_top(

  input           clk,
  input           rst_n_async,

  input   [15:0]  gpioa_i,
  input   [15:0]  gpiob_i,
  output  [15:0]  gpioa_o,
  output  [15:0]  gpiob_o
);


wire          rst_n;
//--------------------------------------------
// master 0
//--------------------------------------------
// read address channel
wire          sb_arvalid_m0;
wire          sb_arready_m0;
wire  [31:0]  sb_araddr_m0;
// read data channel
wire          sb_rvalid_m0;
wire          sb_rready_m0;
wire   [31:0] sb_rdata_m0;
// write channel
wire          sb_wvalid_m0;
wire          sb_wready_m0;
wire  [31:0]  sb_waddr_m0;
wire  [31:0]  sb_wdata_m0;
wire  [3:0]   sb_wstrb_m0;
// write response channel
wire          sb_bvalid_m0;
wire          sb_bready_m0;
wire          sb_bresp_m0;
//--------------------------------------------
// master 1
//--------------------------------------------
// read address channel
wire         sb_arvalid_m1;
wire         sb_arready_m1;
wire [31:0]  sb_araddr_m1;
// read data channel
wire         sb_rvalid_m1;
wire         sb_rready_m1;
wire [31:0]  sb_rdata_m1;
// write channel
wire         sb_wvalid_m1;
wire         sb_wready_m1;
wire [31:0]  sb_waddr_m1;
wire [31:0]  sb_wdata_m1;
wire [3:0]   sb_wstrb_m1;
// write response channel
wire         sb_bvalid_m1;
wire         sb_bready_m1;
wire         sb_bresp_m1;
//--------------------------------------------
// slave 0
//--------------------------------------------
// read address channel
wire          sb_arvalid_s0;
wire          sb_arready_s0;
wire  [31:0]  sb_araddr_s0;
// read data channel
wire          sb_rvalid_s0;
wire          sb_rready_s0;
wire  [31:0]  sb_rdata_s0;
// write channel
wire          sb_wvalid_s0;
wire          sb_wready_s0;
wire  [31:0]  sb_waddr_s0;
wire  [31:0]  sb_wdata_s0;
wire  [3:0]   sb_wstrb_s0;
// write response channel
wire          sb_bvalid_s0;
wire          sb_bready_s0;
wire          sb_bresp_s0;
//--------------------------------------------
// slave 1
//--------------------------------------------
// read address channel
wire          sb_arvalid_s1;
wire          sb_arready_s1;
wire  [31:0]  sb_araddr_s1;
// read data channel
wire          sb_rvalid_s1;
wire          sb_rready_s1;
wire  [31:0]  sb_rdata_s1;
// write channel
wire          sb_wvalid_s1;
wire          sb_wready_s1;
wire  [31:0]  sb_waddr_s1;
wire  [31:0]  sb_wdata_s1;
wire  [3:0]   sb_wstrb_s1;
// write response channel
wire          sb_bvalid_s1;
wire          sb_bready_s1;
wire          sb_bresp_s1;
//--------------------------------------------
// slave 2
//--------------------------------------------
// read address channel
wire          sb_arvalid_s2;
wire          sb_arready_s2;
wire  [31:0]  sb_araddr_s2;
// read data channel
wire          sb_rvalid_s2;
wire          sb_rready_s2;
wire  [31:0]  sb_rdata_s2;
// write channel
wire          sb_wvalid_s2;
wire          sb_wready_s2;
wire  [31:0]  sb_waddr_s2;
wire  [31:0]  sb_wdata_s2;
wire  [3:0]   sb_wstrb_s2;
// write response channel
wire          sb_bvalid_s2;
wire          sb_bready_s2;
wire          sb_bresp_s2;
//--------------------------------------------
// slave 3
//--------------------------------------------
// read address channel
wire          sb_arvalid_s3;
wire          sb_arready_s3;
wire  [31:0]  sb_araddr_s3;
// read data channel
wire          sb_rvalid_s3;
wire          sb_rready_s3;
wire  [31:0]  sb_rdata_s3;
// write channel
wire          sb_wvalid_s3;
wire          sb_wready_s3;
wire  [31:0]  sb_waddr_s3;
wire  [31:0]  sb_wdata_s3;
wire  [3:0]   sb_wstrb_s3;
// write response channel
wire          sb_bvalid_s3;
wire          sb_bready_s3;
wire          sb_bresp_s3;






rst_n_sync u_rst_n_sync(
  .clk(clk),
  .rst_n_async(rst_n_async),
  .rst_n_sync(rst_n)
);

bus u_bus(
  .clk(clk),
  .rst_n(rst_n),
  .sb_arvalid_m0(sb_arvalid_m0),
  .sb_arready_m0(sb_arready_m0),
  .sb_araddr_m0(sb_araddr_m0),
  .sb_rvalid_m0(sb_rvalid_m0),
  .sb_rready_m0(sb_rready_m0),
  .sb_rdata_m0(sb_rdata_m0),
  .sb_wvalid_m0(sb_wvalid_m0),
  .sb_wready_m0(sb_wready_m0),
  .sb_waddr_m0(sb_waddr_m0),
  .sb_wdata_m0(sb_wdata_m0),
  .sb_wstrb_m0(sb_wstrb_m0),
  .sb_bvalid_m0(sb_bvalid_m0),
  .sb_bready_m0(sb_bready_m0),
  .sb_bresp_m0(sb_bresp_m0),
  .sb_arvalid_m1(sb_arvalid_m1),
  .sb_arready_m1(sb_arready_m1),
  .sb_araddr_m1(sb_araddr_m1),
  .sb_rvalid_m1(sb_rvalid_m1),
  .sb_rready_m1(sb_rready_m1),
  .sb_rdata_m1(sb_rdata_m1),
  .sb_wvalid_m1(sb_wvalid_m1),
  .sb_wready_m1(sb_wready_m1),
  .sb_waddr_m1(sb_waddr_m1),
  .sb_wdata_m1(sb_wdata_m1),
  .sb_wstrb_m1(sb_wstrb_m1),
  .sb_bvalid_m1(sb_bvalid_m1),
  .sb_bready_m1(sb_bready_m1),
  .sb_bresp_m1(sb_bresp_m1),
  .sb_arvalid_s0(sb_arvalid_s0),
  .sb_arready_s0(sb_arready_s0),
  .sb_araddr_s0(sb_araddr_s0),
  .sb_rvalid_s0(sb_rvalid_s0),
  .sb_rready_s0(sb_rready_s0),
  .sb_rdata_s0(sb_rdata_s0),
  .sb_wvalid_s0(sb_wvalid_s0),
  .sb_wready_s0(sb_wready_s0),
  .sb_waddr_s0(sb_waddr_s0),
  .sb_wdata_s0(sb_wdata_s0),
  .sb_wstrb_s0(sb_wstrb_s0),
  .sb_bvalid_s0(sb_bvalid_s0),
  .sb_bready_s0(sb_bready_s0),
  .sb_bresp_s0(sb_bresp_s0),
  .sb_arvalid_s1(sb_arvalid_s1),
  .sb_arready_s1(sb_arready_s1),
  .sb_araddr_s1(sb_araddr_s1),
  .sb_rvalid_s1(sb_rvalid_s1),
  .sb_rready_s1(sb_rready_s1),
  .sb_rdata_s1(sb_rdata_s1),
  .sb_wvalid_s1(sb_wvalid_s1),
  .sb_wready_s1(sb_wready_s1),
  .sb_waddr_s1(sb_waddr_s1),
  .sb_wdata_s1(sb_wdata_s1),
  .sb_wstrb_s1(sb_wstrb_s1),
  .sb_bvalid_s1(sb_bvalid_s1),
  .sb_bready_s1(sb_bready_s1),
  .sb_bresp_s1(sb_bresp_s1),
  .sb_arvalid_s2(sb_arvalid_s2),
  .sb_arready_s2(sb_arready_s2),
  .sb_araddr_s2(sb_araddr_s2),
  .sb_rvalid_s2(sb_rvalid_s2),
  .sb_rready_s2(sb_rready_s2),
  .sb_rdata_s2(sb_rdata_s2),
  .sb_wvalid_s2(sb_wvalid_s2),
  .sb_wready_s2(sb_wready_s2),
  .sb_waddr_s2(sb_waddr_s2),
  .sb_wdata_s2(sb_wdata_s2),
  .sb_wstrb_s2(sb_wstrb_s2),
  .sb_bvalid_s2(sb_bvalid_s2),
  .sb_bready_s2(sb_bready_s2),
  .sb_bresp_s2(sb_bresp_s2),
  .sb_arvalid_s3(sb_arvalid_s3),
  .sb_arready_s3(sb_arready_s3),
  .sb_araddr_s3(sb_araddr_s3),
  .sb_rvalid_s3(sb_rvalid_s3),
  .sb_rready_s3(sb_rready_s3),
  .sb_rdata_s3(sb_rdata_s3),
  .sb_wvalid_s3(sb_wvalid_s3),
  .sb_wready_s3(sb_wready_s3),
  .sb_waddr_s3(sb_waddr_s3),
  .sb_wdata_s3(sb_wdata_s3),
  .sb_wstrb_s3(sb_wstrb_s3),
  .sb_bvalid_s3(sb_bvalid_s3),
  .sb_bready_s3(sb_bready_s3),
  .sb_bresp_s3(sb_bresp_s3)
);




core_c1_top u_core_c1_top(

//--------------------------------------------
// master 0: ifidu instrucrtion fetch
//--------------------------------------------
// read address channel
.sb_arvalid_m0(sb_arvalid_m0),
.sb_arready_m0(sb_arready_m0),
.sb_araddr_m0(sb_araddr_m0),
// read data channel
.sb_rvalid_m0(sb_rvalid_m0),
.sb_rready_m0(sb_rready_m0),
.sb_rdata_m0(sb_rdata_m0),
// write channel
.sb_wvalid_m0(sb_wvalid_m0),
.sb_wready_m0(sb_wready_m0),
.sb_waddr_m0(sb_waddr_m0),
.sb_wdata_m0(sb_wdata_m0),
.sb_wstrb_m0(sb_wstrb_m0),
// write response
.sb_bvalid_m0(sb_bvalid_m0),
.sb_bready_m0(sb_bready_m0),
.sb_bresp_m0(sb_bresp_m0),

//--------------------------------------------
// master 1: memort load and store
//--------------------------------------------
// read address channel
.sb_arvalid_m1(sb_arvalid_m1),
.sb_arready_m1(sb_arready_m1),
.sb_araddr_m1(sb_araddr_m1),
// read data channel
.sb_rvalid_m1(sb_rvalid_m1),
.sb_rready_m1(sb_rready_m1),
.sb_rdata_m1(sb_rdata_m1),
// write channel
.sb_wvalid_m1(sb_wvalid_m1),
.sb_wready_m1(sb_wready_m1),
.sb_waddr_m1(sb_waddr_m1),
.sb_wdata_m1(sb_wdata_m1),
.sb_wstrb_m1(sb_wstrb_m1),
// write response
.sb_bvalid_m1(sb_bvalid_m1),
.sb_bready_m1(sb_bready_m1),
.sb_bresp_m1(sb_bresp_m1),

.plic_intr(1'b0),

.clk(clk),
.rst_n(rst_n)

);

ram u_imem (
// gloab signals
.sb_clk(clk),
.sb_rst_n(rst_n),
// read address channel
.sb_arvalid(sb_arvalid_s0),
.sb_arready(sb_arready_s0),
.sb_araddr(sb_araddr_s0),
// read data channel
.sb_rvalid(sb_rvalid_s0),
.sb_rready(sb_rready_s0),
.sb_rdata(sb_rdata_s0),
// write channel
.sb_wvalid(sb_wvalid_s0),
.sb_wready(sb_wready_s0),
.sb_waddr(sb_waddr_s0),
.sb_wdata(sb_wdata_s0),
.sb_wstrb(sb_wstrb_s0),
// write response channel
.sb_bvalid(sb_bvalid_s0),
.sb_bready(sb_bready_s0),
.sb_bresp(sb_bresp_s0)
);


ram u_dmem (
// gloab signals
.sb_clk(clk),
.sb_rst_n(rst_n),
// read address channel
.sb_arvalid(sb_arvalid_s1),
.sb_arready(sb_arready_s1),
.sb_araddr(sb_araddr_s1),
// read data channel
.sb_rvalid(sb_rvalid_s1),
.sb_rready(sb_rready_s1),
.sb_rdata(sb_rdata_s1),
// write channel
.sb_wvalid(sb_wvalid_s1),
.sb_wready(sb_wready_s1),
.sb_waddr(sb_waddr_s1),
.sb_wdata(sb_wdata_s1),
.sb_wstrb(sb_wstrb_s1),
// write response channel
.sb_bvalid(sb_bvalid_s1),
.sb_bready(sb_bready_s1),
.sb_bresp(sb_bresp_s1)
);

gpio u_gpioa(
// gloab signals
.sb_clk(clk),
.sb_rst_n(rst_n),
// read address channel
.sb_arvalid(sb_arvalid_s2),
.sb_arready(sb_arready_s2),
.sb_araddr(sb_araddr_s2),
// read data channel
.sb_rvalid(sb_rvalid_s2),
.sb_rready(sb_rready_s2),
.sb_rdata(sb_rdata_s2),
// write channel
.sb_wvalid(sb_wvalid_s2),
.sb_wready(sb_wready_s2),
.sb_waddr(sb_waddr_s2),
.sb_wdata(sb_wdata_s2),
.sb_wstrb(sb_wstrb_s2),
// write response channel
.sb_bvalid(sb_bvalid_s2),
.sb_bready(sb_bready_s2),
.sb_bresp(sb_bresp_s2),

.gpio_i(gpioa_i),
.gpio_o(gpioa_o)

);

gpio u_gpiob(
// gloab signals
.sb_clk(clk),
.sb_rst_n(rst_n),
// read address channel
.sb_arvalid(sb_arvalid_s3),
.sb_arready(sb_arready_s3),
.sb_araddr(sb_araddr_s3),
// read data channel
.sb_rvalid(sb_rvalid_s3),
.sb_rready(sb_rready_s3),
.sb_rdata(sb_rdata_s3),
// write channel
.sb_wvalid(sb_wvalid_s3),
.sb_wready(sb_wready_s3),
.sb_waddr(sb_waddr_s3),
.sb_wdata(sb_wdata_s3),
.sb_wstrb(sb_wstrb_s3),
// write response channel
.sb_bvalid(sb_bvalid_s3),
.sb_bready(sb_bready_s3),
.sb_bresp(sb_bresp_s3),

.gpio_i(gpiob_i),
.gpio_o(gpiob_o)

);


endmodule

