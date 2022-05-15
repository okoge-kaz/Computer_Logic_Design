/**************************************************************************/
/* code101.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`default_nettype none

module m_main (w_clk, w_a, w_c, w_dout, w_zero);
    input  wire w_clk, w_a, w_c;
    output wire w_dout, w_zero;
    reg [31:0] r_a=0, r_b=0;
    reg [3:0] r_c=0;
    wire [31:0] w_out;
    assign w_dout = ^w_out;
    always@(posedge w_clk) begin
        r_a <= {w_a, r_a[31:1]};
        r_b <= w_out;
        r_c <= {w_c, r_c[3:1]};
    end
    m_ALU m_ALU0 (r_c, r_a, r_b, w_out, w_zero);
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
