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

module sb_pipe (
input           clk,
input           rst_n,
//--------------------------------------------
// master
//--------------------------------------------
// read address channel
input           sb_arvalid_m,
output          sb_arready_m,
input   [31:0]  sb_araddr_m,
// read data channel
output          sb_rvalid_m,
input           sb_rready_m,
output   [31:0] sb_rdata_m,
// write channel
input           sb_wvalid_m,
output          sb_wready_m,
input   [31:0]  sb_waddr_m,
input   [31:0]  sb_wdata_m,
input   [3:0]   sb_wstrb_m,
// write response channel
output          sb_bvalid_m,
input           sb_bready_m,
output          sb_bresp_m,
//--------------------------------------------
// slave
//--------------------------------------------
// read address channel
output          sb_arvalid_s,
input           sb_arready_s,
output  [31:0]  sb_araddr_s,
// read data channel
input           sb_rvalid_s,
output          sb_rready_s,
input   [31:0]  sb_rdata_s,
// write channel
output          sb_wvalid_s,
input           sb_wready_s,
output  [31:0]  sb_waddr_s,
output  [31:0]  sb_wdata_s,
output  [3:0]   sb_wstrb_s,
// write response channel
input           sb_bvalid_s,
output          sb_bready_s,
input           sb_bresp_s

);

// read address channel
reg           arflag_r;
reg           arvalid_r;
reg   [31:0]  araddr_r;

assign  sb_arready_m  = ~arflag_r | sb_arready_s;
assign  sb_arvalid_s  = arvalid_r;
assign  sb_araddr_s   = araddr_r;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    arflag_r  <=  1'b0;
  end
  else if (sb_arvalid_m & sb_arready_m) begin
    arflag_r  <=  1'b1;
  end
  else if(sb_arready_s & ~sb_arvalid_m) begin
    arflag_r  <=  1'b0;
  end
end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    arvalid_r <=  1'b0;
    araddr_r  <=  32'b0;
  end
  else if (sb_arready_m) begin
    arvalid_r <=  sb_arvalid_m;
    araddr_r  <=  sb_araddr_m;
  end
end

// read data channel
reg           rflag_r;
reg           rvalid_r;
reg   [31:0]  rdata_r;

assign  sb_rready_s  = ~rflag_r | sb_rready_m;
assign  sb_rvalid_m  = rvalid_r;
assign  sb_rdata_m   = rdata_r;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    rflag_r  <=  1'b0;
  end
  else if (sb_rvalid_s & sb_rready_s) begin
    rflag_r  <=  1'b1;
  end
  else if(sb_rready_m & ~sb_rvalid_s) begin
    rflag_r  <=  1'b0;
  end
end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    rvalid_r <=  1'b0;
    rdata_r  <=  32'b0;
  end
  else if (sb_rready_s) begin
    rvalid_r <=  sb_rvalid_s;
    rdata_r  <=  sb_rdata_s;
  end
end

// write channel
reg           wflag_r;
reg           wvalid_r;
reg   [31:0]  waddr_r;
reg   [31:0]  wdata_r;
reg   [3:0]   wstrb_r;

assign  sb_wready_m  = ~wflag_r | sb_wready_s;
assign  sb_wvalid_s  = wvalid_r;
assign  sb_waddr_s   = waddr_r;
assign  sb_wdata_s   = wdata_r;
assign  sb_wstrb_s   = wstrb_r;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    wflag_r  <=  1'b0;
  end
  else if (sb_wvalid_m & sb_wready_m) begin
    wflag_r  <=  1'b1;
  end
  else if(sb_wready_s & ~sb_wvalid_m) begin
    wflag_r  <=  1'b0;
  end
end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    wvalid_r <=  1'b0;
    waddr_r  <=  32'b0;
    wdata_r  <=  32'b0;
    wstrb_r  <=  4'b0;
  end
  else if (sb_arready_m) begin
    wvalid_r <=  sb_wvalid_m;
    waddr_r  <=  sb_waddr_m;
    wdata_r  <=  sb_wdata_m;
    wstrb_r  <=  sb_wstrb_m;
  end
end

// write response channel
reg           bflag_r;
reg           bvalid_r;
reg           bresp_r;

assign  sb_bready_s  = ~bflag_r | sb_bready_m;
assign  sb_bvalid_m  = bvalid_r;
assign  sb_bresp_m   = bresp_r;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    bflag_r  <=  1'b0;
  end
  else if (sb_bvalid_s & sb_bready_s) begin
    bflag_r  <=  1'b1;
  end
  else if(sb_bready_m & ~sb_bvalid_s) begin
    bflag_r  <=  1'b0;
  end
end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    bvalid_r <=  1'b0;
    bresp_r  <=  1'b0;
  end
  else if (sb_bready_s) begin
    bvalid_r <=  sb_bvalid_s;
    bresp_r  <=  sb_bresp_s;
  end
end



endmodule


