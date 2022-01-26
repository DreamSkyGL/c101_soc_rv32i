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

module core_c1_clic (

input	interrupt_plic_in,
input	interrupt_soft_in,
input	interrupt_time_in,
//input [1:0] interrupt_mode,
//input	exception_addr_misaligned,
//input exception_addr_access_fault,
input exception_illegal_instruction,
input	exception_breakpoint,
//input	exception_load_addr_misaligned,
//input	exception_load_addr_access_fault,
//input	exception_store_addr_misaligned,
//input	exception_store_addr_access_fault,
//input exception_ecall_umode,
//input exception_ecall_smode,
input exception_ecall_mmode,
//input exception_instruction_page_fault,
//input exception_load_oage_fault,
//input exception_store_page_fault,

output	interrupt_out,
output	[7:0]		interrupt_code,
output	exception_out,
output	[7:0]		exception_code

);

assign	interrupt_out	=	interrupt_plic_in | interrupt_soft_in | interrupt_time_in;
assign	interrupt_code	=	interrupt_soft_in ? 8'd3
								:	interrupt_time_in ? 8'd7
								:	interrupt_plic_in ? 8'd11
								:	8'd0;
/**************************************************************************************/
/*
assign	exception_out	=	exception_addr_misaligned
								|	exception_addr_access_fault
								| exception_illegal_instruction
								|	exception_breakpoint
								|	exception_load_addr_misaligned
								|	exception_load_addr_access_fault
								|	exception_store_addr_misaligned
								|	exception_store_addr_access_fault
								| exception_ecall_umode
								| exception_ecall_smode
								| exception_ecall_mmode
								| exception_instruction_page_fault
								| exception_load_oage_fault
								| exception_store_page_fault;
assign	exception_code	=	exception_addr_misaligned				? 8'd0
								:	exception_addr_access_fault			? 8'd1
								:	exception_illegal_instruction			? 8'd2
								:	exception_breakpoint						? 8'd3
								:	exception_load_addr_misaligned		? 8'd4
								:	exception_load_addr_access_fault		? 8'd5
								:	exception_store_addr_misaligned		? 8'd6
								:	exception_store_addr_access_fault	? 8'd7
								:	exception_ecall_umode					? 8'd8
								:	exception_ecall_smode					? 8'd9
								:	exception_ecall_mmode					? 8'd11
								:	exception_instruction_page_fault		? 8'd12
								:	exception_load_oage_fault				? 8'd13
								:	exception_store_page_fault				? 8'd15
								:	8'd0;
*/
assign	exception_out	=	exception_illegal_instruction
								|	exception_breakpoint
								|	exception_ecall_mmode;
assign	exception_code	=	exception_illegal_instruction			? 8'd2
								:	exception_breakpoint						? 8'd3
								:	exception_ecall_mmode					? 8'd11
								:	8'd0;

endmodule


