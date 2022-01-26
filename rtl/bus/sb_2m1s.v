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

module sb_2m1s (
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
input           sb_arvalid_m1,
output          sb_arready_m1,
input   [31:0]  sb_araddr_m1,
// read data channel
output          sb_rvalid_m1,
input           sb_rready_m1,
output   [31:0] sb_rdata_m1,
// write channel
input           sb_wvalid_m1,
output          sb_wready_m1,
input   [31:0]  sb_waddr_m1,
input   [31:0]  sb_wdata_m1,
input   [3:0]   sb_wstrb_m1,
// write response channel
output          sb_bvalid_m1,
input           sb_bready_m1,
output          sb_bresp_m1,
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
input           sb_bresp_s0

);

reg       arflag;
reg       armst;
wire      ar_ok;
wire      r_ok;

assign    ar_ok = sb_arvalid_s0 & sb_arready_s0;
assign    r_ok  = sb_rvalid_s0  & sb_rready_s0;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    arflag  <=  1'b0;
    armst   <=  1'b0;
  end
  //else if(~arflag & ~ar_ok & ~r_ok) begin
  //  // do nothing
  //  arflag  <=  arflag;
  //  armst   <=  armst;
  //end
  else if(~arflag & ar_ok & ~r_ok) begin
    // set the full flag and record master number
    arflag  <=  1'b1;
    armst   <=  sb_arvalid_m1;
  end
  //else if(~arflag & ~ar_ok & r_ok) begin
  //  // this will never happen
  //  arflag  <=  arflag;
  //  armst   <=  armst;
  //end
  //else if(~arflag & ar_ok & r_ok) begin
  //  // this will never happen
  //  arflag  <=  arflag;
  //  armst   <=  armst;
  //end
  //else if(arflag & ~ar_ok & ~r_ok) begin
  //  // do nothing
  //  arflag  <=  arflag;
  //  armst   <=  armst;
  //end
  else if(arflag & ~ar_ok & r_ok) begin
    // clear the full flag
    arflag  <=  1'b0;
  //  armst   <=  armst;
  end
  //else if(arflag & ar_ok & ~r_ok) begin
  //  // this will never happen
  //  arflag  <=  arflag;
  //  armst   <=  armst;
  //end
  else if(arflag & ar_ok & r_ok) begin
    // full flag maintain and record new master number
  //  arflag  <=  arflag;
    armst   <=  sb_arvalid_m1;
  end
end

assign    sb_arvalid_s0   = (arflag & ~r_ok) ? 1'b0 : sb_arvalid_m1 ? sb_arvalid_m1 : sb_arvalid_m0;
assign    sb_araddr_s0    = sb_arvalid_m1 ? sb_araddr_m1  : sb_araddr_m0;
assign    sb_arready_m0   = (arflag & ~r_ok) ? 1'b0 : sb_arvalid_m1 ? 1'b0 : sb_arready_s0;
assign    sb_arready_m1   = (arflag & ~r_ok) ? 1'b0 : sb_arready_s0;

assign    sb_rvalid_m0       = armst ? 1'b0          : sb_rvalid_s0;
assign    sb_rvalid_m1       = armst ? sb_rvalid_s0  : 1'b0;
assign    sb_rready_s0       = armst ? sb_rready_m1  : sb_rready_m0;
assign    sb_rdata_m0        = sb_rdata_s0;
assign    sb_rdata_m1        = sb_rdata_s0;

//----------------------------------------------------------------------------------------------------------------

reg       wflag;
reg       wmst;
wire      w_ok;
wire      b_ok;

assign    w_ok  = sb_wvalid_s0 & sb_wready_s0;
assign    b_ok  = sb_bvalid_s0 & sb_bready_s0;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    wflag  <=  1'b0;
    wmst   <=  1'b0;
  end
  //else if(~wflag & ~w_ok & ~b_ok) begin
  //  // do nothing
  //  wflag  <=  wflag;
  //  wmst   <=  wmst;
  //end
  else if(~wflag & w_ok & ~b_ok) begin
    // set the full flag and record master number
    wflag  <=  1'b1;
    wmst   <=  sb_wvalid_m1;
  end
  //else if(~wflag & ~w_ok & b_ok) begin
  //  // this will never happen
  //  wflag  <=  wflag;
  //  wmst   <=  wmst;
  //end
  //else if(~wflag & w_ok & b_ok) begin
  //  // this will never happen
  //  wflag  <=  wflag;
  //  wmst   <=  wmst;
  //end
  //else if(wflag & ~w_ok & ~b_ok) begin
  //  // do nothing
  //  wflag  <=  wflag;
  //  wmst   <=  wmst;
  //end
  else if(wflag & ~w_ok & b_ok) begin
    // clear the full flag
    wflag  <=  1'b0;
  //  wmst   <=  wmst;
  end
  //else if(wflag & w_ok & ~b_ok) begin
  //  // this will never happen
  //  wflag  <=  wflag;
  //  wmst   <=  wmst;
  //end
  else if(wflag & w_ok & b_ok) begin
    // full flag maintain and record new master number
  //  wflag  <=  wflag;
    wmst   <=  sb_wvalid_m1;
  end
end

assign    sb_wvalid_s0   = (wflag & ~b_ok) ? 1'b0 : sb_wvalid_m1 ? sb_wvalid_m1 : sb_wvalid_m0;
assign    sb_waddr_s0    = sb_wvalid_m1 ? sb_waddr_m1  : sb_waddr_m0;
assign    sb_wdata_s0    = sb_wvalid_m1 ? sb_wdata_m1  : sb_wdata_m0;
assign    sb_wstrb_s0    = sb_wvalid_m1 ? sb_wstrb_m1  : sb_wstrb_m0;
assign    sb_wready_m0   = (wflag & ~b_ok) ? 1'b0 : sb_wvalid_m1 ? 1'b0 : sb_wready_s0;
assign    sb_wready_m1   = (wflag & ~b_ok) ? 1'b0 : sb_wready_s0;

assign    sb_bvalid_m0       = wmst ? 1'b0          : sb_bvalid_s0;
assign    sb_bvalid_m1       = wmst ? sb_bvalid_s0  : 1'b0;
assign    sb_bready_s0       = wmst ? sb_bready_m1  : sb_bready_m0;
assign    sb_bresp_m0        = sb_bresp_s0;
assign    sb_bresp_m1        = sb_bresp_s0;

endmodule


