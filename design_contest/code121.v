/**************************************************************************/
/* code121.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`timescale 1ns/100ps
`default_nettype none

/**************************************************************************/
`define HALT {6'h4, 5'd0, 5'd0, 16'hffff} // L1: beq  $0, $0, L1
/**************************************************************************/

/***** top module for verification *****/

module m_top (); 
  reg r_clk=0; initial forever #50 r_clk = ~r_clk;
  wire [31:0] w_led;

  m_proc11 p (r_clk, w_led);

  always@(posedge r_clk)
    if(p.w_we) $write("%08x\n", p.w_rslt2);

  always@(posedge r_clk) if(p.w_ir==`HALT) $finish();
endmodule


/***** top module for simulation *****/
module m_top_debug (); 
  reg r_clk=0; initial forever #50 r_clk = ~r_clk;
  wire [31:0] w_led;

  reg [31:0] r_cnt = 0;
  always@(posedge r_clk)  r_cnt <= r_cnt + 1;
  
  m_proc11 p (r_clk, w_led);

  initial $write("clock : r_pc     w_ir     w_rrs    w_rrt2   r_rslt2  r_led\n");
  always@(posedge r_clk) begin
      $write("%6d: %x %x %x %x %x %x ", r_cnt,
            p.r_pc, p.w_ir, p.w_rrs, p.w_rrt2, p.w_rslt2, w_led);
      if(p.w_insn_add)  $write("add");
      if(p.w_insn_sllv) $write("sllv");
      if(p.w_insn_srlv) $write("srlv");
      if(p.w_insn_addi) $write("addi");
      if(p.w_insn_lw)   $write("lw");
      if(p.w_insn_sw)   $write("sw");
      if(p.w_insn_beq)  $write("beq");
      if(p.w_insn_bne)  $write("bne");
      $write("\n");
  end

  always@(posedge r_clk) if(p.w_ir==`HALT) $finish();
endmodule


/***** main module for FPGA implementation *****/

module m_main (w_clk, w_led);
  input  wire w_clk;
  output wire [3:0] w_led;

  wire w_clk2, w_locked;
  clk_wiz_0 clk_w0 (w_clk2, 0, w_locked, w_clk);
  
  wire [31:0] w_dout;
  m_proc07 p (w_clk2, w_dout);

  vio_0 vio_00(w_clk2, w_dout);

  reg [3:0] r_led = 0;
  always @(posedge w_clk2) 
    r_led <= {^w_dout[31:24], ^w_dout[23:16], ^w_dout[15:8], ^w_dout[7:0]};
  assign w_led = r_led;
endmodule


module m_amemory (w_clk, w_addr, w_we, w_din, w_dout);
  input  wire w_clk, w_we;
  input  wire [10:0] w_addr;
  input  wire [31:0] w_din;
  output wire [31:0] w_dout;
  reg [31:0] 	      cm_ram [0:2047]; // 4K word (2048 x 32bit) memory
  always @(posedge w_clk) if (w_we) cm_ram[w_addr] <= w_din;
  assign #20 w_dout = cm_ram[w_addr];

`include "program.txt"
endmodule

module m_memory (w_clk, w_addr, w_we, w_din, w_dout);
  input  wire w_clk, w_we;
  input  wire [11:0] w_addr;
  input  wire [31:0] w_din;
  output wire [31:0] w_dout;
  reg [31:0] 	      cm_ram [0:2047]; // 4K word (2048 x 32bit) memory
  always @(posedge w_clk) if (w_we) cm_ram[w_addr] <= w_din;
  assign #20 w_dout = cm_ram[w_addr];

`include "program.txt"
endmodule

module m_regfile (w_clk, w_rr1, w_rr2, w_wr, w_we, w_wdata, w_rdata1, w_rdata2);
  input  wire        w_clk;
  input  wire [4:0]  w_rr1, w_rr2, w_wr;
  input  wire [31:0] w_wdata;
  input  wire        w_we;
  output wire [31:0] w_rdata1, w_rdata2;
  
  reg [31:0] r[0:31];
  assign w_rdata1 = (w_rr1==0) ? 0 : r[w_rr1];
  assign w_rdata2 = (w_rr2==0) ? 0 : r[w_rr2];
  always @(posedge w_clk) if(w_we) r[w_wr] <= w_wdata;
  
  initial r[1] = 1;
  initial r[2] = 2;
endmodule

module m_proc07 (w_clk, r_led);
  input  wire w_clk;
  output reg [31:0] r_led;
  initial r_led = 0;
  
  reg  [31:0] r_pc = 0;
  wire [31:0] w_ir, w_rrs, w_rrt;
  wire [31:0] w_rrt2, w_rslt, w_ldd, w_rslt2;
  wire  [5:0] w_op    = w_ir[31:26];
  wire  [4:0] w_rs    = w_ir[25:21];
  wire  [4:0] w_rt    = w_ir[20:16];
  wire  [4:0] w_rd    = w_ir[15:11];
  wire [15:0] w_imm   = w_ir[15: 0];
  wire  [5:0] w_funct = w_ir[ 5: 0];

  wire w_insn_add  = (w_op==0 && w_funct==6'h20);
  wire w_insn_sllv = (w_op==0 && w_funct==6'h4);
  wire w_insn_srlv = (w_op==0 && w_funct==6'h6);
  wire w_insn_addi = (w_op==6'h8);
  wire w_insn_lw   = (w_op==6'h23);
  wire w_insn_sw   = (w_op==6'h2b);
  wire w_insn_beq  = (w_op==6'h4);
  wire w_insn_bne  = (w_op==6'h5);
  
  wire [31:0] w_pc4 = r_pc + 4;
  wire [31:0] w_imm32 = {{16{w_imm[15]}}, w_imm};
  wire [31:0] w_tpc = w_pc4 + {w_imm32[29:0], 2'h0};
  wire w_taken = (w_insn_beq && w_rrs==w_rrt2) || (w_insn_bne && w_rrs!=w_rrt2);
  always @(posedge w_clk) r_pc <= #3 (w_taken) ? w_tpc : w_pc4;
  
  m_amemory m_imem (w_clk, r_pc[12:2], 1'd0, 32'd0, w_ir);

  wire  [4:0] w_rd2 = (w_insn_add | w_insn_sllv | w_insn_srlv) ? w_rd : w_rt;
  wire w_we = w_insn_add | w_insn_addi | w_insn_sllv | w_insn_srlv | w_insn_lw;

  m_regfile m_regs (w_clk, w_rs, w_rt, w_rd2, w_we, w_rslt2, w_rrs, w_rrt);

  assign w_rrt2 = (w_insn_addi | w_insn_lw | w_insn_sw) ? w_imm32 : w_rrt;

  assign #10 w_rslt = (w_insn_sllv) ? w_rrs << w_rrt2[4:0] :
          (w_insn_srlv) ? w_rrs >> w_rrt2[4:0] : w_rrs + w_rrt2;

  m_amemory m_dmem (w_clk, w_rslt[12:2], w_insn_sw, w_rrt, w_ldd);
  
  assign w_rslt2 = (w_insn_lw) ? w_ldd : w_rslt;

  always @(posedge w_clk) r_led <= (w_we && w_rd2==30) ? w_rslt2 : r_led;
endmodule

module m_proc11 (w_clk, r_rout);
  input wire w_clk;
  output reg [31:0] r_rout;
  reg r_halt = 0;
  wire w_rst = 0;
  reg [31:0] IfId_pc4=0; // pipe regs
  reg [31:0] IdEx_rrs=0, IdEx_rrt=0, IdEx_rrt2=0; //
  reg [31:0] ExMe_rslt=0, ExMe_rrt=0; //
  reg [31:0] MeWb_rslt=0; //
  reg [5:0] IdEx_op=0, ExMe_op=0, MeWb_op=0, IdEx_funct=0; //
  reg [31:0] IfId_pc=0, IdEx_pc=0, ExMe_pc=0, MeWb_pc=0; //
  reg [4:0] IfId_rd2=0, IdEx_rd2=0, ExMe_rd2=0, MeWb_rd2=0;//
  reg IfId_w=0, IdEx_w=0, ExMe_w=0, MeWb_w=0; //
  reg IfId_we=0, IdEx_we=0, ExMe_we=0; //
  wire [31:0] IfId_ir, MeWb_ldd; // note
  /**************************** IF stage **********************************/
  wire w_taken;
  wire [31:0] w_tpc;
  reg [31:0] r_pc = 0;
  wire [31:0] w_pc4 = r_pc + 4;
  m_memory m_imem (w_clk, r_pc[13:2], 1'b0, 32'b0, IfId_ir);
  always @(posedge w_clk) begin
  r_pc <= #3 (w_rst | r_halt) ? 0 : (w_taken) ? w_tpc : w_pc4;
  IfId_pc <= #3 r_pc;
  IfId_pc4 <= #3 w_pc4;
  end
/**************************** ID stage ***********************************/
  wire [31:0] w_rrs, w_rrt, w_rslt2;

  wire [5:0] w_op = IfId_ir[31:26];
  wire [4:0] w_rs = IfId_ir[25:21];
  wire [4:0] w_rt = IfId_ir[20:16];
  wire [4:0] w_rd = IfId_ir[15:11];
  wire [4:0] w_rd2 = (w_op!=0) ? w_rt : w_rd;
  // = wire  [4:0] w_rd2 = (w_insn_add | w_insn_sllv | w_insn_srlv) ? w_rd : w_rt;
  wire [15:0] w_imm = IfId_ir[15:0];
  wire [5:0] w_funct = IfId_ir[5:0];
  // ALUの計算の前処理
  wire w_insn_add = (w_op==0 && w_funct==6'h20);
  wire w_insn_sllv = (w_op==0 && w_funct==6'h4);
  wire w_insn_srlv = (w_op==0 && w_funct==6'h6);
  wire w_insn_addi = (w_op==6'h8);
  wire w_insn_lw = (w_op==6'h23);
  wire w_insn_sw = (w_op==6'h2b);
  wire w_insn_beq = (w_op==6'h4);
  wire w_insn_bne = (w_op==6'h5);
  //
  wire w_we = w_insn_add | w_insn_addi | w_insn_sllv | w_insn_srlv | w_insn_lw ;
  wire [31:0] w_imm32 = {{16{w_imm[15]}}, w_imm};
  wire [31:0] w_rrt2 = (w_insn_addi | w_insn_lw | w_insn_sw) ? w_imm32 : w_rrt;
  //
  assign w_tpc = IfId_pc4 + {w_imm32[29:0], 2'h0};
  assign w_taken = (w_op==`BNE && w_rrs!=w_rrt);

  m_regfile m_regs (w_clk, w_rs, w_rt, MeWb_rd2, MeWb_w, w_rslt2, w_rrs, w_rrt);

  always @(posedge w_clk) begin
  IdEx_pc <= #3 IfId_pc;
  IdEx_op <= #3 w_op;
  IdEx_rd2 <= #3 w_rd2;
  IdEx_w <= #3 (w_op==0 || (w_op>6'h5 && w_op<6'h28));// bne ,beq, sw ではない命令
  IdEx_we <= #3 w_we;
  IdEx_rrs <= #3 w_rrs;
  IdEx_rrt <= #3 w_rrt;
  IdEx_rrt2 <= #3 w_rrt2;
  IdEx_funct <= #3 w_funct;
  IdEx_insn_sllv <= #3 w_insn_sllv;
  IdEx_insn_srlv <= #3 w_insn_srlv;
  end
/**************************** EX stage ***********************************/
  // ALU
  wire [31:0] #10 w_rslt = (IdEx_issn_sllv) ? IdEx_rrs << IdEx_rrt : 
                          (IdEx_issn_srlv) ? IdEx_rrs >> IdEx_rrt : 
                          IdEx_rslt2 + IdEx_rrs;// 左シフト, 右シフト, 加算
  //
  always @(posedge w_clk) begin
  ExMe_pc <= #3 IdEx_pc;
  ExMe_op <= #3 IdEx_op;
  ExMe_rd2 <= #3 IdEx_rd2;
  ExMe_w <= #3 IdEx_w;
  ExMe_we <= #3 IdEx_we;
  ExMe_rslt <= #3 w_rslt;
  ExMe_rrt <= #3 IdEx_rrt;
  end
/**************************** MEM stage **********************************/
  m_memory m_dmem (w_clk, ExMe_rslt[13:2], ExMe_we, ExMe_rrt, MeWb_ldd);
  always @(posedge w_clk) begin
  MeWb_pc <= #3 ExMe_pc;
  MeWb_rslt <= #3 ExMe_rslt;
  MeWb_op <= #3 ExMe_op;
  MeWb_rd2 <= #3 ExMe_rd2;
  MeWb_w <= #3 ExMe_w;
  end
/**************************** WB stage ***********************************/
  assign w_rslt2 = (MeWb_op>6'h19 && MeWb_op<6'h28) ? MeWb_ldd : MeWb_rslt;
  // = assign w_rslt2 = (w_insn_lw) ? w_ldd : w_rslt;
/*************************************************************************/
  initial r_rout = 0;
  reg [31:0] r_tmp=0;
  always @(posedge w_clk) r_tmp <= (w_rst) ? 0 : (w_rs==30) ? w_rrs : r_tmp;
  always @(posedge w_clk) r_rout <= r_tmp;
endmodule
