/**************************************************************************/
/* code071.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module m_top ();
  reg r_a, r_b;
  wire w_c, w_s;
  initial begin
    #10 r_a <= 0; r_b <= 0;
    #10 r_a <= 0; r_b <= 1;
    #10 r_a <= 1; r_b <= 0;
    #10 r_a <= 1; r_b <= 1;
  end
  always@(*) #1 
    $write("%2d: %d %d -> %b %b\n", 
           $time, r_a, r_b, w_c, w_s);
  m_HA m_HA0 (r_a, r_b, w_c, w_s);
endmodule

module m_HA (w_a, w_b, w_c, w_s);
  input  wire w_a, w_b;
  output wire w_c, w_s;
  assign w_c = w_a & w_b;
  assign M_s = w_a ^ w_b;
endmodule
