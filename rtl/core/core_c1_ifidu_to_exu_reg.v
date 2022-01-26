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

module core_c1_ifu_to_exu_reg (

input           exu_pause,

input           ifu_inst_valid,
output          exu_inst_valid,

input   [31:0]  ifu_inst,
output  [31:0]  exu_inst,

input   [31:0]  ifu_pc_addr,
output  [31:0]  exu_pc_addr,

input   [31:0]  regs_rs1_data,
output  [31:0]  exu_rs1_data,

input   [31:0]  regs_rs2_data,
output  [31:0]  exu_rs2_data,

input   [4:0]   ifu_rd_idx,
output  [4:0]   exu_rd_idx,

input   [31:0]  ifu_imm32,
output  [31:0]  exu_imm32,

input   [54:0]  ifu_cmd_op_bus,
output  [54:0]  exu_cmd_op_bus,

//以下是CSR I类命令需要用到的rs1_idx作为立即数
input   [4:0]   ifu_rs1_idx,
output  [4:0]   exu_csr_imm,

input clk,
input rst_n

);

reg [31:0]  exu_inst_reg;
reg         exu_inst_valid_reg;
reg [31:0]  exu_pc_addr_reg;
reg [31:0]  exu_rs1_data_reg;
reg [31:0]  exu_rs2_data_reg;
reg [4:0]   exu_rd_idx_reg;
reg [31:0]  exu_imm32_reg;
reg [4:0]   exu_csr_imm_reg;
reg [54:0]  exu_cmd_op_bus_reg;

assign      exu_inst        = exu_inst_reg;
assign      exu_inst_valid  = exu_inst_valid_reg;
assign      exu_pc_addr     = exu_pc_addr_reg;
assign      exu_rs1_data    = exu_rs1_data_reg;
assign      exu_rs2_data    = exu_rs2_data_reg;
assign      exu_rd_idx      = exu_rd_idx_reg;
assign      exu_imm32       = exu_imm32_reg;
assign      exu_csr_imm     = exu_csr_imm_reg;
assign      exu_cmd_op_bus  = exu_cmd_op_bus_reg;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    exu_inst_reg              <= 32'b0;
    exu_inst_valid_reg        <= 1'b0;
    exu_pc_addr_reg           <= 32'b0;
    exu_cmd_op_bus_reg        <= 55'b0;
    exu_imm32_reg             <= 32'b0;
    exu_rs1_data_reg          <= 32'b0;
    exu_rs2_data_reg          <= 32'b0;
    exu_rd_idx_reg            <= 5'b0;
    exu_csr_imm_reg           <= 5'b0;
  end
  else begin
    if(!exu_pause) begin
      exu_inst_reg              <= ifu_inst;
      exu_inst_valid_reg        <= ifu_inst_valid;
      exu_pc_addr_reg           <= ifu_pc_addr;
      exu_cmd_op_bus_reg        <= ifu_cmd_op_bus;
      exu_imm32_reg             <= ifu_imm32;
      exu_rs1_data_reg          <= regs_rs1_data;
      exu_rs2_data_reg          <= regs_rs2_data;
      exu_rd_idx_reg            <= ifu_rd_idx;
      exu_csr_imm_reg           <= ifu_rs1_idx;
    end
  end
end

endmodule

