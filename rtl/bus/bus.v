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


//------------------------------ 
// c101 bus module
// 2 master 4 slave
// 
// m0: ifidu instruction fetch
// m1: load/store instruction
// 
// s0: imem         0x0000_0000 - 0x3FFF_FFFF
// s1: dmem         0x4000_0000 - 0x7FFF_FFFF
// s2: peripheral   0x8000_0000 - 0xBFFF_FFFF
// s3: system       0xC000_0000 - 0xFFFF_FFFF
//------------------------------

module bus (
input           clk,
input           rst_n,
//--------------------------------------------
// master 0
//--------------------------------------------
// read address channel
input           sb_arvalid_m0,
output          sb_arready_m0,
input   [31:0]  sb_araddr_m0,
// read data channel
output          sb_rvalid_m0,
input           sb_rready_m0,
output   [31:0] sb_rdata_m0,
// write channel
input           sb_wvalid_m0,
output          sb_wready_m0,
input   [31:0]  sb_waddr_m0,
input   [31:0]  sb_wdata_m0,
input   [3:0]   sb_wstrb_m0,
// write response channel
output          sb_bvalid_m0,
input           sb_bready_m0,
output          sb_bresp_m0,
//--------------------------------------------
// master 1
//--------------------------------------------
// read address channel
input          sb_arvalid_m1,
output         sb_arready_m1,
input  [31:0]  sb_araddr_m1,
// read data channel
output         sb_rvalid_m1,
input          sb_rready_m1,
output [31:0]  sb_rdata_m1,
// write channel
input          sb_wvalid_m1,
output         sb_wready_m1,
input  [31:0]  sb_waddr_m1,
input  [31:0]  sb_wdata_m1,
input  [3:0]   sb_wstrb_m1,
// write response channel
output         sb_bvalid_m1,
input          sb_bready_m1,
output         sb_bresp_m1,
//--------------------------------------------
// slave 0
//--------------------------------------------
// read address channel
output          sb_arvalid_s0,
input           sb_arready_s0,
output  [31:0]  sb_araddr_s0,
// read data channel
input           sb_rvalid_s0,
output          sb_rready_s0,
input   [31:0]  sb_rdata_s0,
// write channel
output          sb_wvalid_s0,
input           sb_wready_s0,
output  [31:0]  sb_waddr_s0,
output  [31:0]  sb_wdata_s0,
output  [3:0]   sb_wstrb_s0,
// write response channel
input           sb_bvalid_s0,
output          sb_bready_s0,
input           sb_bresp_s0,
//--------------------------------------------
// slave 1
//--------------------------------------------
// read address channel
output          sb_arvalid_s1,
input           sb_arready_s1,
output  [31:0]  sb_araddr_s1,
// read data channel
input           sb_rvalid_s1,
output          sb_rready_s1,
input   [31:0]  sb_rdata_s1,
// write channel
output          sb_wvalid_s1,
input           sb_wready_s1,
output  [31:0]  sb_waddr_s1,
output  [31:0]  sb_wdata_s1,
output  [3:0]   sb_wstrb_s1,
// write response channel
input           sb_bvalid_s1,
output          sb_bready_s1,
input           sb_bresp_s1,
//--------------------------------------------
// slave 2
//--------------------------------------------
// read address channel
output          sb_arvalid_s2,
input           sb_arready_s2,
output  [31:0]  sb_araddr_s2,
// read data channel
input           sb_rvalid_s2,
output          sb_rready_s2,
input   [31:0]  sb_rdata_s2,
// write channel
output          sb_wvalid_s2,
input           sb_wready_s2,
output  [31:0]  sb_waddr_s2,
output  [31:0]  sb_wdata_s2,
output  [3:0]   sb_wstrb_s2,
// write response channel
input           sb_bvalid_s2,
output          sb_bready_s2,
input           sb_bresp_s2,
//--------------------------------------------
// slave 3
//--------------------------------------------
// read address channel
output          sb_arvalid_s3,
input           sb_arready_s3,
output  [31:0]  sb_araddr_s3,
// read data channel
input           sb_rvalid_s3,
output          sb_rready_s3,
input   [31:0]  sb_rdata_s3,
// write channel
output          sb_wvalid_s3,
input           sb_wready_s3,
output  [31:0]  sb_waddr_s3,
output  [31:0]  sb_wdata_s3,
output  [3:0]   sb_wstrb_s3,
// write response channel
input           sb_bvalid_s3,
output          sb_bready_s3,
input           sb_bresp_s3

);

wire          sb_arvalid_;
wire          sb_arready_;
wire  [31:0]  sb_araddr_;
// read data channel
wire          sb_rvalid_;
wire          sb_rready_;
wire  [31:0]  sb_rdata_;
// write channel
wire          sb_wvalid_;
wire          sb_wready_;
wire  [31:0]  sb_waddr_;
wire  [31:0]  sb_wdata_;
wire  [3:0]   sb_wstrb_;
// write response channel
wire          sb_bvalid_;
wire          sb_bready_;
wire          sb_bresp_;

wire          sb_arvalid__;
wire          sb_arready__;
wire  [31:0]  sb_araddr__;
// read data channel
wire          sb_rvalid__;
wire          sb_rready__;
wire  [31:0]  sb_rdata__;
// write channel
wire          sb_wvalid__;
wire          sb_wready__;
wire  [31:0]  sb_waddr__;
wire  [31:0]  sb_wdata__;
wire  [3:0]   sb_wstrb__;
// write response channel
wire          sb_bvalid__;
wire          sb_bready__;
wire          sb_bresp__;


sb_pipe u_sb_pipe(
  .clk(clk),
  .rst_n(rst_n),
  .sb_arvalid_m(sb_arvalid_m1),
  .sb_arready_m(sb_arready_m1),
  .sb_araddr_m(sb_araddr_m1),
  .sb_rvalid_m(sb_rvalid_m1),
  .sb_rready_m(sb_rready_m1),
  .sb_rdata_m(sb_rdata_m1),
  .sb_wvalid_m(sb_wvalid_m1),
  .sb_wready_m(sb_wready_m1),
  .sb_waddr_m(sb_waddr_m1),
  .sb_wdata_m(sb_wdata_m1),
  .sb_wstrb_m(sb_wstrb_m1),
  .sb_bvalid_m(sb_bvalid_m1),
  .sb_bready_m(sb_bready_m1),
  .sb_bresp_m(sb_bresp_m1),
  .sb_arvalid_s(sb_arvalid_),
  .sb_arready_s(sb_arready_),
  .sb_araddr_s(sb_araddr_),
  .sb_rvalid_s(sb_rvalid_),
  .sb_rready_s(sb_rready_),
  .sb_rdata_s(sb_rdata_),
  .sb_wvalid_s(sb_wvalid_),
  .sb_wready_s(sb_wready_),
  .sb_waddr_s(sb_waddr_),
  .sb_wdata_s(sb_wdata_),
  .sb_wstrb_s(sb_wstrb_),
  .sb_bvalid_s(sb_bvalid_),
  .sb_bready_s(sb_bready_),
  .sb_bresp_s(sb_bresp_)

);


sb_1m4s u_sb_1m4s(
  .clk(clk),
  .rst_n(rst_n),
  .sb_arvalid_m0(sb_arvalid_),
  .sb_arready_m0(sb_arready_),
  .sb_araddr_m0(sb_araddr_),
  .sb_rvalid_m0(sb_rvalid_),
  .sb_rready_m0(sb_rready_),
  .sb_rdata_m0(sb_rdata_),
  .sb_wvalid_m0(sb_wvalid_),
  .sb_wready_m0(sb_wready_),
  .sb_waddr_m0(sb_waddr_),
  .sb_wdata_m0(sb_wdata_),
  .sb_wstrb_m0(sb_wstrb_),
  .sb_bvalid_m0(sb_bvalid_),
  .sb_bready_m0(sb_bready_),
  .sb_bresp_m0(sb_bresp_),
  .sb_arvalid_s0(sb_arvalid__),
  .sb_arready_s0(sb_arready__),
  .sb_araddr_s0(sb_araddr__),
  .sb_rvalid_s0(sb_rvalid__),
  .sb_rready_s0(sb_rready__),
  .sb_rdata_s0(sb_rdata__),
  .sb_wvalid_s0(sb_wvalid__),
  .sb_wready_s0(sb_wready__),
  .sb_waddr_s0(sb_waddr__),
  .sb_wdata_s0(sb_wdata__),
  .sb_wstrb_s0(sb_wstrb__),
  .sb_bvalid_s0(sb_bvalid__),
  .sb_bready_s0(sb_bready__),
  .sb_bresp_s0(sb_bresp__),
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

sb_2m1s u_sb_2m1s(
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
  .sb_arvalid_m1(sb_arvalid__),
  .sb_arready_m1(sb_arready__),
  .sb_araddr_m1(sb_araddr__),
  .sb_rvalid_m1(sb_rvalid__),
  .sb_rready_m1(sb_rready__),
  .sb_rdata_m1(sb_rdata__),
  .sb_wvalid_m1(sb_wvalid__),
  .sb_wready_m1(sb_wready__),
  .sb_waddr_m1(sb_waddr__),
  .sb_wdata_m1(sb_wdata__),
  .sb_wstrb_m1(sb_wstrb__),
  .sb_bvalid_m1(sb_bvalid__),
  .sb_bready_m1(sb_bready__),
  .sb_bresp_m1(sb_bresp__),
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
  .sb_bresp_s0(sb_bresp_s0)

);








endmodule

