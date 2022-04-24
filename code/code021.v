/**************************************************************************/
/* code021.v                          For CSC.T341 CLD Archlab TOKYO TECH */
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


module m_7segled (w_in, r_led);
  input  wire [3:0] w_in;
  output reg  [6:0] r_led;
  always @(*) begin
    if      (w_in==4'd0) r_led <= 7'b1111110;
    else if (w_in==4'd1) r_led <= 7'b0110000;
    else if (w_in==4'd2) r_led <= 7'b1101101;
    else if (w_in==4'd3) r_led <= 7'b1111001;
    else if (w_in==4'd4) r_led <= 7'b0110011;
    else if (w_in==4'd5) r_led <= 7'b1011011;
    else if (w_in==4'd6) r_led <= 7'b1011111;
    else if (w_in==4'd7) r_led <= 7'b1110000;
    else if (w_in==4'd8) r_led <= 7'b1111111;
    else if (w_in==4'd9) r_led <= 7'b1111011;
    else                 r_led <= 7'b0000000;
  end
endmodule
