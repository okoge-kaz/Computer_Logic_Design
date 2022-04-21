/**************************************************************************/
/* code079.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none
`define D_N 32

module m_main (w_clk, w_a, w_b, w_dout);
  input  wire w_clk, w_a, w_b;
  output wire w_dout;
  reg [`D_N-1:0] r_a=0, r_b=0, r_s=0;
  wire [`D_N-1:0] w_s;
  assign w_dout = ^r_s;
  always@(posedge w_clk) begin
    r_a <= {w_a, r_a[`D_N-1:1]};
    r_b <= {w_b, r_b[`D_N-1:1]};
    r_s <= w_s;
  end
  m_ADDER #(32) m_ADDER0 (r_a, r_b, w_s);
endmodule

module m_ADDER #(parameter P_N=8) (w_a, w_b, w_s);
  input  wire [P_N-1:0] w_a, w_b;
  output wire [P_N-1:0] w_s;
  wire [P_N:0] w_cin;
  assign w_cin[0] = 0;
  generate genvar g;
    for (g = 0; g < P_N; g = g + 1) begin : Gen
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
