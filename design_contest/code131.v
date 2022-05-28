`timescale 1ns/100ps
`default_nettype none

/**************************************************************************/
`define HALT {6'h4, 5'd0, 5'd0, 16'hffff} // L1: beq  $0, $0, L1
/**************************************************************************/
module m_top (); 
  reg r_clk=0; initial forever #50 r_clk = ~r_clk;
  wire [31:0] w_led;

  reg [31:0] r_cnt = 0;
  always@(posedge r_clk)  r_cnt <= r_cnt + 1;
  
  m_proc10 p (r_clk, w_led);

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

module m_memory (w_clk, w_addr, w_we, w_din, w_dout);
  input  wire w_clk, w_we;
  input  wire [10:0] w_addr;
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

module m_proc10 (w_clk, w_rst, r_rout, r_halt);
  input wire w_clk, w_rst;
  output reg [31:0] r_rout;
  output reg r_halt;
  reg [31:0] IdEx_rrs=0, IdEx_rrt=0, IdEx_rrt2=0; // pipe regs
  reg [31:0] ExMe_rslt=0, ExMe_rrt=0; //
  reg [31:0] MeWb_rslt=0; //
  reg [5:0] IdEx_op=0, ExMe_op=0, MeWb_op=0; //
  reg [31:0] IfId_pc=0, IdEx_pc=0, ExMe_pc=0, MeWb_pc=0; //
  reg [4:0] IfId_rd2=0, IdEx_rd2=0, ExMe_rd2=0, MeWb_rd2=0;//
  reg IfId_w=0, IdEx_w=0, ExMe_w=0, MeWb_w=0; //
  reg IfId_we=0, IdEx_we=0, ExMe_we=0; //
  wire [31:0] IfId_ir, MeWb_ldd; // note
/**************************** IF stage *****************************/
  reg [31:0] r_pc = 0;
  wire [31:0] w_npc = r_pc + 4;
  always @(posedge w_clk) begin
  r_pc <= #3 (w_rst | r_halt) ? 0 : w_npc;
  end
  m_memory m_imem (w_clk, r_pc[13:2], 0, 0, IfId_ir);
  always @(posedge w_clk) begin
  IfId_pc <= #3 r_pc;
  end
/**************************** ID stage ******************************/
  wire [5:0] w_op = IfId_ir[31:26];
  wire [4:0] w_rs = IfId_ir[25:21];
  wire [4:0] w_rt = IfId_ir[20:16];
  wire [4:0] w_rd = IfId_ir[15:11];
  wire [4:0] w_rd2 = (w_op!=0) ? w_rt : w_rd;
  wire [15:0] w_imm = IfId_ir[15:0];
  wire [31:0] w_rrs, w_rrt, w_rslt2;
  m_regfile m_regs (w_clk, w_rs, w_rt, MeWb_rd2, MeWb_w, w_rslt2, w_rrs,
  w_rrt);
  wire [31:0] w_imm32 = {{16{w_imm[15]}}, w_imm};
  wire [31:0] w_rrt2 = (w_op>6'h5) ? w_imm32 : w_rrt;

  always @(posedge w_clk) begin
  IdEx_pc <= #3 IfId_pc;
  IdEx_op <= #3 w_op;
  IdEx_rd2 <= #3 w_rd2;
  IdEx_w <= #3 (w_op==0 || (w_op>6'h5 && w_op<6'h28));
  IdEx_we <= #3 (w_op>6'h27);
  IdEx_rrs <= #3 w_rrs;
  IdEx_rrt <= #3 w_rrt;
  IdEx_rrt2 <= #3 w_rrt2;
  end
/**************************** EX stage ******************************/
  wire [31:0] #10 w_rslt = IdEx_rrs + IdEx_rrt2; // ALU

  always @(posedge w_clk) begin
  ExMe_pc <= #3 IdEx_pc;
  ExMe_op <= #3 IdEx_op;
  ExMe_rd2 <= #3 IdEx_rd2;
  ExMe_w <= #3 IdEx_w;
  ExMe_we <= #3 IdEx_we;
  ExMe_rslt <= #3 w_rslt;
  ExMe_rrt <= #3 IdEx_rrt;
  end
/**************************** MEM stage *****************************/
m_memory m_dmem (w_clk, ExMe_rslt[13:2], ExMe_we, ExMe_rrt, MeWb_ldd);

  always @(posedge w_clk) begin
  MeWb_pc <= #3 ExMe_pc;
  MeWb_rslt <= #3 ExMe_rslt;
  MeWb_op <= #3 ExMe_op;
  MeWb_rd2 <= #3 ExMe_rd2;
  MeWb_w <= #3 ExMe_w;
  end
/**************************** WB stage ******************************/
assign w_rslt2 = (MeWb_op>6'h19 && MeWb_op<6'h28) ? MeWb_ldd : MeWb_rslt;
/******************************************************************/
initial r_halt = 0;

  always @(posedge w_clk) if (MeWb_op==`HALT) r_halt <= 1;

initial r_rout = 0;
reg [31:0] r_tmp=0;

  always @(posedge w_clk) r_tmp <= (w_rst) ? 0 : (w_rs==30) ? w_rrs : r_tmp;
  always @(posedge w_clk) r_rout <= r_tmp;
endmodule