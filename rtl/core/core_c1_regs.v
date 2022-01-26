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

module core_c1_regs (

input   [4:0]   rs1_idx,
input   [4:0]   rs2_idx,
output  [31:0]  rs1_data,
output  [31:0]  rs2_data,

input           rd_valid,
input  [4:0]    rd_idx,
input  [31:0]   rd_data,

input           rst_n,
input           clk
);


reg   [31:0]  regs  [30:0];

always @ (posedge clk) begin
  if(!rst_n) begin
    regs[0] <=  32'b0;
    regs[1] <=  32'b0;
    regs[2] <=  32'b0;
    regs[3] <=  32'b0;
    regs[4] <=  32'b0;
    regs[5] <=  32'b0;
    regs[6] <=  32'b0;
    regs[7] <=  32'b0;
    regs[8] <=  32'b0;
    regs[9] <=  32'b0;
    regs[10] <=  32'b0;
    regs[11] <=  32'b0;
    regs[12] <=  32'b0;
    regs[13] <=  32'b0;
    regs[14] <=  32'b0;
    regs[15] <=  32'b0;
    regs[16] <=  32'b0;
    regs[17] <=  32'b0;
    regs[18] <=  32'b0;
    regs[19] <=  32'b0;
    regs[20] <=  32'b0;
    regs[21] <=  32'b0;
    regs[22] <=  32'b0;
    regs[23] <=  32'b0;
    regs[24] <=  32'b0;
    regs[25] <=  32'b0;
    regs[26] <=  32'b0;
    regs[27] <=  32'b0;
    regs[28] <=  32'b0;
    regs[29] <=  32'b0;
    regs[30] <=  32'b0;
  end
  else if(rd_valid && (rd_idx != 5'b0)) begin
    regs[rd_idx-1] <= rd_data;
  end
end

assign  rs1_data  = rs1_idx == 5'b0                 ? 32'b0
                  : (rs1_idx == rd_idx) && rd_valid ? rd_data
                  : regs[rs1_idx-1];
//

assign  rs2_data = rs2_idx == 5'b0                  ? 32'b0
                  : (rs2_idx == rd_idx) && rd_valid ? rd_data
                  : regs[rs2_idx-1];
//
      
endmodule
