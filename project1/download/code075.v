/**************************************************************************/
/* code075.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none

module m_top ();
  reg  [3:0] r_a, r_b;
  wire [3:0] w_s;
  initial begin
    #10 r_a <= 3; r_b <= 4; 
    #10 r_a <= 1; r_b <= 9;
    #10 r_a <= 8; r_b <= 9;   
  end
  always@(*) #1 $write("%2d %2d -> %2d\n", r_a, r_b, w_s);
  m_4ADDER m_4ADDER0 (r_a, r_b, w_s);
endmodule

module m_4ADDER (w_a, w_b, w_s);
 /* Please describe here by yourself */
endmodule

module m_FA (w_a, w_b, w_cin, w_s, w_cout);
   input wire w_a, w_b, w_cin;
   output wire w_s, w_cout;

   wire w_e, w_f, w_g;
   m_HA m_HA0(w_cin, w_e, w_s, w_g);
   m_HA m_HA1(w_a, w_b, w_e, w_f);
   assign w_cout = w_g | w_f;
endmodule

module m_HA (w_a, w_b, w_s, w_c);
  input  wire w_a, w_b;
  output wire w_s, w_c;
  assign w_c = w_a & w_b;
  assign w_s = w_a ^ w_b;
endmodule
