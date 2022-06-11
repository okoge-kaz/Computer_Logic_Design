/******************************************************************************/
/* m_proc12                                              Arch Lab. TOKYO TECH */
/******************************************************************************/
`default_nettype none

/******************************************************************************/
`define ADD  6'h0
`define ADDI 6'h8
`define LW   6'h23
`define SW   6'h2b
`define BEQ  6'h4
`define BNE  6'h5
`define NOP  {6'h0, 5'd0, 5'd0, 5'd0, 5'h0, 6'h20} // add $0, $0, $0
`define HALT 6'h11 /* this is not for MIPS */
/******************************************************************************/

module m_top ();
  reg r_clk=0; initial forever #50 r_clk = ~r_clk;
  
  wire w_halt;
  wire [31:0] w_led;
  m_proc12 p (r_clk, w_led, w_halt);

  reg [31:0] r_cnt = 0;
  always@(posedge r_clk) r_cnt <= r_cnt + 1;

  initial  $write("   r_cnt : r_pc     IfId_pc  [w_op] IdEx_pc  ExMe_pc  MeWb_pc    MeWb_rd2 w_rslt2  w_led\n");
  always@(posedge r_clk) begin #90
    $write("%8d : %d %x [ %x ] %x %x %x | %8d %x %x\n",
          r_cnt, p.r_pc, p.IfId_pc, p.w_op, p.IdEx_pc, p.ExMe_pc, p.MeWb_pc, p.MeWb_rd2, p.w_rslt2, w_led);
  end

  always@(posedge r_clk) if (w_halt) begin
    $write("w_led = %x\n", w_led);
    #10 $finish();
  end

endmodule


/******************************************************************************/

module m_main (w_clk, w_led);
  input  wire w_clk;
  output wire [3:0] w_led;
  
  wire w_halt=0;
  wire w_clk2, w_locked;
  clk_wiz_0 clk_w0 (w_clk2, 0, w_locked, w_clk);
  
  wire [31:0] w_dout;
  m_proc12 p (w_clk2, w_dout, w_halt);

  vio_0 vio_00(w_clk2, w_dout);

  reg [3:0] r_led = 0;
  always @(posedge w_clk2) 
    r_led <= {^w_dout[31:24], ^w_dout[23:16], ^w_dout[15:8], ^w_dout[7:0]};
  assign w_led = r_led;
endmodule

/******************************************************************************/
module m_proc12 (w_clk, r_led, r_halt);
  input  wire w_clk;
  output reg [31:0] r_led;
  output reg        r_halt;
  initial r_led = 0;

  reg  [31:0] IfId_pc4=0;                                    // pipe regs
  reg  [31:0] IdEx_rrs=0, IdEx_rrt=0, IdEx_rrt2=0;           //
  reg  [31:0] ExMe_rslt=0, ExMe_rrt=0;                       // 
  reg  [31:0] MeWb_rslt=0;                                   //
  reg   [5:0]             IdEx_op=0,  ExMe_op=0,  MeWb_op=0; // 
  reg  [31:0] IfId_pc=0,  IdEx_pc=0,  ExMe_pc=0,  MeWb_pc=0; //
  reg   [4:0] IfId_rd2=0, IdEx_rd2=0, ExMe_rd2=0, MeWb_rd2=0;//
  reg   [4:0]             IdEx_rs=0,  ExMe_rs=0,  MeWb_rs=0; //
  reg   [4:0]             IdEx_rt=0,  ExMe_rt=0,  MeWb_rt=0; //
  reg         IfId_w=0,   IdEx_w=0,   ExMe_w=0,   MeWb_w=0;  //
  reg         IfId_we=0,  IdEx_we=0,  ExMe_we=0;             //
  reg   [5:0]             IdEx_funct=0;                      //
  reg  [31:0]             IdEx_ir,    ExMe_ir,    MeWb_ir;   //
  reg  [31:0] MeWb_rslt2=0, MeWb_rd3=0;                      //
  wire [31:0] IfId_ir, MeWb_ldd;                             // note
  /**************************** IF stage *****************************/
  wire w_taken;
  wire [31:0] w_tpc;
  reg  [31:0] r_pc  = 0;
  wire [31:0] w_pc4 = r_pc + 4;
  m_memory m_imem (w_clk, r_pc[12:2], 1'd0, 32'd0, IfId_ir, w_insn_beq | w_insn_bne);
  always @(posedge w_clk) begin
    r_pc     <= (r_halt) ? 0
                : ((w_insn_beq | w_insn_bne) && ~w_taken) ? r_pc
                : (w_taken) ? w_tpc
                : w_pc4;
    IfId_pc  <= r_pc;
    IfId_pc4 <= w_pc4;
  end
  /**************************** ID stage ******************************/
  wire [31:0] w_rrs, w_rrt, w_rslt2;
  wire  [5:0] w_op    = IfId_ir[31:26];
  wire  [5:0] w_funct = IfId_ir[5: 0];
  wire  [4:0] w_rs    = IfId_ir[25:21];
  wire  [4:0] w_rt    = IfId_ir[20:16];
  wire  [4:0] w_rd    = IfId_ir[15:11];
  wire [15:0] w_imm   = IfId_ir[15:0];
  wire [31:0] w_imm32 = {{16{w_imm[15]}}, w_imm};
  wire [31:0] w_taken_rrs;
  wire [31:0] w_taken_rrt;
  
  wire w_insn_add     = (w_op==0 && w_funct==6'h20);
  wire w_insn_sllv    = (w_op==0 && w_funct==6'h4);
  wire w_insn_srlv    = (w_op==0 && w_funct==6'h6);
  wire w_insn_addi    = (w_op==6'h8);
  wire w_insn_lw      = (w_op==6'h23);
  wire w_insn_sw      = (w_op==6'h2b);
  wire w_insn_beq     = (w_op==6'h4);
  wire w_insn_bne     = (w_op==6'h5);
  wire  [4:0] w_rd2   = (w_insn_add | w_insn_sllv | w_insn_srlv) ? w_rd 
                      : (w_insn_addi | w_insn_lw) ? w_rt 
                      : 31;
  wire [31:0] w_rrt2  = (w_insn_addi | w_insn_lw | w_insn_sw) ? w_imm32 : w_rrt;
  assign w_tpc   = IfId_pc4 + {w_imm32[29:0], 2'h0};
  assign w_taken_rrs = (w_rs==IdEx_rd2) ? w_rslt
                    : (w_rs==ExMe_rd2) ? ExMe_rslt
                    : (w_rs==MeWb_rd2) ? MeWb_rslt
                    : w_rrs;
assign w_taken_rrt = (w_rt==IdEx_rd2) ? w_rslt
                    : (w_rt==ExMe_rd2) ? ExMe_rslt
                    : (w_rt==MeWb_rd2) ? MeWb_rslt
                    : w_rrt;
  assign w_taken = (w_insn_beq && w_taken_rrs==w_taken_rrt) || (w_insn_bne && w_taken_rrs!=w_taken_rrt);

  m_regfile m_regs (w_clk, w_rs, w_rt, MeWb_rd2, MeWb_w, w_rslt2, w_rrs, w_rrt);

  always @(posedge w_clk) begin
    IdEx_pc    <= IfId_pc;
    IdEx_op    <= w_op;
    IdEx_ir    <= IfId_ir;
    IdEx_rd2   <= w_rd2;
    IdEx_w     <= (w_op==0 || (w_op>6'h5 && w_op<6'h28));
    IdEx_we    <= w_insn_add | w_insn_addi | w_insn_sllv | w_insn_srlv | w_insn_lw;
    IdEx_rrs   <= w_rrs;
    IdEx_rrt   <= w_rrt;
    IdEx_rrt2  <= w_rrt2;
    IdEx_funct <= w_funct;
    IdEx_rs    <= w_rs;
    IdEx_rt    <= w_rt;
  end
  /**************************** EX stage ******************************/
  wire [31:0] w_rrs2 = (IdEx_rs==ExMe_rd2) ? ExMe_rslt                // red
                     : (IdEx_rs==MeWb_rd2) ? w_rslt2                  // blue
                     : IdEx_rrs;                                      // black
  wire [31:0] w_rrt3 = (IdEx_op==0 && IdEx_rt==ExMe_rd2) ? ExMe_rslt  // red
                     : (IdEx_op==0 && IdEx_rt==MeWb_rd2) ? w_rslt2    // blue
                     : IdEx_rrt2;                                     // black
  wire [31:0] w_rslt = (IdEx_op==0 && IdEx_funct==6'h4) ? w_rrs2 << w_rrt3[4:0]
                    : (IdEx_op==0 && IdEx_funct==6'h6) ? w_rrs2 >> w_rrt3[4:0]
                     : w_rrs2 + w_rrt3; // ALU
  always @(posedge w_clk) begin
    ExMe_pc   <= IdEx_pc;
    ExMe_op   <= IdEx_op;
    ExMe_ir   <= IdEx_ir;
    ExMe_rd2  <= IdEx_rd2;
    ExMe_w    <= IdEx_w;
    ExMe_we   <= IdEx_we;
    ExMe_rslt <= w_rslt;
    ExMe_rrt  <= IdEx_rrt;
    ExMe_rs   <= IdEx_rs;
    ExMe_rt   <= IdEx_rt;
  end
  /**************************** MEM stage *****************************/
  reg MeWb_we=0;
  wire [10:0] w_addr = (ExMe_rs==MeWb_rd2) ? MeWb_rslt[12:2]     // kokokana ????
                    : (ExMe_rs==MeWb_rd3) ? MeWb_rslt2[12:2]
                    : ExMe_rslt[12:2];
  wire [31:0] w_din = (ExMe_rt==MeWb_rd2) ? MeWb_rslt
                    : (ExMe_rt==MeWb_rd3) ? MeWb_rslt2
                    : ExMe_rrt;
  m_memory m_dmem (w_clk, w_addr, ExMe_op==6'h2b, w_din, MeWb_ldd, 1'd0);
  always @(posedge w_clk) begin
    MeWb_pc   <= ExMe_pc;
    MeWb_rslt <= ExMe_rslt;
    MeWb_op   <= ExMe_op;
    MeWb_ir   <= ExMe_ir;
    MeWb_rd2  <= ExMe_rd2;
    MeWb_w    <= ExMe_w;
    MeWb_we   <= ExMe_we;
    MeWb_rs   <= ExMe_rs;
    MeWb_rt   <= ExMe_rt;
    MeWb_rd3  <= MeWb_rd2;
    MeWb_rslt2<= MeWb_rslt;
  end
  /**************************** WB stage ******************************/
  assign w_rslt2 = (MeWb_op==6'h23) ? MeWb_ldd : MeWb_rslt;  // lw -> MeWb_ldd.
  /******************************************************************/
  initial r_halt = 0;
  always @(posedge w_clk) if (ExMe_ir==`HALT) r_halt <= 1; // ?

  initial r_led = 0;
  always @(posedge w_clk) r_led <= (MeWb_we && MeWb_rd2==30) ? w_rslt2 : r_led;
endmodule

/******************************************************************************/
module m_memory (w_clk, w_addr, w_we, w_din, r_dout, w_branch);
  input  wire w_clk, w_we, w_branch;
  input  wire [10:0] w_addr;
  input  wire [31:0] w_din;
  output reg  [31:0] r_dout;
  reg [31:0] cm_ram [0:2047]; // 2K word (2048 x 32bit) memory
  always @(posedge w_clk) begin
    if (w_we) cm_ram[w_addr] <= w_din;
    r_dout <= cm_ram[w_addr];
    if (w_branch) r_dout <= `NOP;
  end
  initial r_dout = 0;
  
`include "program.txt"
endmodule

/******************************************************************************/
module m_regfile (w_clk, w_rr1, w_rr2, w_wr, w_we, w_wdata, w_rdata1, w_rdata2);
  input  wire        w_clk;
  input  wire  [4:0] w_rr1, w_rr2, w_wr;
  input  wire [31:0] w_wdata;
  input  wire        w_we;
  output wire [31:0] w_rdata1, w_rdata2;

  reg [31:0] r[0:31];
  assign w_rdata1 = (w_rr1==0) ? 0 :(w_rr1==w_wr) ? w_wdata : r[w_rr1];
  assign w_rdata2 = (w_rr2==0) ? 0 :(w_rr2==w_wr) ? w_wdata : r[w_rr2];
  always @(posedge w_clk) if(w_we) r[w_wr] <= w_wdata;

  initial begin
    r[1] = 1;
    r[2] = 2;
  end
endmodule

/******************************************************************************/