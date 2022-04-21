/**************************************************************************/
/* code026.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module m_top ();
  reg  [4:0]  r_btn;
  wire [2:0]  w_led;
  initial begin
    #10 r_btn <= 5'b00000;
    #10 r_btn <= 5'b11111;
    #10 r_btn <= 5'b00010;
  end
  always@(*) #1 $display(" %b -> %b", r_btn, w_led);
  m_main m_main0 (r_btn, w_led);
endmodule

module m_main (w_btn, w_led);
  input  wire [4:0] w_btn;
  output wire [2:0] w_led;
  assign w_led[0]  = &w_btn; // same as w_btn[0] & w_btn[1] & w_btn[2] & w_btn[3] & w_btn[4]
  assign w_led[1]  = |w_btn; // same as w_btn[0] | w_btn[1] | w_btn[2] | w_btn[3] | w_btn[4] 
  assign w_led[2]  = ^w_btn; // same as w_btn[0] ^ w_btn[1] ^ w_btn[2] ^ w_btn[3] ^ w_btn[4]
endmodule
