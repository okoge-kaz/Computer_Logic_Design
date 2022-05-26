/**************************************************************************/
/* code130.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`timescale 1ns/100ps
`default_nettype none

/***** top module for simulation *****/
module m_top (); 
   reg r_clk=0; initial forever #50 r_clk = ~r_clk;
   wire [31:0] w_led;

   initial $dumpfile("main.vcd");
   initial $dumpvars(0, m_top);

   m_proc09 p (r_clk, w_led);
   initial $write("time: s r_pc     w_ir     w_rrs    w_rrt2   r_rslt2  r_led\n");
   always@(posedge r_clk) $write("%4d: %d %x %x %x %x %x %x\n", $time,
                        p.r_state, p.r_pc, p.w_ir, p.w_rrs, p.w_rrt2, p.w_rslt2, w_led);
   initial #2000 $finish;
endmodule

/***** main module for FPGA implementation *****/

// module m_main (w_clk, w_led);
//    input  wire w_clk;
//    output wire [3:0] w_led;

//    wire w_clk2, w_locked;
//    clk_wiz_0 clk_w0 (w_clk2, 0, w_locked, w_clk);
   
//    wire [31:0] w_dout;
//    m_proc09 p (w_clk2, w_dout);

//    vio_0 vio_00(w_clk2, w_dout);

//    reg [3:0] r_led = 0;
//    always @(posedge w_clk2) 
//       r_led <= {^w_dout[31:24], ^w_dout[23:16], ^w_dout[15:8], ^w_dout[7:0]};
//    assign w_led = r_led;
// endmodule


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

module m_proc09 (w_clk, r_led);
   input  wire w_clk;
   output reg [31:0] r_led;
   initial r_led = 0;
   
   reg [31:0] r_pc = 0;

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

   // 5状態を管理
   reg [3:0] r_state = 0;
   always @(posedge w_clk) begin
      if(r_state != 4'd4) r_state <= r_state + 1; 
      else r_state <= 0;
   end

   /***** first cycle IF*****/ 
   reg [31:0] w_tpc=0;

   wire [31:0] w_pc4 = r_pc + 4;
   wire w_taken = (w_insn_beq && w_rrs==w_rrt2) || (w_insn_bne && w_rrs!=w_rrt2);

   always @(posedge w_clk) if(r_state == 4'd4) begin
      r_pc <= #3 (w_taken) ? r_tpc : w_pc4;
   end

   m_amemory m_imem (w_clk, r_pc[12:2], 1'd0, 32'd0, w_ir);
   /***** second cycle ID*****/
   reg [31:0] r_ir=0, r_pc4=0; 
   wire [31:0] w_imm32 = {{16{w_imm[15]}}, w_imm};
   wire [31:0] w_tpc = w_pc4 + {w_imm32[29:0], 2'h0};
   wire  [4:0] w_rd2 = (w_insn_add | w_insn_sllv | w_insn_srlv) ? w_rd : w_rt;
   wire w_we = w_insn_add | w_insn_addi | w_insn_sllv | w_insn_srlv | w_insn_lw;

   m_regfile m_regs (w_clk, w_rs, w_rt, w_rd2, r_we, w_rslt2, w_rrs, w_rrt);
   assign w_rrt2 = (w_insn_addi | w_insn_lw | w_insn_sw) ? w_imm32 : w_rrt;

   always @(posedge w_clk) if(r_state ==  4'd0) begin
      r_ir <= w_ir;
      r_pc4 <= w_pc4;
      r_rd2 <= w_rd2;// これいる？
      r_led <= (r_we && r_rd2==30 && r_state==4) ? w_rslt2 : r_led;
   end
   /***** third cycle EX*****/
   reg [31:0] r_rrs=0, r_rrt=0, r_rrt2=0, r_tpc=0;

   assign #10 w_rslt = (w_insn_sllv) ? w_rrs << w_rrt2[4:0] :
	(w_insn_srlv) ? w_rrs >> w_rrt2[4:0] : w_rrs + w_rrt2;

   always @(posedge w_clk) if(r_state == 4'd1) begin
      r_rrs <= w_rrs;
      r_rrt <= w_rrt;
      r_rrt2 <= w_rrt2;
      r_tpc <= w_tpc;
   end
   /***** forth cycle MEM*****/   
   reg [31:0] r_rslt=0;
   reg r_taken=0;

   m_amemory m_dmem (w_clk, r_rslt[12:2], r_insn_sw, r_rrt, w_ldd);

   always @(posedge w_clk) if(r_state == 4'd2) begin
      r_rslt <= w_rslt;
      r_taken <= w_taken;
   end
   /***** fifth cycle WB*****/   
   reg r_insn_lw=0, r_insn_sw=0;

   assign w_rslt2 = (r_insn_lw) ? w_ldd : r_rslt;
   
   always @(posedge w_clk) if(r_state == 4'd3) begin
      r_insn_lw <= w_insn_lw;
      r_insn_sw <= w_insn_sw;
   end
endmodule
