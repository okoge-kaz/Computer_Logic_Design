/**************************************************************************/
/* code105.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none

module m_main (w_clk, w_led);
  input  wire w_clk;
  output wire [3:0]  w_led;
  
  wire w_clk2, w_locked;
  clk_wiz_0 clk_w0 (w_clk2, 0, w_locked, w_clk);

  reg        r_out = 0;
  reg [31:0] r_cnt = 0;
  always@(posedge w_clk2) begin
    r_cnt <= (r_cnt==99999999) ? 0 : r_cnt +1;
    r_out <= (r_cnt==0) ? ~r_out : r_out;
  end
  assign w_led = {r_out, r_out, r_out, r_out};
  vio_0 vio_00(w_clk2, w_led[3], w_led[2], w_led[1], w_led[0]);
endmodule
