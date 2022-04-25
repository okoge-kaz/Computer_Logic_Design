/**************************************************************************/
/* code094.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none

module m_top();
  reg [31:0] r_i1, r_i2, r_i3;
  initial begin
    r_i1 = {6'h0, 5'd17, 5'd18, 5'd8,  5'h0, 6'h20};
    r_i2 = {6'h0, 5'd19, 5'd20, 5'd9,  5'h0, 6'h20};
    r_i3 = {6'h0, 5'd8,  5'd9,  5'd16, 5'h0, 6'h22};
    $display("i1: %b %x", r_i1, r_i1);
    $display("i2: %b %x", r_i2, r_i2);
    $display("i3: %b %x", r_i3, r_i3);
  end
endmodule
