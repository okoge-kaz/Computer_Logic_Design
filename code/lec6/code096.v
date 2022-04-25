/**************************************************************************/
/* code096.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none

module m_top();
  wire signed [15:0] w_data1 = 16'b1111111111111110;
  wire signed [31:0] w_data2 = {{16{w_data1[15]}}, w_data1};

  initial #1 begin
    $display("%5d %32b", w_data1, w_data1);
    $display("%5d %32b", w_data2, w_data2);
  end
endmodule
