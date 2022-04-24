/**************************************************************************/
/* code054.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`timescale 1ns/100ps
module m_top ();
  reg r_clk=0;
  initial forever #50 r_clk = ~r_clk;
  reg r_rst=1;
  initial #230 r_rst=0;
  wire [1:0] w_cnt;
  m_main m_main0 (r_clk, r_rst, w_cnt);
  initial $dumpfile("main.vcd");
  initial $dumpvars(0, m_main0);
  initial #1000 $finish; 
endmodule

module m_main (w_clk, w_rst, w_cnt);
  input  wire w_clk, w_rst;
  output wire [1:0] w_cnt;

  reg [1:0] r_cnt;
  always@(posedge w_clk) begin
    if (w_rst) r_cnt <= 0;
    else r_cnt <= #5 r_cnt + 1;
  end
  assign w_cnt = r_cnt;
endmodule
