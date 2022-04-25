/**************************************************************************/
/* code090.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/

module m_main (w_clk, w_led);
  input  wire w_clk;
  output wire [3:0] w_led;
 
  reg [3:0] r_out = 0;
  always@(posedge w_clk) r_out <= r_out + 1;
  assign w_led = r_out;
endmodule
