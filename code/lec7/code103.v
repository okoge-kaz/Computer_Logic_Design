/**************************************************************************/
/* code103.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none

module m_top ();
   reg r_clk=0; initial forever #50 r_clk = ~r_clk;
   wire [31:0] w_pc, w_ifpc;
   m_main m_main0 (r_clk, w_pc, w_ifpc);
   always@(*) #1 $write("%3d %x %x\n", $time, w_pc, w_ifpc);
   initial #1000 $finish();
endmodule

module m_main (w_clk, w_pc, w_ifpc);
   input  wire w_clk;
   output wire [31:0] w_pc, w_ifpc;

   reg [31:0] r_pc = 0;
   reg [31:0] r_ifpc = 0;
   assign w_ifpc = r_ifpc;
   assign w_pc = r_pc;
   wire [31:0] w_npc = w_pc + 4;
   always@(posedge w_clk) r_pc   <= w_npc;
   always@(posedge w_clk) r_ifpc <= w_pc;  
endmodule
