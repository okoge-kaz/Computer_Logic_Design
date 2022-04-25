/**************************************************************************/
/* code022.v                          For CSC.T341 CLD Archlab TOKYO TECH */
/**************************************************************************/
module m_top ();
  reg  [31:0] r_ir = 32'h1464fffe;
  wire [5:0]  w_op;
  wire [4:0]  w_rs;
  wire [4:0]  w_rt;
  wire [15:0] w_imm;
  initial begin
    #1 $display(" %x -> %x %x %x %x", r_ir, w_op, w_rs, w_rt, w_imm);
    $display(" %b -> ", r_ir);
    $display(" %b %b %b %b", w_op, w_rs, w_rt, w_imm);
  end
  m_decode m_decode0 (r_ir, w_op, w_rs, w_rt, w_imm);
endmodule

module m_decode (w_ir, w_op, w_rs, w_rt, w_imm);
  input  wire [31:0] w_ir;
  output wire [5:0]  w_op;
  output wire [4:0]  w_rs;
  output wire [4:0]  w_rt;
  output wire [15:0] w_imm;
  // bit列からの切り出し
  assign w_op  = w_ir[31:26];
  assign w_rs  = w_ir[25:21];
  assign w_rt  = w_ir[20:16];
  assign w_imm = w_ir[15:0];
endmodule

