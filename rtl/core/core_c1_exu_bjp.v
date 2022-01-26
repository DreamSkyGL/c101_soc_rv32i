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

module core_c1_exu_bjp (

//四个源操作数输入
input   [31:0]	exu_pc_addr,
input   [31:0]	exu_rs1_data,
input   [31:0]	exu_rs2_data,
input   [31:0]	exu_imm32,

input   [7:0]   cmd_type_bus,	//指令类型
input   [7:0]   cmd_op_bjp,		//指令操作

output          bjp_rd_valid,
output  [31:0]  bjp_rd_data,

output          pipeline_wash_request,
output  [31:0]  pipeline_wash_pc

);

wire	cmd_type_bxx	=	cmd_type_bus[3];

wire	cmd_JAL	  =	cmd_op_bjp[7];
wire	cmd_JALR	=	cmd_op_bjp[6];
wire	cmd_BEQ	  =	cmd_type_bxx & cmd_op_bjp[5];
wire	cmd_BNE	  =	cmd_type_bxx & cmd_op_bjp[4];
wire	cmd_BLT	  =	cmd_type_bxx & cmd_op_bjp[3];
wire	cmd_BGE	  =	cmd_type_bxx & cmd_op_bjp[2];
wire	cmd_BLTU	=	cmd_type_bxx & cmd_op_bjp[1];
wire	cmd_BGEU	=	cmd_type_bxx & cmd_op_bjp[0];
//wire	cmd_Bxx	  =	cmd_BEQ|cmd_BNE|cmd_BLT|cmd_BGE|cmd_BLTU|cmd_BGEU;


//判断是否需要跳转
wire	BEQ_jump		=	(cmd_BEQ & (exu_rs1_data == exu_rs2_data));
wire	BNE_jump		=	(cmd_BNE & (exu_rs1_data != exu_rs2_data));
wire	BLTU_jump	  =	(cmd_BLTU & (exu_rs1_data < exu_rs2_data));
wire	BGEU_jump	  =	(cmd_BGEU & (exu_rs1_data >= exu_rs2_data));
wire	BLT_jump		=	(cmd_BLT & (((exu_rs1_data[31]==exu_rs2_data[31])&(exu_rs1_data<exu_rs2_data))
						|	 ((exu_rs1_data[31]==1)&(exu_rs2_data[31]==0))));
wire	BGE_jump		=	(cmd_BGE & (((exu_rs1_data[31]==exu_rs2_data[31])&(exu_rs1_data>exu_rs2_data))
						|	 ((exu_rs1_data[31]==0)&(exu_rs2_data[31]==1))
						|	 (exu_rs1_data == exu_rs2_data)));

//确定需要跳转
wire	bjp_taken	=	cmd_JAL | cmd_JALR | BEQ_jump | BNE_jump | BLTU_jump | BGEU_jump | BLT_jump | BGE_jump;

assign	pipeline_wash_request	=	bjp_taken;
assign	pipeline_wash_pc			= cmd_JALR ? exu_rs1_data + exu_imm32 : exu_pc_addr + exu_imm32;

assign	bjp_rd_valid  =	cmd_JAL | cmd_JALR;
assign	bjp_rd_data   =	exu_pc_addr + 32'd4;

endmodule


