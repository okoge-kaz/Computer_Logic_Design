/**************************************************************************/
/* code113.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`timescale 1ns/100ps
`default_nettype none

module m_top ();
   reg r_clk=0; initial forever #50 r_clk = ~r_clk;
   wire [31:0] w_led;
   m_proc02 p (r_clk, w_led);
   initial begin
      p.m_imem.cm_ram[0]={6'h0, 5'd0, 5'd0, 5'd0, 5'h0, 6'h20}; // add $0, $0, $0
      p.m_imem.cm_ram[1]={6'h0, 5'd0, 5'd1, 5'd4, 5'h0, 6'h20}; // add $4, $0, $1
      p.m_imem.cm_ram[2]={6'h0, 5'd1, 5'd2, 5'd5, 5'h0, 6'h20}; // add $5, $1, $2
      p.m_imem.cm_ram[3]={6'h0, 5'd4, 5'd5, 5'd6, 5'h0, 6'h20}; // add $6, $4, $5
   end
   initial $dumpfile("main.vcd"); /* file name for GTKWave */
   initial $dumpvars(0, m_top);   /* module    for GTKWave */
   initial #550 $finish;
   always@(posedge r_clk) #1 $write("%4d %x: %x  %x -> %x\n", 
				    $time, p.r_pc, p.w_rrs, p.w_rrt, p.w_rslt);
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
   
   reg [31:0] 	      r[0:31];
   assign w_rdata1 = (w_rr1==0) ? 0 : r[w_rr1];
   assign w_rdata2 = (w_rr2==0) ? 0 : r[w_rr2];
   always @(posedge w_clk) if(w_we) r[w_wr] <= w_wdata;
   
   initial r[1] = 1;
   initial r[2] = 2;
endmodule

module m_proc02 (w_clk, w_led);
   input  wire w_clk;
   output wire [31:0] w_led;
   
   reg [31:0] r_pc = 0;
   always @(posedge w_clk) r_pc <= r_pc + 4;
   wire [31:0] w_ir;
   m_amemory m_imem (w_clk, r_pc[13:2], 1'd0, 32'd0, w_ir);

   wire [4:0]  w_rs = w_ir[25:21];
   wire [4:0]  w_rt = w_ir[20:16];
   wire [4:0]  w_rd = w_ir[15:11];
   wire [31:0] w_rrs, w_rrt, w_rslt;
   m_regfile m_regs (w_clk, w_rs, w_rt, w_rd, 1'd1, w_rslt, w_rrs, w_rrt);

   assign w_rslt = w_rrs + w_rrt;

   assign w_led = w_rslt;
endmodule
