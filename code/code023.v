/**************************************************************************/
/* code023.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module m_top ();
  reg [3:0] r_a = 4'b1001;
  reg [3:0] r_b = 4'b0101;
  reg [3:0] r_c = 4'b1111;
  initial #1 begin
    $display("%b", {r_a, r_b});
    $display("%b", {r_a, r_b, r_c});
    $display("%b", {2{r_a}});
    $display("%b", {3{r_a}});
    $display("%b", {4{r_a}});
    $display("%b", {{4{r_a[3]}}, r_a});
    $display("%b", {{4{r_b[3]}}, r_b});
  end
endmodule

