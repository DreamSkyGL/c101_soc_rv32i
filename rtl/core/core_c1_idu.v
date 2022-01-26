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

module core_c1_idu (

input   [31:0]  i_inst,	//来自IFU模块的指令输入

//output		 decode_jalr_rs1x0,
output  [4:0]   rs1_idx,
output  [4:0]   rs2_idx,
output  [4:0]   rd_idx,
output  [31:0]  imm_32,
output  [54:0]  cmd_op_bus
);

assign        rs1_idx	          =	i_inst[19:15];
assign        rs2_idx	          =	i_inst[24:20];
assign        rd_idx            =	i_inst[11:7];
wire          rs1x0             = (rs1_idx == 5'b00000);
//wire        rs2x0             = (rs2_idx == 5'b00000);
wire          rdx0              = (rd_idx  == 5'b00000);

wire  [11:0]  imm_11_0_itype    =	 i_inst[31:20];
wire  [11:0]  imm_11_0_stype    =	{i_inst[31:25],i_inst[11:7]};
wire  [19:0]  imm_31_12_utype   =	 i_inst[31:12];
wire  [11:0]  imm_12_1_btype    =	{i_inst[31],i_inst[7],i_inst[30:25],i_inst[11:8]};
wire  [19:0]  imm_20_1_jtype    =	{i_inst[31],i_inst[19:12],i_inst[20],i_inst[30:21]};

wire  [6:0]   opcode            = i_inst[6:0];
wire  [2:0]   func3             = i_inst[14:12];
wire  [6:0]   func7             = i_inst[31:25];
wire          opcode_4_2_000    = (opcode[4:2] == 3'b000);
wire          opcode_4_2_001    = (opcode[4:2] == 3'b001);
//wire        opcode_4_2_010    = (opcode[4:2] == 3'b010);
wire          opcode_4_2_011    = (opcode[4:2] == 3'b011);
wire          opcode_4_2_100    = (opcode[4:2] == 3'b100);
wire          opcode_4_2_101    = (opcode[4:2] == 3'b101);
wire          opcode_4_2_110    = (opcode[4:2] == 3'b110);
//wire        opcode_4_2_111    = (opcode[4:2] == 3'b111);
wire          opcode_6_5_00     = (opcode[6:5] == 2'b00);
wire          opcode_6_5_01     = (opcode[6:5] == 2'b01);
wire          opcode_6_5_10     = (opcode[6:5] == 2'b10);
wire          opcode_6_5_11     = (opcode[6:5] == 2'b11);
wire          opcode_1_0_11     = (opcode[1:0] == 2'b11);
wire          func3_000         = (func3 == 3'b000);
wire          func3_001         = (func3 == 3'b001);
wire          func3_010         = (func3 == 3'b010);
wire          func3_011         = (func3 == 3'b011);
wire          func3_100         = (func3 == 3'b100);
wire          func3_101         = (func3 == 3'b101);
wire          func3_110         = (func3 == 3'b110);
wire          func3_111         = (func3 == 3'b111);
//RV32I中只有4种func7，故其他种类无需译码。(func7仅出现在R类指令中)
wire          func7_0000000     = (func7 == 7'b0000000);
wire          func7_0100000     = (func7 == 7'b0100000);
wire          func7_0001000     = (func7 == 7'b0001000);
wire          func7_0011000     = (func7 == 7'b0011000);

//---------------------------------------------------------------
// RV32I base instructions
//---------------------------------------------------------------
//U type only this 2 in RV64GC
wire cmd_LUI    = (opcode_6_5_01 & opcode_4_2_101);
wire cmd_AUIPC  = (opcode_6_5_00 & opcode_4_2_101);
//J type only this 1 in RV64GC
wire cmd_JAL    = (opcode_6_5_11 & opcode_4_2_011);
//B type only this 6 in RV64GC
wire cmd_BEQ    =	(opcode_6_5_11 & opcode_4_2_000 & func3_000);
wire cmd_BNE    =	(opcode_6_5_11 & opcode_4_2_000 & func3_001);
wire cmd_BLT    =	(opcode_6_5_11 & opcode_4_2_000 & func3_100);
wire cmd_BGE    =	(opcode_6_5_11 & opcode_4_2_000 & func3_101);
wire cmd_BLTU   =	(opcode_6_5_11 & opcode_4_2_000 & func3_110);
wire cmd_BGEU   =	(opcode_6_5_11 & opcode_4_2_000 & func3_111);
//S type only this 3 in RV32I     S type is only for store instructions
wire cmd_SB     = (opcode_6_5_01 & opcode_4_2_000 & func3_000);
wire cmd_SH     = (opcode_6_5_01 & opcode_4_2_000 & func3_001);
wire cmd_SW     = (opcode_6_5_01 & opcode_4_2_000 & func3_010);
//R type
wire cmd_ADD    = (opcode_6_5_01 & opcode_4_2_100 & func3_000 & func7_0000000);
wire cmd_SUB    = (opcode_6_5_01 & opcode_4_2_100 & func3_000 & func7_0100000);
wire cmd_SLL    = (opcode_6_5_01 & opcode_4_2_100 & func3_001 & func7_0000000);
wire cmd_SLT    = (opcode_6_5_01 & opcode_4_2_100 & func3_010 & func7_0000000);
wire cmd_SLTU   = (opcode_6_5_01 & opcode_4_2_100 & func3_011 & func7_0000000);
wire cmd_XOR    = (opcode_6_5_01 & opcode_4_2_100 & func3_100 & func7_0000000);
wire cmd_SRL    = (opcode_6_5_01 & opcode_4_2_100 & func3_101 & func7_0000000);
wire cmd_SRA    = (opcode_6_5_01 & opcode_4_2_100 & func3_101 & func7_0100000);
wire cmd_OR     = (opcode_6_5_01 & opcode_4_2_100 & func3_110 & func7_0000000);
wire cmd_AND    = (opcode_6_5_01 & opcode_4_2_100 & func3_111 & func7_0000000);
//I type
wire cmd_JALR   = (opcode_6_5_11 & opcode_4_2_001 & func3_000);
wire cmd_LB     = (opcode_6_5_00 & opcode_4_2_000 & func3_000 & opcode_1_0_11);
wire cmd_LH     = (opcode_6_5_00 & opcode_4_2_000 & func3_001 & opcode_1_0_11);
wire cmd_LW     = (opcode_6_5_00 & opcode_4_2_000 & func3_010 & opcode_1_0_11);
wire cmd_LBU    = (opcode_6_5_00 & opcode_4_2_000 & func3_100 & opcode_1_0_11);
wire cmd_LHU    = (opcode_6_5_00 & opcode_4_2_000 & func3_101 & opcode_1_0_11);
wire cmd_ADDI   = (opcode_6_5_00 & opcode_4_2_100 & func3_000);
wire cmd_SLTI   = (opcode_6_5_00 & opcode_4_2_100 & func3_010);
wire cmd_SLTIU  = (opcode_6_5_00 & opcode_4_2_100 & func3_011);
wire cmd_XORI   = (opcode_6_5_00 & opcode_4_2_100 & func3_100);
wire cmd_ORI    = (opcode_6_5_00 & opcode_4_2_100 & func3_110);
wire cmd_ANDI   = (opcode_6_5_00 & opcode_4_2_100 & func3_111);
wire cmd_SLLI   = (opcode_6_5_00 & opcode_4_2_100 & func3_001 & func7_0000000);
wire cmd_SRLI   = (opcode_6_5_00 & opcode_4_2_100 & func3_101 & func7_0000000);
wire cmd_SRAI   = (opcode_6_5_00 & opcode_4_2_100 & func3_101 & func7_0100000);
// CSR Instructions
wire cmd_CSRRW  = (opcode_6_5_11 & opcode_4_2_100 & func3_001);
wire cmd_CSRRS  = (opcode_6_5_11 & opcode_4_2_100 & func3_010);
wire cmd_CSRRC  = (opcode_6_5_11 & opcode_4_2_100 & func3_011);
wire cmd_CSRRWI = (opcode_6_5_11 & opcode_4_2_100 & func3_101);
wire cmd_CSRRSI = (opcode_6_5_11 & opcode_4_2_100 & func3_110);
wire cmd_CSRRCI = (opcode_6_5_11 & opcode_4_2_100 & func3_111);
// system instructions
wire cmd_URET   = (opcode_6_5_11 & opcode_4_2_100 & func3_000 & func7_0000000 & rs1x0 & rdx0 & (rs2_idx == 5'b00010));
wire cmd_SRET   = (opcode_6_5_11 & opcode_4_2_100 & func3_000 & func7_0001000 & rs1x0 & rdx0 & (rs2_idx == 5'b00010));
wire cmd_MRET   = (opcode_6_5_11 & opcode_4_2_100 & func3_000 & func7_0011000 & rs1x0 & rdx0 & (rs2_idx == 5'b00010));
wire cmd_WFI    = (opcode_6_5_11 & opcode_4_2_100 & func3_000 & func7_0001000 & rs1x0 & rdx0 & (rs2_idx == 5'b00101));
wire cmd_FENCE  = (opcode_6_5_00 & opcode_4_2_011 & func3_000);
wire cmd_FENCE_I= (opcode_6_5_00 & opcode_4_2_011 & func3_001);
wire cmd_ECALL  = (opcode_6_5_11 & opcode_4_2_100 & func3_000 & (imm_11_0_itype == 12'b0));
wire cmd_EBREAK = (opcode_6_5_11 & opcode_4_2_100 & func3_000 & (imm_11_0_itype == 12'b1));
/**********************************************************************************************
												指令大类分类
**********************************************************************************************/
wire cmd_utype  = cmd_LUI | cmd_AUIPC;            // 0x_101 only 2 inst: lui auipc  utype is only this 2 inst in all of inst in rv64gc
wire cmd_jtype  = cmd_JAL;                        // 11_011 only 1 inst: jal        jtype is only this 1 inst in all of inst in rv64gc
wire cmd_btype  = opcode_6_5_11 & opcode_4_2_000; // 11_000 only 6 inst: bxx        btype is only this 6 inst in all of inst in rv64gc
wire cmd_stype  = opcode_6_5_01 & opcode_4_2_000; // 01_000 only 3 inst: store (in rv32i:3, rv64i:1 rvf/d/q:1, stype is only for store inst)
wire cmd_itype  = (opcode_6_5_00 & (opcode_4_2_000 | opcode_4_2_100 | opcode_4_2_110)) | (opcode_6_5_11 & (opcode_4_2_001 | opcode_4_2_100));
wire cmd_rtype  = (opcode_6_5_01 & (opcode_4_2_100 | opcode_4_2_110 | opcode_4_2_011)) | (opcode_6_5_10 & (opcode_4_2_100));
//ECALL, EBREAK, URET, SRET, MRET, WFI, FENCE, FENCE.I 这8条特殊指令
wire cmd_type_sys	=	(cmd_ECALL | cmd_EBREAK | cmd_URET | cmd_SRET | cmd_MRET | cmd_WFI | cmd_FENCE | cmd_FENCE_I);		//8
wire cmd_type_illegal	=	(!(cmd_utype | cmd_jtype | cmd_btype | cmd_stype | cmd_itype | cmd_rtype | cmd_type_sys) | (opcode[1:0] != 2'b11));

assign  imm_32  = ({32{cmd_utype}} & {imm_31_12_utype, {12{1'b0}}})                   //LUI, AUIPC
                |	({32{cmd_stype}} & {{20{imm_11_0_stype[11]}}, imm_11_0_stype})		  //Store
                |	({32{cmd_itype}} & {{20{imm_11_0_itype[11]}}, imm_11_0_itype})			//Imm
                |	({32{cmd_jtype}} & {{11{imm_20_1_jtype[19]}}, imm_20_1_jtype,1'b0})	//JAL
                |	({32{cmd_btype}} & {{19{imm_12_1_btype[11]}}, imm_12_1_btype,1'b0});//Bxx
					
wire  [7:0]   cmd_type_bus    =	{cmd_type_illegal,cmd_type_sys,cmd_utype,cmd_jtype,cmd_btype,cmd_stype,cmd_itype,cmd_rtype};
wire  [7:0]   cmd_op_sys  =	{cmd_FENCE,cmd_FENCE_I,cmd_ECALL,cmd_EBREAK,cmd_URET,cmd_SRET,cmd_MRET,cmd_WFI};
wire  [5:0]   cmd_op_csr      =	{cmd_CSRRW,cmd_CSRRS,cmd_CSRRC,cmd_CSRRWI,cmd_CSRRSI,cmd_CSRRCI};
wire  [7:0]   cmd_op_bjp      =	{cmd_JAL,cmd_JALR,cmd_BEQ,cmd_BNE,cmd_BLT,cmd_BGE,cmd_BLTU,cmd_BGEU};
wire  [7:0]   cmd_op_mem   =	{cmd_LB,cmd_LH,cmd_LW,cmd_LBU,cmd_LHU,cmd_SB,cmd_SH,cmd_SW};
//算术逻辑运算的19条指令(10+9)合并为10条以及2条特殊ALU指令LUI，AUIPC
wire  [11:0]  cmd_op_alu      =	{cmd_LUI,cmd_AUIPC,(cmd_ADD|cmd_ADDI),cmd_SUB,(cmd_SLT|cmd_SLTI),(cmd_SLTU|cmd_SLTIU),(cmd_AND|cmd_ANDI),(cmd_OR|cmd_ORI),(cmd_XOR|cmd_XORI),(cmd_SLL|cmd_SLLI),(cmd_SRL|cmd_SRLI),(cmd_SRA|cmd_SRAI)};

assign  cmd_op_bus  = {cmd_type_bus,cmd_op_sys,cmd_op_csr,cmd_op_bjp,cmd_op_mem,cmd_op_alu,rd_idx};


endmodule
