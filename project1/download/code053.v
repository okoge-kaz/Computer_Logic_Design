/**************************************************************************/
/* code053.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`timescale 1ns/100ps
module m_top ();
  reg r_clk=0;
  initial forever #50 r_clk = ~r_clk;
  wire [1:0] w_cnt;
  m_main m_main0 (r_clk, w_cnt);
  initial $dumpfile("main.vcd");
  initial $dumpvars(0, m_main0);
  initial #1000 $finish; 
endmodule


module m_main (w_clk, r_cnt);
  input  wire w_clk;
  output reg [1:0] r_cnt;

  initial r_cnt = 0;
  always@(posedge w_clk) r_cnt <= #5 r_cnt + 1; 
endmodule
