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

module core_c1_exu_alu (

//四个源操作数输入
input		[31:0]	exu_pc_addr,
input		[31:0]	exu_rs1_data,
input		[31:0]	exu_rs2_data,
input		[31:0]	exu_imm32,

input		[7:0]		cmd_type_bus,	//指令类型
input		[11:0]	cmd_op_alu,		//指令操作

output	[31:0]	alu_rd_data,
output				  alu_rd_valid		//写寄存器请求
);

wire	[31:0]	alu_op1;
wire	[31:0]	alu_op2;

wire	cmd_type_alu_reg	=	cmd_type_bus[0];
wire	cmd_type_alu_imm	=	cmd_type_bus[1];
wire	cmd_type_alu_spe	=	cmd_type_bus[5];
/*
wire	cmd_LUI		=	cmd_op_alu[11] & cmd_type_alu_spe;
wire	cmd_AUIPC	=	cmd_op_alu[10] & cmd_type_alu_spe;
wire	cmd_ADD		=	cmd_op_alu[9] & cmd_type_alu_reg;
wire	cmd_SUB		=	cmd_op_alu[8] & cmd_type_alu_reg;
wire	cmd_SLT		=	cmd_op_alu[7] & cmd_type_alu_reg;
wire	cmd_SLTU		=	cmd_op_alu[6] & cmd_type_alu_reg;
wire	cmd_AND		=	cmd_op_alu[5] & cmd_type_alu_reg;
wire	cmd_OR		=	cmd_op_alu[4] & cmd_type_alu_reg;
wire	cmd_XOR		=	cmd_op_alu[3] & cmd_type_alu_reg;
wire	cmd_SLL		=	cmd_op_alu[2] & cmd_type_alu_reg;
wire	cmd_SRL		=	cmd_op_alu[1] & cmd_type_alu_reg;
wire	cmd_SRA		=	cmd_op_alu[0] & cmd_type_alu_reg;
wire	cmd_ADDI		=	cmd_op_alu[9] & cmd_type_alu_imm;
wire	cmd_SLTI		=	cmd_op_alu[7] & cmd_type_alu_imm;
wire	cmd_SLTUI	=	cmd_op_alu[6] & cmd_type_alu_imm;
wire	cmd_ANDI		=	cmd_op_alu[5] & cmd_type_alu_imm;
wire	cmd_ORI		=	cmd_op_alu[4] & cmd_type_alu_imm;
wire	cmd_XORI		=	cmd_op_alu[3] & cmd_type_alu_imm;
wire	cmd_SLLI		=	cmd_op_alu[2] & cmd_type_alu_imm;
wire	cmd_SRLI		=	cmd_op_alu[1] & cmd_type_alu_imm;
wire	cmd_SRAI		=	cmd_op_alu[0] & cmd_type_alu_imm;
*/

assign	alu_op1	=	(cmd_type_alu_reg | cmd_type_alu_imm)	?	exu_rs1_data :
							cmd_type_alu_spe	?	exu_pc_addr : 0;
							
assign	alu_op2	=	cmd_type_alu_reg	?	exu_rs2_data :
							(cmd_type_alu_imm | cmd_type_alu_spe)	?	exu_imm32 : 0;



assign	alu_rd_data	=	cmd_op_alu[9]	?	(alu_op1 + alu_op2)									//ADD(I)
							:	cmd_op_alu[8]	?	(alu_op1 - alu_op2)									//SUB
							:	cmd_op_alu[7]	?	(($signed(alu_op1)) < ($signed(alu_op2)))		//SLT(I)
							:	cmd_op_alu[6]	?	(alu_op1 < alu_op2)									//SLTU(I)
							:	cmd_op_alu[5]	?	(alu_op1 & alu_op2)									//AND(I)
							:	cmd_op_alu[4]	?	(alu_op1 | alu_op2)									//OR(I)
							:	cmd_op_alu[3]	?	(alu_op1 ^ alu_op2)									//XOR(I)
							:	cmd_op_alu[2]	?	(alu_op1 << alu_op2[4:0])							//SLL(I)
							:	cmd_op_alu[1]	?	(alu_op1 >> alu_op2[4:0])							//SRL(I)
							:	cmd_op_alu[0]	?	(($signed(alu_op1)) >>> alu_op2[4:0])			//SRA(I)
							:	cmd_op_alu[11]	?	(alu_op2)								//LUI
							:	cmd_op_alu[10]	?	(alu_op2 + alu_op1)				//AUIPC
							: 0 ;


assign	alu_rd_valid = |cmd_op_alu;

endmodule


