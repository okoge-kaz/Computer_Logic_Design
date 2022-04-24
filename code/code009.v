/**************************************************************************/
/* code009.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module main ();
  initial #200 $display("%3d hello, world", $time);
  initial begin
    #100 $display("%3d in Verilog HDL", $time);
    #150 $display("%3d When am I displayed?", $time);
  end
  initial #210 $finish;
endmodule
