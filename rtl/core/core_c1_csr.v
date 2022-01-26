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

`define   csr_addr_mstatus    12'h300
`define   csr_addr_misa       12'h301
`define   csr_addr_mie        12'h304
`define   csr_addr_mtvec      12'h305
`define   csr_addr_mscratch   12'h340
`define   csr_addr_mepc       12'h341
`define   csr_addr_mcause     12'h342
`define   csr_addr_mtval      12'h343
`define   csr_addr_mip        12'h344
`define   csr_addr_mvendorid  12'hF11
`define   csr_addr_marchid    12'hF12
`define   csr_addr_mimpid     12'hF13
`define   csr_addr_mhartid    12'hF14


module core_c1_csr (
input           clk,
input           rst_n,
//csr寄存器读取为一个纯粹的多路选择器
//csr寄存器的写与工作寄存器组类似
input   [11:0]  csr_addr,
output  [31:0]  csr_read_data,
input   [31:0]  csr_write_data,
input           csr_en,
input   [5:0]   csr_cmd,
input   [4:0]   csr_imm,
//以下端口来自异常和中断系统
input           cmd_mret,
input           in_exception,			//异常输入
input           in_interrupt,			//中断输入
input   [7:0]   in_exception_code,	//异常编号
input   [7:0]   in_interrupt_code,	//中断编号
input   [31:0]  pc_address,				//输入当前执行的代码的PC
input   [31:0]  pc_address_next,
output  [31:0]  pc_wash_addr_e,				//输出需要跳转到的PC地址
output          pc_wash_req_e
);

/************************************
CSR寄存器连线
************************************/
wire	[31:0]	misa;
wire	[31:0]	mvendorid;
wire	[31:0]	marchid;
wire	[31:0]	mimpid;
wire	[31:0]	mhartid;
reg	[31:0]	mstatus;
reg	[31:0]	mtvec;
reg	[31:0]	mepc;
reg	[31:0]	mcause;
reg	[31:0]	mtval;//(暂未实现)
reg	[31:0]	mie;
wire	[31:0]	mip;
reg	[31:0]	mscratch;//临时寄存器
/*
wire	[31:0]	mcycle;//(暂未实现)
wire	[31:0]	mcycleh;//(暂未实现)
wire	[31:0]	minstret;//(暂未实现)
wire	[31:0]	minstreth;//(暂未实现)
wire	[31:0]	mtime;//(暂未实现)
wire	[31:0]	mtimecmp;//(暂未实现)
wire	[31:0]	msip;//(暂未实现)
*/

/********************************************************/
wire	csr_choice_mstatus	=	csr_addr == `csr_addr_mstatus;
wire	csr_choice_misa		=	csr_addr == `csr_addr_misa;
wire	csr_choice_mie			=	csr_addr == `csr_addr_mie;
wire	csr_choice_mtvec		=	csr_addr == `csr_addr_mtvec;
wire	csr_choice_mscratch	=	csr_addr == `csr_addr_mscratch;
wire	csr_choice_mepc		=	csr_addr == `csr_addr_mepc;
wire	csr_choice_mcause		=	csr_addr == `csr_addr_mcause;
wire	csr_choice_mtval		=	csr_addr == `csr_addr_mtval;
wire	csr_choice_mip			=	csr_addr == `csr_addr_mip;
wire	csr_choice_mvendorid	=	csr_addr == `csr_addr_mvendorid;
wire	csr_choice_marchid	=	csr_addr == `csr_addr_marchid;
wire	csr_choice_mimpid		=	csr_addr == `csr_addr_mimpid;
wire	csr_choice_mhartid	=	csr_addr == `csr_addr_mhartid;
wire	[31:0]	csr_new;



/***************************************************************************************

下面对中断和异常进行处理

***************************************************************************************/
//wire	in_interrupt_usoft	=	in_interrupt & (in_interrupt_code==8'd0);
//wire	in_interrupt_ssoft	=	in_interrupt & (in_interrupt_code==8'd1);
wire	in_interrupt_msoft	=	in_interrupt & (in_interrupt_code==8'd3);
//wire	in_interrupt_utime	=	in_interrupt & (in_interrupt_code==8'd4);
//wire	in_interrupt_stime	=	in_interrupt & (in_interrupt_code==8'd5);
wire	in_interrupt_mtime	=	in_interrupt & (in_interrupt_code==8'd7);
//wire	in_interrupt_uexti	=	in_interrupt & (in_interrupt_code==8'd8);
//wire	in_interrupt_sexti	=	in_interrupt & (in_interrupt_code==8'd9);
wire	in_interrupt_mexti	=	in_interrupt & (in_interrupt_code==8'd11);

//wire	interrupt_usoft_trigger	=	in_interrupt_usoft & mie[0] & mstatus[0];
//wire	interrupt_ssoft_trigger	=	in_interrupt_ssoft & mie[1] & mstatus[1];
wire	interrupt_msoft_trigger	=	in_interrupt_msoft & mie[3] & mstatus[3];
//wire	interrupt_utime_trigger	=	in_interrupt_utime & mie[4] & mstatus[0];
//wire	interrupt_stime_trigger	=	in_interrupt_stime & mie[5] & mstatus[1];
wire	interrupt_mtime_trigger	=	in_interrupt_mtime & mie[7] & mstatus[3];
//wire	interrupt_uexti_trigger	=	in_interrupt_uexti & mie[8] & mstatus[0];
//wire	interrupt_sexti_trigger	=	in_interrupt_sexti & mie[9] & mstatus[1];
wire	interrupt_mexti_trigger	=	in_interrupt_mexti & mie[11] & mstatus[3];

//wire	interrupt_utrigger	=	interrupt_usoft_trigger | interrupt_utime_trigger | interrupt_uexti_trigger;
//wire	interrupt_strigger	=	interrupt_ssoft_trigger | interrupt_stime_trigger | interrupt_sexti_trigger;
wire	interrupt_mtrigger	=	interrupt_msoft_trigger | interrupt_mtime_trigger | interrupt_mexti_trigger;


/*-------------------------------------------------
misa
-------------------------------------------------*/
assign misa = 32'b01000000000000000000000100000000;

/*-------------------------------------------------
mvendorid
-------------------------------------------------*/
assign mvendorid = 32'b00000000000000000000000000000000;

/*-------------------------------------------------
marchid
-------------------------------------------------*/
assign marchid = 32'b00000000000000000000000000000000;

/*-------------------------------------------------
mimpid
-------------------------------------------------*/
assign mimpid = 32'b00000000000000000000000000000000;

/*-------------------------------------------------
mhartid
-------------------------------------------------*/
assign mhartid = 32'b00000000000000000000000000000000;

/*-------------------------------------------------
mstatus
-------------------------------------------------*/
wire  [31:0]  pc_mtvec;
wire    exception_interrupt_trigger = in_exception | interrupt_mtrigger;
assign	pc_wash_req_e               = exception_interrupt_trigger | cmd_mret;
assign  pc_wash_addr_e  = cmd_mret ? mepc : pc_mtvec;
wire	[31:0]	mstatus_exception = {mstatus[31:8],mstatus[3],7'b0};
wire	[31:0]	mstatus_mret		=	{mstatus[31:8],1'b1,3'b0,mstatus[7],3'b0};
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		mstatus <= 32'b00000000000000000000110010001000;
	else begin
		if (exception_interrupt_trigger)							//如果异常发生，则更新mstatus的值
			mstatus <= mstatus_exception;
		else if (csr_choice_mstatus & csr_en)	//如果写操作发生，则写入mstatus的新值
			mstatus <= csr_new;		
		else if (cmd_mret)
			mstatus <= mstatus_mret;
		else																//否则mstatus保持不变
			mstatus <= mstatus;
	end
end

/*-------------------------------------------------
mtvec
-------------------------------------------------*/
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		mtvec <= 32'h00000000;										//默认中断和异常向量表地址。(暂时未设置)
	else begin
		if (csr_choice_mtvec & csr_en)		//如果写操作发生，则写入mtvec的新值
			mtvec <= csr_new;		
		else																//否则mstatus保持不变
			mtvec <= mtvec;
	end
end
//发生中断异常时需要跳转的pc值
assign	pc_mtvec	=	(mtvec[1:0]	==	2'b00) ? {mtvec[31:2],2'b0}
						:	((mtvec[1:0]	==	2'b01)&in_exception) ? {mtvec[31:2],2'b0}
						:	((mtvec[1:0]	==	2'b01)&interrupt_mtrigger) ? ({mtvec[31:2],2'b0} + 4*in_interrupt_code)
						:	32'b0;

/*-------------------------------------------------
mepc
-------------------------------------------------*/
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		mepc <= 32'h00000000;										//进入中断异常时的PC值
	else begin
		if	(in_exception)					//发生异常，mepc为当前指令的值
			mepc <= pc_address;
		else if	(interrupt_mtrigger)			//发生中断，mepc为下一条指令
			mepc <= pc_address_next;
		else if (csr_choice_mepc & csr_en)		//如果写操作发生，则写入mepc的新值
			mepc <= csr_new;		
		else																//否则mepc保持不变
			mepc <= mepc;
	end
end

/*-------------------------------------------------
mcause
-------------------------------------------------*/
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		mcause <= 32'h00000000;
	else begin
		if	(in_exception)					//发生异常
			mcause <= {24'h000000,in_exception_code};
		else if	(interrupt_mtrigger)			//发生中断
			mcause <= {24'h800000,in_interrupt_code};
		else if (csr_choice_mcause & csr_en)
			mcause <= csr_new;		
		else
			mcause <= mcause;
	end
end


/*-------------------------------------------------
mtval	(暂时未实现)
-------------------------------------------------*/
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		mtval <= 32'h00000000;
	else begin
		if (csr_choice_mtval & csr_en)		//如果写操作发生
			mtval <= csr_new;		
		else																//否则mepc保持不变
			mtval <= mtval;
	end
end

/*-------------------------------------------------
mie
-------------------------------------------------*/
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		mie <= 32'h00000000;										//复位后所有中断都将被屏蔽
	else begin
		if (csr_choice_mie & csr_en)		//如果写操作发生
			mie <= csr_new;		
		else																//否则mepc保持不变
			mie <= mie;
	end
end

/*-------------------------------------------------
mip
-------------------------------------------------*/
reg	[31:0]	mip_reg;
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		mip_reg <= 32'b0;
	else begin
		if (csr_choice_mip & csr_en) begin
			mip_reg <= csr_new;
		end
		else begin
			mip_reg <= mip_reg;
		end
	end
end
assign	mip = {mip_reg[31:12],interrupt_mexti_trigger,mip_reg[10:8],
					interrupt_mtime_trigger,mip_reg[6:4],
					interrupt_msoft_trigger,mip_reg[2:0]};
//
/*-------------------------------------------------
mscratch
-------------------------------------------------*/
always @ (posedge clk or negedge rst_n) begin
	if (!rst_n)
		mscratch <= 32'h00000000;
	else begin
		if (csr_choice_mscratch & csr_en)		//如果写操作发生
			mscratch <= csr_new;		
		else
			mscratch <= mscratch;
	end
end



/************************************************************

CSR选择读取
通过CSR地址多路选择器，将需要读出的CSR值返回到exu模块，并且将该值拉回CSR写前的运算单元，
该单元结合现有的CSR值和指令需要进行的操作，将新的CSR值送入相应的CSR寄存器。
`define	csr_addr_mstatus		0x300
`define	csr_addr_misa			0x301
`define	csr_addr_mie			0x304
`define	csr_addr_mtvec			0x305
`define	csr_addr_mscratch		0x340
`define	csr_addr_mepc			0x341
`define	csr_addr_mcause		0x342
`define	csr_addr_mtval			0x343
`define	csr_addr_mip			0x344
`define	csr_addr_mvendorid	0xF11
`define	csr_addr_marchid		0xF12
`define	csr_addr_mimped		0xF13
`define	csr_addr_mhartid		0xF14
*************************************************************/
assign	csr_read_data	=	({32{csr_choice_mstatus}}	& mstatus)
								|	({32{csr_choice_misa}}		& misa)
								|	({32{csr_choice_mie}}		& mie)
								|	({32{csr_choice_mtvec}}		& mtvec)
								|	({32{csr_choice_mscratch}}	& mscratch)
								|	({32{csr_choice_mepc}}		& mepc)
								|	({32{csr_choice_mcause}}	& mcause)
								|	({32{csr_choice_mtval}}		& mtval)
								|	({32{csr_choice_mip}}		& mip)
								|	({32{csr_choice_mvendorid}}& mvendorid)
								|	({32{csr_choice_marchid}}	& marchid)
								|	({32{csr_choice_mimpid}}	& mimpid)
								|	({32{csr_choice_mhartid}}	& mhartid);
/********************************************************************

CSR运算
根据当前csr_read_data和当前需要进行的CSR指令来计算出需要写的CSR寄存器新值
生成csr_new

**********************************************************************/

wire	cmd_CSRRW	=	csr_cmd[5];
wire	cmd_CSRRS	=	csr_cmd[4];
wire	cmd_CSRRC	=	csr_cmd[3];
wire	cmd_CSRRWI	=	csr_cmd[2];
wire	cmd_CSRRSI	=	csr_cmd[1];
wire	cmd_CSRRCI	=	csr_cmd[0];

//op1是csr_read_data
wire	[31:0]	csr_new_op2	=	({32{cmd_CSRRW|cmd_CSRRS|cmd_CSRRC}} & csr_write_data)
									|	({32{cmd_CSRRWI|cmd_CSRRSI|cmd_CSRRCI}} & {27'b0,csr_imm});

assign	csr_new	=	({32{cmd_CSRRW|cmd_CSRRWI}} & csr_read_data)
						|	({32{cmd_CSRRW|cmd_CSRRWI}} & (csr_read_data|csr_new_op2))
						|	({32{cmd_CSRRW|cmd_CSRRWI}} & (csr_read_data&(!csr_new_op2)));
/***************************************************************************************/




endmodule



