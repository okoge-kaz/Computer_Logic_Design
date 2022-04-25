/**************************************************************************/
/* code117.v                          For CSC.T341 CLD Archlab TOKYO TECH */
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
endmodule

