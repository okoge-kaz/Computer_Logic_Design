/**************************************************************************/
/* code007.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module main ();
  initial #200 $display("hello, world");
  initial begin
    #100 $display("in Verilog HDL");
    #150 $display("When am I displayed?");
    #1000 $display("Verilog is easy?");
  end
endmodule
