/**************************************************************************/
/* code019.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module m_top ();
  reg  [3:0] r_in;
  wire [6:0] w_led;
  integer i;
  initial
    for (i=0; i<=15; i=i+1) begin r_in <= i; #10; end
  
  initial       $display("      abcdefg");
  always@(*) #1 $display(" %x -> %b", r_in, w_led);
  
  m_7segled m_7segled0 (r_in, w_led);
endmodule


module m_7segled (w_in, w_led);
  input  wire [3:0] w_in;
  output wire [6:0] w_led;

  assign w_led =  (w_in==4'd0) ? 7'b1111110 :
                  (w_in==4'd1) ? 7'b0110000 :
                  (w_in==4'd2) ? 7'b1101101 :
                  (w_in==4'd3) ? 7'b1111001 :
                  (w_in==4'd4) ? 7'b0110011 :
                  (w_in==4'd5) ? 7'b1011011 :
                  (w_in==4'd6) ? 7'b1011111 :
                  (w_in==4'd7) ? 7'b1110000 :
                  (w_in==4'd8) ? 7'b1111111 :
                  (w_in==4'd9) ? 7'b1111011 :
                  7'b0000000;
endmodule
