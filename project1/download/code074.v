/**************************************************************************/
/* code074.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none

module m_top ();
  reg  r_a, r_b, r_cin;
  wire w_s, w_cout;
  initial begin
    #10 r_a <= 0; r_b <= 0;  r_cin <= 0; 
    #10 r_a <= 0; r_b <= 0;  r_cin <= 1; 
    #10 r_a <= 0; r_b <= 1;  r_cin <= 0;   
    #10 r_a <= 0; r_b <= 1;  r_cin <= 1; 
    #10 r_a <= 1; r_b <= 0;  r_cin <= 0; 
    #10 r_a <= 1; r_b <= 0;  r_cin <= 1; 
    #10 r_a <= 1; r_b <= 1;  r_cin <= 0; 
    #10 r_a <= 1; r_b <= 1;  r_cin <= 1; 
  end
  always@(*) #1 $write("%d %d %d -> %b %b\n",  
                  r_a, r_b, r_cin, w_cout, w_s);
  m_FA m_FA0 (r_a, r_b, r_cin, w_s, w_cout);
endmodule

module m_FA (w_a, w_b, w_cin, w_s, w_cout);
  /* Please describe here by yourself */
  input wire w_a, w_b, w_cin;
  output wire w_s, w_cout;

  assign w_s = (w_a ^ w_b) ^ w_cin;
  wire w_e = w_a ^ w_b;
  assign w_cout = (w_a & w_b) | (w_e & w_cin);
endmodule

module m_HA (w_a, w_b, w_s, w_c);
  input  wire w_a, w_b;
  output wire w_s, w_c;
  assign w_c = w_a & w_b;
  assign w_s = w_a ^ w_b;
endmodule
