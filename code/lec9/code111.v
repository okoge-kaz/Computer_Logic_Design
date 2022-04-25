/**************************************************************************/
/* code111.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
`timescale 1ns/100ps
`default_nettype none
  
module m_top ();
    reg r_clk=0; initial forever #50 r_clk = ~r_clk;
    reg [31:0] r_pc = 0;
    always @(posedge r_clk) r_pc <= #3 r_pc + 4;
    
    wire [31:0] w_data;
    m_amemory m (r_clk, r_pc[13:2], 1'd0, 32'd0, w_data);
    
    initial $dumpfile("main.vcd"); /* file name for GTKWave */
    initial $dumpvars(0, m_top);   /* module    for GTKWave */
    initial #1000 $finish;
    
    initial begin
        m.cm_ram[0]={6'h0, 5'd0, 5'd0, 5'd0, 5'h0, 6'h20}; // add $0, $0, $0
        m.cm_ram[1]={6'h0, 5'd0, 5'd1, 5'd4, 5'h0, 6'h20}; // add $4, $0, $1
        m.cm_ram[2]={6'h0, 5'd1, 5'd2, 5'd5, 5'h0, 6'h20}; // add $5, $1, $2
        m.cm_ram[3]={6'h0, 5'd4, 5'd5, 5'd6, 5'h0, 6'h20}; // add $6, $4, $5
    end
    always@(*) #80 $write("%3d %d %x\n", $time, r_pc, w_data);
endmodule

module m_amemory (w_clk, w_addr, w_we, w_din, w_dout);
    input  wire w_clk, w_we;
    input  wire [11:0] w_addr;
    input  wire [31:0] w_din;
    output wire [31:0] w_dout;

    reg [31:0] cm_ram [0:4095]; // 4K word (4096 x 32bit) memory
    always @(posedge w_clk) if (w_we) cm_ram[w_addr] <= w_din;
    assign #20 w_dout = cm_ram[w_addr];
endmodule

