/**************************************************************************/
/* code014.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module main ();
  reg  [3:0] a, b;
  wire [3:0] c;
  assign c = a | b;

  initial begin
    #10 a <= 4'b1010; b <= 4'b1100;
  end
  always@(*) #1 $display("%2d: %b %b -> %b", $time, a, b, c);
endmodule
