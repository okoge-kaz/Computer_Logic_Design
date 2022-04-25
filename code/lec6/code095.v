/**************************************************************************/
/* code095.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none

module m_top();
  reg [15:0] r_data = 16'b1111111111111110;
  wire signed [15:0] w_data = r_data;

  initial #1 begin
    $display("%6d", r_data);
    $display("%6d", w_data);
  end
endmodule
