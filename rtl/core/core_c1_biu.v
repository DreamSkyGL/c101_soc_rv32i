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

module core_c1_biu (

//--------------------------------------------
// master 0: ifu instrucrtion fetch
//--------------------------------------------
input   [31:0]  ifu_pc_addr,
input           ifu_pc_valid,
output  [31:0]  ifu_inst,
output          ifu_inst_valid,

output          ifu_pause,

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
input           mem_load_valid,
input   [31:0]  mem_load_addr,
output  [31:0]  mem_load_data,
input           mem_store_valid,
input   [31:0]  mem_store_addr,
input   [31:0]  mem_store_data,
input   [1:0]   mem_store_size,

output          exu_pause,

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

input           clk,
input           rst_n

);

wire  m0_read_pause;
wire  m1_read_pause;
wire  m1_write_pause;

assign ifu_pause  = m0_read_pause | m1_read_pause | m1_write_pause;
assign exu_pause    = m1_read_pause | m1_write_pause;

//--------------------------------------------
// master 0: ifu pc fetch
//--------------------------------------------

reg           sb_arvalid_m0_r;
reg   [31:0]  sb_araddr_m0_r;
reg           sb_arflag_m0_r;     //ar通道握手成功标志
reg   [31:0]  sb_rdata_m0_r;
reg           sb_rvalid_m0_r;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    sb_arvalid_m0_r     <=  1'b0;
    sb_araddr_m0_r      <=  32'b0;
  end
  //给出了valid，但没有回ready,将valid保持直到收到ready
  else if(sb_arvalid_m0 & !sb_arready_m0) begin
    sb_arvalid_m0_r   <=  sb_arvalid_m0;
    sb_araddr_m0_r    <=  sb_araddr_m0;
  end
  else if(sb_arready_m0) begin
    sb_arvalid_m0_r   <=  1'b0;
  end
end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    sb_arflag_m0_r      <=  1'b0;
    sb_rdata_m0_r       <=  32'b0;
  end
  else if(sb_rvalid_m0 & sb_rready_m0) begin
    sb_rdata_m0_r     <=  sb_rdata_m0;
    if(~(sb_arvalid_m0 & sb_arready_m0)) begin
      sb_arflag_m0_r    <=  1'b0;
    end
  end
  else if(sb_arvalid_m0 & sb_arready_m0) begin
    sb_arflag_m0_r    <=  1'b1;
  end
end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    sb_rvalid_m0_r  <=  1'b0;
  end
  else if(ifu_pause & sb_rvalid_m0 & sb_rready_m0) begin
    sb_rvalid_m0_r  <=  sb_rvalid_m0;
  end
  else if(!ifu_pause) begin
    sb_rvalid_m0_r  <= 1'b0;
  end
end

//暂停原因：
//arvalid给出，但没有回ready，使得arvalid被寄存。
//ar通道握手成功，但之后没有传回rvalid
assign  m0_read_pause = sb_arvalid_m0_r | (sb_arflag_m0_r & ~sb_rvalid_m0);
// read address channel
assign  sb_arvalid_m0 = ifu_pc_valid | sb_arvalid_m0_r;
assign  sb_araddr_m0  = ifu_pc_valid ? ifu_pc_addr : sb_araddr_m0_r;
// read data channel
assign  sb_rready_m0  = 1'b1;
assign  ifu_inst        = sb_rvalid_m0 ? sb_rdata_m0 : sb_rdata_m0_r;
assign  ifu_inst_valid  = sb_rvalid_m0 | sb_rvalid_m0_r;
// write channel
assign  sb_wvalid_m0  = 1'b0;
assign  sb_waddr_m0   = 32'b0;
assign  sb_wdata_m0   = 32'b0;
assign  sb_wstrb_m0   = 4'b0;
// write response channel
assign  sb_bready_m0  = 1'b1;

//--------------------------------------------
// master 1: load/store instruction
//--------------------------------------------

reg           sb_arvalid_m1_r;
reg   [31:0]  sb_araddr_m1_r;
reg           sb_arflag_m1_r;     //ar通道握手成功标志
reg   [31:0]  sb_rdata_m1_r;

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    sb_arvalid_m1_r     <=  1'b0;
    sb_araddr_m1_r      <=  32'b0;
  end
  //给出了valid，但没有回ready,将valid保持直到收到ready
  else if(sb_arvalid_m1 & !sb_arready_m1) begin
    sb_arvalid_m1_r   <=  sb_arvalid_m1;
    sb_araddr_m1_r    <=  sb_araddr_m1;
  end
  else if(sb_arready_m1) begin
    sb_arvalid_m1_r   <=  1'b0;
  end
end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    sb_arflag_m1_r      <=  1'b0;
    sb_rdata_m1_r       <=  32'b0;
  end
  else if(sb_rvalid_m1 & sb_rready_m1) begin
    sb_rdata_m1_r     <=  sb_rdata_m1;
    if(~(sb_arvalid_m1 & sb_arready_m1)) begin
      sb_arflag_m1_r    <=  1'b0;
    end
  end
  else if(sb_arvalid_m1 & sb_arready_m1) begin
    sb_arflag_m1_r    <=  1'b1;
  end
end

//暂停原因
//arvalid给出，但没有回ready，使得arvalid被寄存。
//ar通道握手成功，但之后没有传回rvalid
assign  m1_read_pause = sb_arvalid_m1_r | (sb_arflag_m1_r & ~sb_rvalid_m1);
// read address channel
assign  sb_arvalid_m1 = mem_load_valid | sb_arvalid_m1_r;
assign  sb_araddr_m1  = mem_load_valid ? mem_load_addr : sb_araddr_m1_r;
// read data channel
assign  sb_rready_m1  = 1'b1;
assign  mem_load_data = sb_rvalid_m1 ? sb_rdata_m1 : sb_rdata_m1_r;



reg           sb_wvalid_m1_r;
reg   [31:0]  sb_waddr_m1_r;
reg   [31:0]  sb_wdata_m1_r;
reg   [3:0]   sb_wstrb_m1_r;
reg           sb_wflag_m1_r;     //w通道握手成功标志

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    sb_wvalid_m1_r      <=  1'b0;
    sb_waddr_m1_r       <=  32'b0;
    sb_wdata_m1_r       <=  32'b0;
    sb_wstrb_m1_r       <=  4'b0;
  end
  else begin
    //给出了valid，但没有回ready,将valid保持直到收到ready
    if(sb_wvalid_m1 & !sb_wready_m1) begin
      sb_wvalid_m1_r    <=  sb_wvalid_m1;
      sb_waddr_m1_r     <=  sb_waddr_m1;
      sb_wdata_m1_r     <=  sb_wdata_m1;
      sb_wstrb_m1_r     <=  sb_wstrb_m1;
    end
    else if(sb_wready_m1) begin
      sb_wvalid_m1_r    <=  1'b0;
    end
  end
end

always @ (posedge clk or negedge rst_n) begin
  if(!rst_n) begin
    sb_wflag_m1_r       <=  1'b0;
  end
  else begin
    if(sb_bvalid_m1 & sb_bready_m1) begin
      if(~(sb_wvalid_m1 & sb_wready_m1)) begin
        sb_wflag_m1_r     <=  1'b0;
      end
    end
    else if(sb_wvalid_m1 & sb_wready_m1) begin
      sb_wflag_m1_r     <=  1'b1;
    end
  end
end

wire  [3:0] mem_store_strb;
// only support 32bit align
assign      mem_store_strb  = mem_store_size == 2'b00 ? 4'h1
                            : mem_store_size == 2'b01 ? 4'h3
                            : mem_store_size == 2'b10 ? 4'hf
                            : 4'h0;
//暂停原因
//wvalid给出，但没有回ready，使得wvalid被寄存。
//w通道握手成功，但之后没有传回bvalid
assign  m1_write_pause = sb_wvalid_m1_r | (sb_wflag_m1_r & ~sb_bvalid_m1);
// write channel
assign  sb_wvalid_m1  = mem_store_valid | sb_wvalid_m1_r;
assign  sb_waddr_m1   = mem_store_valid ? mem_store_addr : sb_waddr_m1_r;
assign  sb_wdata_m1   = mem_store_valid ? mem_store_data : sb_wdata_m1_r;
assign  sb_wstrb_m1   = mem_store_valid ? mem_store_strb : sb_wstrb_m1_r;
// write response channel
assign  sb_bready_m1  = 1'b1;

endmodule
