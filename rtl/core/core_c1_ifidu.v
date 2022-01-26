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

module core_c1_ifu(

  input           clk,
  input           rst_n,
  
  input           i_pc_wash_req_b,  // branch instruction
  input           i_pc_wash_req_e,  // exception
  input   [31:0]  i_pc_wash_addr_b,
  input   [31:0]  i_pc_wash_addr_e,
  
  input           i_ifu_pause,
  
  output          o_pc_valid_biu,
  output  [31:0]  o_pc_addr_biu,
  input           i_inst_valid_biu,
  input   [31:0]  i_inst_biu,
  
  output          o_inst_valid_exu,
  output  [31:0]  o_inst_exu,
  output  [31:0]  o_pc_addr_exu,
  output  [4:0]   o_rs1_idx,
  output  [4:0]   o_rs2_idx,
  output  [4:0]   o_rd_idx,
  output  [31:0]  o_imm32,
  output  [54:0]  o_cmd_op_bus,
  
  input   [31:0]  i_rs1_data,
  output  [31:0]  o_mem_load_addr,
  output          o_mem_load_valid

);

reg   [31:0]  pc_addr_r;
reg   [31:0]  pc_addr_out_r;
reg           pc_wash_req_r;
wire          pc_wash_req;

assign  pc_wash_req       = i_pc_wash_req_b | i_pc_wash_req_e;

assign  o_pc_valid_biu    = rst_n & ~i_ifu_pause & ~pc_wash_req;          
assign  o_pc_addr_biu     = pc_addr_r;

assign  o_inst_valid_exu  = rst_n & ~i_ifu_pause & ~(pc_wash_req | pc_wash_req_r) & i_inst_valid_biu;
assign  o_pc_addr_exu     = pc_addr_out_r;
assign  o_inst_exu        = i_inst_biu;

assign  o_mem_load_addr   = i_rs1_data + o_imm32;
assign  o_mem_load_valid  = o_inst_valid_exu & (|o_cmd_op_bus[24:20]);

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    pc_addr_r <= 32'h40000000;
  end
  else if(i_pc_wash_req_e) begin
    pc_addr_r <= i_pc_wash_addr_e;
  end
  else if(i_pc_wash_req_b) begin
    pc_addr_r <= i_pc_wash_addr_b;
  end
  else if(i_ifu_pause) begin
    pc_addr_r <= pc_addr_r;
  end
  else begin
    pc_addr_r <= pc_addr_r + 32'h4;
  end
end

always @ (posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		pc_addr_out_r <= 32'b0;
	end
  else if (o_pc_valid_biu)begin
    pc_addr_out_r <= o_pc_addr_biu;
  end
end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    pc_wash_req_r <=  1'b0;
  end
  else if(i_ifu_pause & pc_wash_req) begin
    pc_wash_req_r <=  1'b1;
  end
  else if(i_inst_valid_biu) begin
    pc_wash_req_r <=  1'b0;
  end
end

// instruction decoder unit
core_c1_idu u_core_c1_idu(
  .i_inst       (i_inst_biu   ),
  .rs1_idx      (o_rs1_idx    ),
  .rs2_idx      (o_rs2_idx    ),
  .rd_idx       (o_rd_idx     ),
  .imm_32       (o_imm32      ),
  .cmd_op_bus   (o_cmd_op_bus )
);

endmodule
