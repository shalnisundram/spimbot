// 00 -> AND, 01 -> OR, 10 -> NOR, 11 -> XOR
module logicunit(out, A, B, control);
    output      out;
    input       A, B;
    input [1:0] control;

    wire  w1, w2, w3, w4;
    and a(w1, A, B);
    or o1(w2, A, B);
    nor n1(w3, A, B);
    xor xo(w4, A, B);
    newmux4 m4(out, w1, w2, w3, w4, control);


endmodule // logicunit

module newmux4(out, A, B, C, D, control);
  output      out;
  input       A, B, C, D;
  input [1:0] control;
  wire  wA, wB, wC, wD;

  assign wA = A & (control == 2'b00);
  assign wB = B & (control == 2'b01);
  assign wC = C & (control == 2'b10);
  assign wD = D & (control == 2'b11);
  
  or  o1(out, wA, wB, wC, wD);
endmodule // newmux4