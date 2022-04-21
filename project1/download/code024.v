/**************************************************************************/
/* code024.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module m_top ();
  reg [3:0] r_a = 4'd7;
  reg [3:0] r_b = 4'd8;
  initial #1 begin
    $display("%b", (r_a> r_b));
    $display("%b", (r_a< r_b));
    $display("%b", (r_a>=r_b));
    $display("%b", (r_a<=r_b));
    $display("%b", (r_a==r_b));
    $display("%b", (r_a!=r_b));
  end
endmodule
