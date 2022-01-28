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

module sb_ram_wrapper (
// gloab signals
input           sb_clk,
input           sb_rst_n,
// read address channel
input           sb_arvalid,
output          sb_arready,
input   [31:0]  sb_araddr,
// read data channel
output          sb_rvalid,
input           sb_rready,
output  [31:0]  sb_rdata,
// write channel
input           sb_wvalid,
output          sb_wready,
input   [31:0]  sb_waddr,
input   [31:0]  sb_wdata,
input   [3:0]   sb_wstrb,
// write response channel
output          sb_bvalid,
input           sb_bready,
output          sb_bresp
);


reg           sb_bvalid_r;
reg           sb_rvalid_r;
reg   [31:0]  sb_rdata_r;

assign        sb_wready   = 1'b1;
assign        sb_bvalid   = sb_bvalid_r;
assign        sb_bresp    = 1'b0;
assign        sb_arready  = 1'b1;
assign        sb_rvalid   = sb_rvalid_r;


// write data
always @ (posedge sb_clk) begin
  if(!sb_rst_n) begin
    sb_bvalid_r <=  1'b0;
  end
  else if(sb_wvalid & sb_wready) begin
    sb_bvalid_r <= 1'b1;
  end
  else if(sb_bready) begin
    sb_bvalid_r <= 1'b0;
  end
end
// read data
always @ (posedge sb_clk) begin
  if(!sb_rst_n) begin
    sb_rvalid_r <=  1'b0;
  end
  else if(sb_arvalid & sb_arready) begin
    sb_rvalid_r <= 1'b1;
  end
  else if(sb_rready) begin
    sb_rvalid_r <= 1'b0;
  end
end

ram u_ram (
  .clk    (sb_clk                 ),
  .we     (sb_wvalid & sb_wready  ),
  .waddr  (sb_waddr[11:2]         ),
  .wdata  (sb_wdata               ),
  .re     (sb_arvalid & sb_arready),
  .raddr  (sb_araddr[11:2]        ),
  .rdata  (sb_rdata               )
);


endmodule

