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

module sb_1m4s (
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

reg       arflag;
reg [3:0] arslv;
wire      arslv0;
wire      arslv1;
wire      arslv2;
wire      arslv3;
wire      ar_ok;
wire      r_ok;

assign    arslv0  = sb_araddr_m0[31:30] ==  2'b01;
assign    arslv1  = sb_araddr_m0[31:30] ==  2'b00;
assign    arslv2  = sb_araddr_m0[31:30] ==  2'b10;
assign    arslv3  = sb_araddr_m0[31:30] ==  2'b11;

assign    ar_ok = sb_arvalid_m0 & sb_arready_m0;
assign    r_ok  = sb_rvalid_m0  & sb_rready_m0;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    arflag  <=  1'b0;
    arslv   <=  4'b0;
  end
  //else if(~arflag & ~ar_ok & ~r_ok) begin
  //  // do nothing
  //  arflag  <=  arflag;
  //  arslv   <=  arslv;
  //end
  else if(~arflag & ar_ok & ~r_ok) begin
    // set the full flag and record slave number
    arflag  <=  1'b1;
    arslv   <=  {sb_arvalid_s3,sb_arvalid_s2,sb_arvalid_s1,sb_arvalid_s0};
  end
  //else if(~arflag & ~ar_ok & r_ok) begin
  //  // this will never happen
  //  arflag  <=  arflag;
  //  arslv   <=  arslv;
  //end
  //else if(~arflag & ar_ok & r_ok) begin
  //  // this will never happen
  //  arflag  <=  arflag;
  //  arslv   <=  arslv;
  //end
  //else if(arflag & ~ar_ok & ~r_ok) begin
  //  // do nothing
  //  arflag  <=  arflag;
  //  arslv   <=  arslv;
  //end
  else if(arflag & ~ar_ok & r_ok) begin
    // clear the full flag
    arflag  <=  1'b0;
  //  arslv   <=  arslv;
  end
  //else if(arflag & ar_ok & ~r_ok) begin
  //  // this will never happen
  //  arflag  <=  arflag;
  //  arslv   <=  arslv;
  //end
  else if(arflag & ar_ok & r_ok) begin
    // full flag maintain and record new slave number
  //  arflag  <=  arflag;
    arslv   <=  {sb_arvalid_s3,sb_arvalid_s2,sb_arvalid_s1,sb_arvalid_s0};
  end
end

assign    sb_arvalid_s0   = (arflag & ~r_ok) ? 1'b0 : arslv0 ? sb_arvalid_m0 : 1'b0;
assign    sb_arvalid_s1   = (arflag & ~r_ok) ? 1'b0 : arslv1 ? sb_arvalid_m0 : 1'b0;
assign    sb_arvalid_s2   = (arflag & ~r_ok) ? 1'b0 : arslv2 ? sb_arvalid_m0 : 1'b0;
assign    sb_arvalid_s3   = (arflag & ~r_ok) ? 1'b0 : arslv3 ? sb_arvalid_m0 : 1'b0;
assign    sb_araddr_s0    = sb_araddr_m0;
assign    sb_araddr_s1    = sb_araddr_m0;
assign    sb_araddr_s2    = sb_araddr_m0;
assign    sb_araddr_s3    = sb_araddr_m0;
assign    sb_arready_m0   = (arflag & ~r_ok) ? 1'b0 : (|({arslv3,arslv2,arslv1,arslv0} & {sb_arready_s3,sb_arready_s2,sb_arready_s1,sb_arready_s0}));

assign    sb_rvalid_m0      = |(arslv & {sb_rvalid_s3,sb_rvalid_s2,sb_rvalid_s1,sb_rvalid_s0});
assign    sb_rready_s0      = arslv[0] ? sb_rready_m0 : 1'b0;
assign    sb_rready_s1      = arslv[1] ? sb_rready_m0 : 1'b0;
assign    sb_rready_s2      = arslv[2] ? sb_rready_m0 : 1'b0;
assign    sb_rready_s3      = arslv[3] ? sb_rready_m0 : 1'b0;
assign    sb_rdata_m0       = ({32{arslv[3]}} & sb_rdata_s3)
                            | ({32{arslv[2]}} & sb_rdata_s2)
                            | ({32{arslv[1]}} & sb_rdata_s1)
                            | ({32{arslv[0]}} & sb_rdata_s0);

//-------------------------------------------------------------------------------------------------------------------------------------------------

reg       wflag;
reg [3:0] wslv;
wire      wslv0;
wire      wslv1;
wire      wslv2;
wire      wslv3;
wire      w_ok;
wire      b_ok;

assign    wslv0  = sb_waddr_m0[31:30] ==  2'b01;
assign    wslv1  = sb_waddr_m0[31:30] ==  2'b00;
assign    wslv2  = sb_waddr_m0[31:30] ==  2'b10;
assign    wslv3  = sb_waddr_m0[31:30] ==  2'b11;

assign    w_ok  = sb_wvalid_m0 & sb_wready_m0;
assign    b_ok  = sb_bvalid_m0 & sb_bready_m0;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    wflag  <=  1'b0;
    wslv   <=  4'b0;
  end
  //else if(~wflag & ~w_ok & ~b_ok) begin
  //  // do nothing
  //  wflag  <=  wflag;
  //  wslv   <=  wslv;
  //end
  else if(~wflag & w_ok & ~b_ok) begin
    // set the full flag and record slave number
    wflag  <=  1'b1;
    wslv   <=  {sb_wvalid_s3,sb_wvalid_s2,sb_wvalid_s1,sb_wvalid_s0};
  end
  //else if(~wflag & ~w_ok & b_ok) begin
  //  // this will never happen
  //  wflag  <=  wflag;
  //  wslv   <=  wslv;
  //end
  //else if(~wflag & w_ok & b_ok) begin
  //  // this will never happen
  //  wflag  <=  wflag;
  //  wslv   <=  wslv;
  //end
  //else if(wflag & ~w_ok & ~b_ok) begin
  //  // do nothing
  //  wflag  <=  wflag;
  //  wslv   <=  wslv;
  //end
  else if(wflag & ~w_ok & b_ok) begin
    // clear the full flag
    wflag  <=  1'b0;
  //  wslv   <=  wslv;
  end
  //else if(wflag & w_ok & ~b_ok) begin
  //  // this will never happen
  //  wflag  <=  wflag;
  //  wslv   <=  wslv;
  //end
  else if(wflag & w_ok & b_ok) begin
    // full flag maintain and record new slave number
  //  wflag  <=  wflag;
    wslv   <=  {sb_wvalid_s3,sb_wvalid_s2,sb_wvalid_s1,sb_wvalid_s0};
  end
end

assign    sb_wvalid_s0   = (wflag & ~b_ok) ? 1'b0 : wslv0 ? sb_wvalid_m0 : 1'b0;
assign    sb_wvalid_s1   = (wflag & ~b_ok) ? 1'b0 : wslv1 ? sb_wvalid_m0 : 1'b0;
assign    sb_wvalid_s2   = (wflag & ~b_ok) ? 1'b0 : wslv2 ? sb_wvalid_m0 : 1'b0;
assign    sb_wvalid_s3   = (wflag & ~b_ok) ? 1'b0 : wslv3 ? sb_wvalid_m0 : 1'b0;
assign    sb_waddr_s0    = sb_waddr_m0;
assign    sb_waddr_s1    = sb_waddr_m0;
assign    sb_waddr_s2    = sb_waddr_m0;
assign    sb_waddr_s3    = sb_waddr_m0;
assign    sb_wdata_s0    = sb_wdata_m0;
assign    sb_wdata_s1    = sb_wdata_m0;
assign    sb_wdata_s2    = sb_wdata_m0;
assign    sb_wdata_s3    = sb_wdata_m0;
assign    sb_wstrb_s0    = sb_wstrb_m0;
assign    sb_wstrb_s1    = sb_wstrb_m0;
assign    sb_wstrb_s2    = sb_wstrb_m0;
assign    sb_wstrb_s3    = sb_wstrb_m0;
assign    sb_wready_m0   = (wflag & ~b_ok) ? 1'b0 : (|({wslv3,wslv2,wslv1,wslv0} & {sb_wready_s3,sb_wready_s2,sb_wready_s1,sb_wready_s0}));

assign    sb_bvalid_m0      = |(wslv & {sb_bvalid_s3,sb_bvalid_s2,sb_bvalid_s1,sb_bvalid_s0});
assign    sb_bready_s0      = wslv[0] ? sb_bready_m0 : 1'b0;
assign    sb_bready_s1      = wslv[1] ? sb_bready_m0 : 1'b0;
assign    sb_bready_s2      = wslv[2] ? sb_bready_m0 : 1'b0;
assign    sb_bready_s3      = wslv[3] ? sb_bready_m0 : 1'b0;
assign    sb_bresp_m0       = ({32{wslv[3]}} & sb_bresp_s3)
                            | ({32{wslv[2]}} & sb_bresp_s2)
                            | ({32{wslv[1]}} & sb_bresp_s1)
                            | ({32{wslv[0]}} & sb_bresp_s0);



endmodule


