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

module core_c1_exu_lsu (

input		[7:0]		cmd_type_bus,		//指令类型
input		[7:0]		cmd_op_memory,		//指令操作


input		[31:0]	exu_rs1_data,
input		[31:0]	exu_rs2_data,
input		[31:0]	exu_imm32,

input 	[31:0]	lsu_load_data,
output	[31:0]	lsu_store_addr,
output				  lsu_store_en,
output	[31:0]	lsu_store_data,
output	[1:0]		lsu_store_size,

output          lsu_rd_valid,
output  [31:0]  lsu_rd_data

);


wire	cmd_type_memory_load		=	cmd_type_bus[1];
wire	cmd_type_memory_store	  =	cmd_type_bus[2];

wire	cmd_LB	=	cmd_type_memory_load & cmd_op_memory[7];
wire	cmd_LH	=	cmd_type_memory_load & cmd_op_memory[6];
wire	cmd_LW	=	cmd_type_memory_load & cmd_op_memory[5];
wire	cmd_LBU	=	cmd_type_memory_load & cmd_op_memory[4];
wire	cmd_LHU	=	cmd_type_memory_load & cmd_op_memory[3];
wire	cmd_SB	=	cmd_type_memory_store & cmd_op_memory[2];
wire	cmd_SH	=	cmd_type_memory_store & cmd_op_memory[1];
wire	cmd_SW	=	cmd_type_memory_store & cmd_op_memory[0];


//----------------------------------------------------
// load instruction
//----------------------------------------------------
assign	lsu_rd_valid  =	cmd_LB | cmd_LH | cmd_LW | cmd_LBU | cmd_LHU;
assign	lsu_rd_data	  =	({32{cmd_LB}}   & {{24{lsu_load_data[7]}},lsu_load_data[7:0]})
                      |	({32{cmd_LH}}   & {{16{lsu_load_data[15]}},lsu_load_data[15:0]})
                      |	({32{cmd_LW}}   & lsu_load_data)
                      |	({32{cmd_LBU}}  & {24'b0,lsu_load_data[7:0]})
                      |	({32{cmd_LHU}}  & {16'b0,lsu_load_data[15:0]});							

//----------------------------------------------------
// store instruction
//----------------------------------------------------
assign	lsu_store_addr  =	exu_rs1_data + exu_imm32;
assign	lsu_store_en		=	cmd_SB | cmd_SH | cmd_SW;
assign	lsu_store_data	=	({32{cmd_SB}} & {exu_rs2_data[7:0] ,exu_rs2_data[7:0] ,exu_rs2_data[7:0] ,exu_rs2_data[7:0]})
                        |	({32{cmd_SH}} & {exu_rs2_data[15:0],exu_rs2_data[15:0]})
                        |	({32{cmd_SW}} &  exu_rs2_data);						
assign	lsu_store_size	= cmd_SB ? 2'b00
                        : cmd_SH ? 2'b01
                        : cmd_SW ? 2'b10
                        : 2'b0;




endmodule


