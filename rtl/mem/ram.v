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

module ram (
  input           clk,
  input           we,
  input   [9:0]   waddr,
  input   [31:0]  wdata,
  input           re,
  input   [9:0]   raddr,
  output  [31:0]  rdata
);

reg   [31:0]  mem [1023:0];
reg   [31:0]  rdata_r;

assign        rdata = rdata_r;

// write data
always @ (posedge clk) begin
  if(we) begin
    mem[waddr]  <= wdata;
  end
end
// read data
always @ (posedge clk) begin
  if(re) begin
    rdata_r  <= mem[raddr];
  end
end

endmodule

