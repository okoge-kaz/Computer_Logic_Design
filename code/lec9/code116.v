/**************************************************************************/
/* code116.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`timescale 1ns/100ps
`default_nettype none
  
module m_top ();
   reg r_clk=0; initial forever #50 r_clk = ~r_clk;
   wire [31:0] w_led;
   m_proc06 p (r_clk, w_led);
   always@(*) #80 $write("%4d %x %x %x %x %x\n", $time,
                         p.r_pc, p.w_ir, p.w_rrs, p.w_rrt2, p.w_rslt2);
   initial begin
      p.m_imem.cm_ram[0] = {6'h0, 5'd0, 5'd0, 5'd0, 5'h0, 6'h20}; //     add  $0, $0, $0
      p.m_imem.cm_ram[1] = {6'h8, 5'd0, 5'd9, 16'h55};            //     addi $9, $0, 55 
      p.m_imem.cm_ram[2] = {6'h2b,5'd0, 5'd9, 16'd32};            //     sw   $9, 32($0)
      p.m_imem.cm_ram[3] = {6'h23,5'd0, 5'd7, 16'd32};            //     lw   $7, 32($0)
      p.m_imem.cm_ram[4] = {6'h0, 5'd7, 5'd2, 5'd7, 5'h0, 6'h20}; // L1: add  $7, $7, $2
      p.m_imem.cm_ram[5] = {6'h4, 5'd0, 5'd0, 16'hfffe};          //     beq  $0, $0, L1
      p.m_dmem.cm_ram[0]=32'h222;
      p.m_dmem.cm_ram[1]=32'h333;
   end
   initial $dumpfile("main.vcd"); /* file name for GTKWave */
   initial $dumpvars(0, m_top);   /* module    for GTKWave */
   initial #1000 $finish;
endmodule

module m_amemory (w_clk, w_addr, w_we, w_din, w_dout);
   input  wire w_clk, w_we;
   input  wire [11:0] w_addr;
   input  wire [31:0] w_din;
   output wire [31:0] w_dout;
   
   reg [31:0] 	      cm_ram [0:4095]; // 4K word (4096 x 32bit) memory
   always @(posedge w_clk) if (w_we) cm_ram[w_addr] <= w_din;
   assign #20 w_dout = cm_ram[w_addr];
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

module m_proc06 (w_clk, w_led);
   input  wire w_clk;
   output wire [31:0] w_led;
   
   reg  [31:0] r_pc = 0;
   wire [31:0] w_ir, w_rrs, w_rrt, w_imm32, w_rrt2, w_rslt, w_ldd, w_rslt2;
   wire  [5:0] w_op = w_ir[31:26];
   wire  [4:0] w_rs = w_ir[25:21];
   wire  [4:0] w_rt = w_ir[20:16];
   wire  [4:0] w_rd = w_ir[15:11];   
   wire        w_taken = (w_op==6'h4 && w_rrs==w_rrt2);
   wire [31:0] w_npc = r_pc + 4;
   wire [31:0] w_tpc = /* describe proper logic here */ ;

   always @(posedge w_clk) r_pc <= /* describe proper logic here */ ;
   m_amemory m_imem (w_clk, r_pc[13:2], 1'd0, 32'd0, w_ir);

   wire  [4:0] w_rd2 = (w_op!=0) ? w_rt : w_rd;
   wire [15:0] w_imm = w_ir[15:0];
   wire        w_w = (w_op==0 || (w_op>6'h5 && w_op<6'h28));
   m_regfile m_regs (w_clk, w_rs, w_rt, w_rd2, w_w, w_rslt2, w_rrs, w_rrt);

   assign w_imm32 = {{16{w_imm[15]}}, w_imm};
   assign w_rrt2  = (w_op>6'h5) ? w_imm32 : w_rrt;

   assign #10 w_rslt = w_rrs + w_rrt2;

   wire        w_we = (w_op>6'h27);
   m_amemory m_dmem ( /* describe proper input and output here */ );
   assign w_rslt2 = (w_op>6'h19 && w_op<6'h28) ? w_ldd : w_rslt;
  
   assign w_led = w_rslt2;
endmodule

