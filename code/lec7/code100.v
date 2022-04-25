/**************************************************************************/
/* code100.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none

module m_top ();
    reg [3:0] r_Ctl = 0;
    reg [31:0] r_A=0, r_B=0;
    wire [31:0] w_Out;
    wire w_Zero;
    m_ALU m_ALU0 (r_Ctl, r_A, r_B, w_Out, w_Zero);
    initial begin
        #10 r_A = 32'h00000001; r_B = 32'h00000002; r_Ctl = 2;
        #10 r_A = 32'h00000002; r_B = 32'h00000002; r_Ctl = 0;
        #10 r_A = 32'h00000001; r_B = 32'h00000002; r_Ctl = 6;
    end
    always@(*) #1 $write("%4d: %d %x %x -> %x %d\n",
                         $time, r_Ctl, r_A, r_B, w_Out, w_Zero);
endmodule

module m_ALU (w_Ctl, w_A, w_B, r_Out, w_Zero);
    input [3:0] w_Ctl;
    input [31:0] w_A, w_B;
    output reg [31:0] r_Out;
    output wire w_Zero;
    assign w_Zero = (r_Out==0);

    always@(*)
      case (w_Ctl)
          0:  r_Out <= w_A & w_B;
          1:  r_Out <= w_A | w_B;
          2:  r_Out <= w_A + w_B;
          6:  r_Out <= w_A - w_B;
          7:  r_Out <= (w_A < w_B) ? 1 : 0;
          12: r_Out <= ~(w_A | w_B);
          default: r_Out <= 0;
      endcase
endmodule
