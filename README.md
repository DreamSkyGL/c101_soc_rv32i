# c101_soc_rv32i
An open source RISC-V RV32I SoC designed by GanLing

## 介绍
这是一个两级流水的RISC-V RV32I处理器及简单的SoC系统，可以用于了解CPU原理及内部结构，也可以在其基础上集成更多功能来做简单的控制。CPU行为不能保证完全符合RISC-V架构的规范，主要是特权架构规范部分还没有细看，不过之后我也会边啃文档边完善。

### 项目名称说明
c1：c取自音名CDEFGAB中的C，表示通用处理器第一代
01：第一代SoC，也表示最简SoC，1前面的0用于分隔

### CPU参数
1. 指令集：RV32I
2. 两级流水线：取指+译码、执行
3. 无分支预测单元
4. 支持外部中断，无软件中断和架构定义的定时器中断
5. 总线为根据AXI4 Lite进一步简化而来的Simple Bus（SB），下文会有介绍
6. 180nm工艺下可达180MHz，14nm工艺下可达1GHz（可能不准确，但目前综合结果来看未报violation），Altera Cyclone IV系列FPGA上频率可达72MHz，资源占用不到4K逻辑单元

### SoC配置
1. 4KB指令存储器（imem），4KB数据存储器（dmem），均可读可写，但由于没有留程序下载接口，程序需要提前准能好与代码一起生成FPGA配置文件，仿真时需要在tb中初始化指令存储器。imem基地址：0x0000_0000，dmem基地址0x4000_0000（2022.01.27版本以前imem和dmem的基地址是相反的）
2. 两路16Bit的IO口，第一路基地址0x8000_0000，第二路基地址0xC000_0000
3. 预计版本将添加C工程例程，并增加串口下载程序功能

### 总线结构
CPU有两路总线，ibus和dbus，接口均为sb口。
（2022.01.28版本）
dbus通过一个pipe模块打拍，以与外界时序隔离，然后连接到一个1m4s模块，其中s0与ibus通过一个2m1s模块连接到imem；s1连接到dmem，s2和s3连接到IO口。
这种总线结构保证了在不执行访存指令时，CPU可以每一个时钟周期都取到一条指令，较上一版总线相比性能提升很大，且对时序几乎没有影响，但取指单元被限制在了只能从imem取指令，也就是程序只能在imem中执行。当执行访存指令时，由于pipe模块的打拍，流水线将暂停两个时钟周期（当访存地址为imem时为3个时钟周期）。
（2022.01.27版本）
ibus和dbus会经过2m1s模块合并为1路总线后经过pipe模块打拍，以与外界隔离。打拍后的总线经过1m4s模块，分别连到指令存储器、数据存储器、GPIOA和GPIOB。
这类总线的效率极低，CPU取指单元每次需要3个时钟周期才能取到一条指令，后续会优化总线结构，做到每个时钟周期都能取到指令。

### SB总线介绍
SB总线是在AXI4 Lite的基础上极度简化而来，有四个通道：
Read Address Channel、Read Data Channel、Write Channel、Write Response Channel（这个通道其实也可以省去，不过为了后续功能升级，保留了B通道）。
支持滞外交易，不支持乱序返回，时序与AXI一致。接口如下：
ar channel：
  arvalid
  arready
  araddr
r channel
  rvalid
  rready
  rdata
w channel
  wvalid
  wready
  waddr
  wdata
  wstrb
b channel
  bvalid
  bready
  bresp

## 使用
### 仿真环境
待补充
### FPGA环境
#### Intel FPGA
使用Quartus，将rtl代码添加到工程即可。imem和dmem将会自动被综合为存储器ip。若需要不同的时钟频率，自行添加PLL模块。



## 更新说明
2022.01.28
更新总线结构，使每个时钟周期都能取到指令
修改1m4s模块中的bug

2022.01.27
更新项目介绍

2022.01.27
先把目前的rtl代码更新上来，介绍和仿真环境、BSP等内容等春节假期找时间更新吧
