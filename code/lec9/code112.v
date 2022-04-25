/**************************************************************************/
/* code112.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`timescale 1ns/100ps
`default_nettype none
  
module m_regfile (w_clk, w_rr1, w_rr2, w_wr, w_we, w_wdata, w_rdata1, w_rdata2);
    input  wire        w_clk;
    input  wire [4:0]  w_rr1, w_rr2, w_wr;
    input  wire [31:0] w_wdata;
    input  wire        w_we;
    output wire [31:0] w_rdata1, w_rdata2;
    
    reg [31:0] r[0:31];
    assign w_rdata1 = (w_rr1==0) ? 0 : r[w_rr1];
    assign w_rdata2 = (w_rr2==0) ? 0 : r[w_rr2];
    always @(posedge w_clk) if(w_we) r[w_wr] <= w_wdata;
    
    initial r[1] = 1;
    initial r[2] = 2;
endmodule

