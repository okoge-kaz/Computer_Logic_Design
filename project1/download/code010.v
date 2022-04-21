/**************************************************************************/
/* code010.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module main ();
  integer fahr, celsius;
  initial begin
    for (fahr = 0; fahr <= 300; fahr += 20) begin
      celsius = 5*(fahr-32) / 9;
      $display("%3d %6d", fahr, celsius);
    end
  end
endmodule
