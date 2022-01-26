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

module core_c1_exu (

input           exu_pause,

input           exu_inst_valid,	
input		[31:0]	exu_pc_addr,
input		[31:0]	exu_rs1_data,
input		[31:0]	exu_rs2_data,
input		[31:0]	exu_imm32,

input		[54:0]	exu_cmd_op_bus,

input   [4:0]   exu_csr_imm,

output	[4:0]		exu_rd_idx,		//目标寄存器idxx
output	[31:0]	exu_rd_data,
output				  exu_rd_valid,


//Memory Access
input 	[31:0]  memory_load_data,
output	[31:0]  memory_store_addr,
output          memory_store_en,
output	[31:0]  memory_store_data,
output	[1:0]   memory_store_size,

//CSR操作
output  [11:0]  csr_addr,			//输入需要读写的寄存器地址
input   [31:0]  csr_read_data,		//输出读到的值
output  [31:0]  csr_write_data,	//输入要写的值
output          csr_en,				//输入CSR读写使能
output  [5:0]   csr_cmd,				//输入CSR读写操作
output  [4:0]   csr_imm,				//CSR指令中的立即数

//会产生的异常类型。只保留了3类
output          exception_illegal_instruction,    // exception number 2
output          exception_breakpoint,             // exception number 3
output          exception_ecall_mmode,            // exception number 11

output          cmd_mret,
output  [31:0]  exu_o_pc_next,

output          pc_wash_req_b,
output  [31:0]  pc_wash_addr_b

);



assign        exu_rd_idx      = exu_cmd_op_bus[4:0];
wire  [11:0]  cmd_op_alu      = exu_inst_valid ? exu_cmd_op_bus[16:5]		: 12'b0;
wire  [7:0]   cmd_op_mem      = exu_inst_valid ? exu_cmd_op_bus[24:17]	: 8'b0;
wire  [7:0]   cmd_op_bjp      = exu_inst_valid ? exu_cmd_op_bus[32:25]	: 8'b0;
wire  [5:0]   cmd_op_csr      = exu_inst_valid ? exu_cmd_op_bus[38:33]	: 6'b0;
wire  [7:0]   cmd_op_sys      = exu_inst_valid ? exu_cmd_op_bus[46:39]	: 8'b0;
wire  [7:0]   cmd_type_bus    = exu_inst_valid ? exu_cmd_op_bus[54:47]	: 8'b0;
wire          cmd_illegal     =	cmd_type_bus[7];
assign        exception_illegal_instruction	=	exu_inst_valid & cmd_illegal;
assign        exception_ecall_mmode	        =	cmd_op_sys[5];
assign        exception_breakpoint		      =	cmd_op_sys[4];
assign        cmd_mret	                    =	cmd_op_sys[1];

wire	[31:0]	alu_rd_data;
wire				  alu_rd_valid;
wire	[31:0]	csr_rd_data;
wire				  csr_rd_valid;
wire	[31:0]	bjp_rd_data;
wire				  bjp_rd_valid;
wire  [31:0]  lsu_rd_data;
wire          lsu_rd_valid;

/************************************************************
							ALU运算单元
************************************************************/
core_c1_exu_alu core_c1_exu_alu(

//四个源操作数输入
.exu_pc_addr(exu_pc_addr),
.exu_rs1_data(exu_rs1_data),
.exu_rs2_data(exu_rs2_data),
.exu_imm32(exu_imm32),

.cmd_type_bus(cmd_type_bus),	//指令类型
.cmd_op_alu(cmd_op_alu),		//指令操作

.alu_rd_valid(alu_rd_valid),
.alu_rd_data(alu_rd_data)

);

/************************************************************
							BJP分支单元
************************************************************/
core_c1_exu_bjp core_c1_exu_bjp (

//四个源操作数输入
.exu_pc_addr(exu_pc_addr),
.exu_rs1_data(exu_rs1_data),
.exu_rs2_data(exu_rs2_data),
.exu_imm32(exu_imm32),

.cmd_type_bus(cmd_type_bus),	//指令类型
.cmd_op_bjp(cmd_op_bjp),		//指令操作

.pipeline_wash_request(pc_wash_req_b),
.pipeline_wash_pc(pc_wash_addr_b),

.bjp_rd_valid(bjp_rd_valid),
.bjp_rd_data(bjp_rd_data)

);

assign  exu_o_pc_next = pc_wash_req_b ? pc_wash_addr_b : exu_pc_addr + 32'h4;

/************************************************************
							LSU存储器单元
************************************************************/
core_c1_exu_lsu core_c1_exu_lsu(

.cmd_type_bus(cmd_type_bus),		//指令类型
.cmd_op_memory(cmd_op_mem),		//指令操作

.exu_rs1_data(exu_rs1_data),
.exu_rs2_data(exu_rs2_data),
.exu_imm32(exu_imm32),

.lsu_load_data(memory_load_data),
.lsu_store_addr(memory_store_addr),
.lsu_store_en(memory_store_en),
.lsu_store_data(memory_store_data),
.lsu_store_size(memory_store_size),

.lsu_rd_valid(lsu_rd_valid),
.lsu_rd_data(lsu_rd_data)

);



assign exu_rd_data	= alu_rd_valid ? alu_rd_data
                    :	csr_rd_valid ? csr_rd_data
                    :	bjp_rd_valid ? bjp_rd_data
                    : lsu_rd_valid ? lsu_rd_data
                    :	0;
assign exu_rd_valid = !exu_pause & (alu_rd_valid | csr_rd_valid | bjp_rd_valid | lsu_rd_valid);


/************************************************************
							CSR 单元
							//CSR操作
output	[11:0]	csr_addr,			//输入需要读写的寄存器地址
input		[31:0]	csr_read_data,		//输出读到的值
output	[31:0]	csr_write_data,	//输入要写的值
output				csr_en,				//输入CSR读写使能
output	[5:0]		csr_cmd,				//输入CSR读写操作
//output	[4:0]		csr_imm,				//CSR指令中的立即数
***********************************************************/
assign	csr_addr			  =	exu_imm32[11:0];
assign	csr_write_data	=	exu_rs1_data;
assign	csr_en			    =	|csr_cmd;
assign	csr_cmd			    =	cmd_op_csr;
assign	csr_imm			    =	exu_csr_imm;		

assign  csr_rd_valid    = csr_en;
assign  csr_rd_data     = csr_read_data;

endmodule
