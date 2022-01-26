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

module core_c1_top(
// clock and reset signals
input           clk,
input           rst_n,
//--------------------------------------------
// master 0: ifu instrucrtion fetch
//--------------------------------------------
// read address channel
output          sb_arvalid_m0,
input           sb_arready_m0,
output  [31:0]  sb_araddr_m0,
// read data channel
input           sb_rvalid_m0,
output          sb_rready_m0,
input   [31:0]  sb_rdata_m0,
// write channel
output          sb_wvalid_m0,
input           sb_wready_m0,
output  [31:0]  sb_waddr_m0,
output  [31:0]  sb_wdata_m0,
output  [3:0]   sb_wstrb_m0,
// write response channel
input           sb_bvalid_m0,
output          sb_bready_m0,
input           sb_bresp_m0,
//--------------------------------------------
// master 1: load/store instruction
//--------------------------------------------
// read address channel
output          sb_arvalid_m1,
input           sb_arready_m1,
output  [31:0]  sb_araddr_m1,
// read data channel
input           sb_rvalid_m1,
output          sb_rready_m1,
input   [31:0]  sb_rdata_m1,
// write channel
output          sb_wvalid_m1,
input           sb_wready_m1,
output  [31:0]  sb_waddr_m1,
output  [31:0]  sb_wdata_m1,
output  [3:0]   sb_wstrb_m1,
// write response channel
input           sb_bvalid_m1,
output          sb_bready_m1,
input           sb_bresp_m1,
// interrupt input
input           plic_intr
);

wire          ifu_pause;
wire          exu_pause;
wire          ifu_pc_valid_biu;
wire  [31:0]  ifu_pc_addr_biu;
wire  [31:0]  ifu_inst_biu;
wire          ifu_inst_valid_biu;
wire          mem_load_valid;
wire  [31:0]  mem_load_addr;
wire  [31:0]  mem_load_data;
wire          mem_store_valid;
wire  [31:0]  mem_store_addr;
wire  [31:0]  mem_store_data;
wire  [1:0]   mem_store_size;

wire  [4:0]   regs_rs1_idx;
wire  [4:0]   regs_rs2_idx;
wire  [31:0]  regs_rs1_data;
wire  [31:0]  regs_rs2_data;
wire          regs_rd_valid;
wire  [4:0]   regs_rd_idx;
wire  [31:0]  regs_rd_data;

wire          pc_wash_req_e;
wire          pc_wash_req_b;
wire  [31:0]  pc_wash_addr_e;
wire  [31:0]  pc_wash_addr_b;

// ifu to exu regs
wire          ifu_inst_valid;
wire          exu_inst_valid;
wire  [31:0]  ifu_inst;
wire  [31:0]  exu_inst;
wire  [31:0]  ifu_pc_addr;
wire  [31:0]  exu_pc_addr;
wire  [31:0]  exu_rs1_data;
wire  [31:0]  exu_rs2_data;
wire  [4:0]   ifu_rd_idx;
wire  [4:0]   exu_rd_idx;
wire  [31:0]  ifu_imm32;
wire  [31:0]  exu_imm32;
wire  [54:0]  ifu_cmd_op_bus;
wire  [54:0]  exu_cmd_op_bus;
wire  [4:0]   exu_csr_imm;
// end of ifu to exu regs

wire  [11:0]  csr_addr;         //输入需要读写的寄存器地址
wire  [31:0]  csr_read_data;    //输出读到的值
wire  [31:0]  csr_write_data;   //输入要写的值
wire          csr_en;           //输入CSR读写使能
wire  [5:0]   csr_cmd;          //输入CSR读写操作
wire  [4:0]   csr_imm;          //CSR指令中的立即数

//以下端口来自异常和中断系统
wire          cmd_mret;
wire          clic_exception_out;     //异常输入
wire          clic_intr_out;     //中断输入
wire  [7:0]   clic_exception_code;//异常编号
wire  [7:0]   clic_intr_code;//中断编号
wire  [31:0]  exu_o_pc_next;

wire          exu_exception_illegal_instruction;
wire          exu_exception_breakpoint;
wire          exu_exception_ecall_mmode;

core_c1_biu u_core_c1_biu(
  .clk              (clk),
  .rst_n            (rst_n),

  .ifu_pc_addr      (ifu_pc_addr_biu),
  .ifu_pc_valid     (ifu_pc_valid_biu),
  .ifu_inst         (ifu_inst_biu),
  .ifu_inst_valid   (ifu_inst_valid_biu),
  .ifu_pause        (ifu_pause),
  
  .sb_arvalid_m0    (sb_arvalid_m0),
  .sb_arready_m0    (sb_arready_m0),
  .sb_araddr_m0     (sb_araddr_m0),
  .sb_rvalid_m0     (sb_rvalid_m0),
  .sb_rready_m0     (sb_rready_m0),
  .sb_rdata_m0      (sb_rdata_m0),
  .sb_wvalid_m0     (sb_wvalid_m0),
  .sb_wready_m0     (sb_wready_m0),
  .sb_waddr_m0      (sb_waddr_m0),
  .sb_wdata_m0      (sb_wdata_m0),
  .sb_wstrb_m0      (sb_wstrb_m0),
  .sb_bvalid_m0     (sb_bvalid_m0),
  .sb_bready_m0     (sb_bready_m0),
  .sb_bresp_m0      (sb_bresp_m0),
  
  .mem_load_valid   (mem_load_valid),
  .mem_load_addr    (mem_load_addr),
  .mem_load_data    (mem_load_data),
  .mem_store_valid  (mem_store_valid),
  .mem_store_addr   (mem_store_addr),
  .mem_store_data   (mem_store_data),
  .mem_store_size   (mem_store_size),
  .exu_pause        (exu_pause),
  
  .sb_arvalid_m1    (sb_arvalid_m1),
  .sb_arready_m1    (sb_arready_m1),
  .sb_araddr_m1     (sb_araddr_m1),
  .sb_rvalid_m1     (sb_rvalid_m1),
  .sb_rready_m1     (sb_rready_m1),
  .sb_rdata_m1      (sb_rdata_m1),
  .sb_wvalid_m1     (sb_wvalid_m1),
  .sb_wready_m1     (sb_wready_m1),
  .sb_waddr_m1      (sb_waddr_m1),
  .sb_wdata_m1      (sb_wdata_m1),
  .sb_wstrb_m1      (sb_wstrb_m1),
  .sb_bvalid_m1     (sb_bvalid_m1),
  .sb_bready_m1     (sb_bready_m1),
  .sb_bresp_m1      (sb_bresp_m1)
);

core_c1_regs u_core_c1_regs (
  .rst_n            (rst_n          ),
  .clk              (clk            ),
  .rs1_idx          (regs_rs1_idx   ),
  .rs2_idx          (regs_rs2_idx   ),
  .rs1_data         (regs_rs1_data  ),
  .rs2_data         (regs_rs2_data  ),
  .rd_valid         (regs_rd_valid  ),
  .rd_idx           (regs_rd_idx    ),
  .rd_data          (regs_rd_data   )
);

core_c1_ifu u_core_c1_ifu (
  .clk              (clk),
  .rst_n            (rst_n),
  .i_pc_wash_req_e  (pc_wash_req_e),
  .i_pc_wash_req_b  (pc_wash_req_b),
  .i_pc_wash_addr_e (pc_wash_addr_e),
  .i_pc_wash_addr_b (pc_wash_addr_b),
  .i_ifu_pause      (ifu_pause),

  .o_pc_valid_biu   (ifu_pc_valid_biu),
  .o_pc_addr_biu    (ifu_pc_addr_biu),
  .i_inst_valid_biu (ifu_inst_valid_biu),
  .i_inst_biu       (ifu_inst_biu),	

  .o_inst_valid_exu (ifu_inst_valid),
  .o_inst_exu       (ifu_inst),
  .o_pc_addr_exu    (ifu_pc_addr),
  .o_rs1_idx        (regs_rs1_idx),
  .o_rs2_idx        (regs_rs2_idx),
  .o_rd_idx         (ifu_rd_idx),
  .o_imm32          (ifu_imm32),
  .o_cmd_op_bus     (ifu_cmd_op_bus),

  .i_rs1_data       (regs_rs1_data),
  .o_mem_load_valid (mem_load_valid),
  .o_mem_load_addr  (mem_load_addr)
);


core_c1_ifu_to_exu_reg u_core_c1_ifu_to_exu_reg(
  .clk              (clk),
  .rst_n            (rst_n),
  .exu_pause        (exu_pause),

  .ifu_inst_valid   (ifu_inst_valid),
  .ifu_inst         (ifu_inst),
  .ifu_pc_addr      (ifu_pc_addr),
  .regs_rs1_data    (regs_rs1_data),
  .regs_rs2_data    (regs_rs2_data),
  .ifu_rd_idx       (ifu_rd_idx),
  .ifu_imm32        (ifu_imm32),
  .ifu_cmd_op_bus   (ifu_cmd_op_bus),
  .ifu_rs1_idx      (regs_rs1_idx),

  .exu_inst_valid   (exu_inst_valid),
  .exu_inst         (exu_inst),
  .exu_pc_addr      (exu_pc_addr),
  .exu_rs1_data     (exu_rs1_data),
  .exu_rs2_data     (exu_rs2_data),
  .exu_rd_idx       (exu_rd_idx),
  .exu_imm32        (exu_imm32),
  .exu_cmd_op_bus   (exu_cmd_op_bus),
  .exu_csr_imm      (exu_csr_imm)
);

core_c1_exu u_core_c1_exu(

  .exu_pause        (exu_pause),
  
  .exu_inst_valid   (exu_inst_valid),	
  .exu_pc_addr      (exu_pc_addr),
  .exu_rs1_data     (exu_rs1_data),
  .exu_rs2_data     (exu_rs2_data),
  .exu_imm32        (exu_imm32),
  
  .exu_cmd_op_bus   (exu_cmd_op_bus),
  
  .exu_csr_imm      (exu_csr_imm),
  
  .exu_rd_idx       (regs_rd_idx),		//目标寄存器idxx
  .exu_rd_data      (regs_rd_data),
  .exu_rd_valid     (regs_rd_valid),
  
  .memory_load_data (mem_load_data),
  .memory_store_addr(mem_store_addr),
  .memory_store_en  (mem_store_valid),
  .memory_store_data(mem_store_data),
  .memory_store_size(mem_store_size),
  //CSR操作
  .csr_addr         (csr_addr),			//输入需要读写的寄存器地址
  .csr_read_data    (csr_read_data),		//输出读到的值
  .csr_write_data   (csr_write_data),	//输入要写的值
  .csr_en           (csr_en),				//输入CSR读写使能
  .csr_cmd          (csr_cmd),				//输入CSR读写操作
  .csr_imm          (csr_imm),				//CSR指令中的立即数
  
  .exception_illegal_instruction  (exu_exception_illegal_instruction),
  .exception_breakpoint           (exu_exception_breakpoint),
  .exception_ecall_mmode          (exu_exception_ecall_mmode),
  
  .cmd_mret         (cmd_mret),
  .exu_o_pc_next    (exu_o_pc_next),
  
  .pc_wash_req_b    (pc_wash_req_b),
  .pc_wash_addr_b   (pc_wash_addr_b)

);


core_c1_csr u_core_c1_csr(
  .clk              (clk),
  .rst_n            (rst_n),
  .csr_addr         (csr_addr),
  .csr_read_data    (csr_read_data),
  .csr_write_data   (csr_write_data),
  .csr_en           (csr_en),
  .csr_cmd          (csr_cmd),
  .csr_imm          (csr_imm),

  .cmd_mret         (cmd_mret),
  .in_exception     (clic_exception_out),
  .in_interrupt     (clic_intr_out),
  .in_exception_code(clic_exception_code),
  .in_interrupt_code(clic_intr_code),
  .pc_address       (exu_pc_addr),
  .pc_address_next  (exu_o_pc_next),
  .pc_wash_addr_e   (pc_wash_addr_e),
  .pc_wash_req_e    (pc_wash_req_e)
);

core_c1_clic u_core_c1_clic(

  .interrupt_plic_in              (plic_intr),
  .interrupt_soft_in              (1'b0),
  .interrupt_time_in              (1'b0),
  .exception_illegal_instruction  (exu_exception_illegal_instruction),
  .exception_breakpoint           (exu_exception_breakpoint),
  .exception_ecall_mmode          (exu_exception_ecall_mmode),

  .interrupt_out                  (clic_intr_out),
  .interrupt_code                 (clic_intr_code),
  .exception_out                  (clic_exception_out),
  .exception_code                 (clic_exception_code)

);

endmodule
