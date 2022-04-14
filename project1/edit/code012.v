/**************************************************************************/
/* code012.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module main ();
  reg a, b;
  wire c;
  assign c = a | b;

  initial begin
    #10 a <= 0; b <= 0;
    #10 a <= 0; b <= 1;
    #10 a <= 1; b <= 0;
    #10 a <= 1; b <= 1;
  end
  always@(*) #1 $display("%2d: %d %d -> %d", $time, a, b, c);
endmodule
