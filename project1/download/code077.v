/**************************************************************************/
/* code077.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none
`define D_N 5

module m_top ();
  reg  [`D_N-1:0] r_a, r_b;
  wire [`D_N-1:0] w_s;
  initial begin
    #10 r_a <=  321; r_b <= 4444; 
    #10 r_a <= 1024; r_b <= 2048;
  end
  always@(*) #1 $write("%4d %4d -> %4d\n", r_a, r_b, w_s);
  m_ADDER m_ADDER0 (r_a, r_b, w_s);
endmodule

module m_ADDER (w_a, w_b, w_s);
  input  wire [`D_N-1:0] w_a, w_b;
  output wire [`D_N-1:0] w_s;
  wire [`D_N:0] w_cin;
  assign w_cin[0] = 0;
  generate genvar g;
    for (g = 0; g < `D_N; g = g + 1) begin : Gen
      m_FA m_FA0(w_a[g], w_b[g], w_cin[g], w_s[g], w_cin[g+1]);
    end
  endgenerate
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
