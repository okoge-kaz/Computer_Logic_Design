/**************************************************************************/
/* code025.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module m_top ();
  reg [7:0] r_a = 8'b11110101;
  reg [2:0] r_s = 3'd3;
  initial #1 begin
    $display("%b", (r_a>>0));
    $display("%b", (r_a>>1));
    $display("%b", (r_a<<1));
    $display("%b", (r_a>>r_s));
    $display("%b", (r_a<<r_s));
  end
endmodule
