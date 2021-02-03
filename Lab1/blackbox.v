module blackbox(z, q, p, k);
    output z;
    input  q, p, k;
    wire   w00, w08, w09, w12, w17, w21, w26, w27, w33, w40, w43, w48, w58, w65, w69, w78, w82, w86, w90, w91, w93, w97;
    or  o62(z, w21, w43, w97);
    and a47(w21, w27, w91, w65);
    not n31(w65, w93);
    and a52(w43, w91, w93, w27);
    and a3(w97, w48, w17);
    not n55(w48, w91);
    or  o95(w17, w69, w90);
    and a30(w69, w27, w93);
    and a23(w90, w00, w27);
    not n49(w00, w93);
    or  o53(w91, k, w12, p);
    not n71(w12, q);
    or  o11(w93, w78, w08);
    and a77(w78, w33, w82);
    not n20(w33, p);
    not n5(w82, k);
    and a51(w08, p, w09, q);
    not n16(w09, k);
    and a94(w27, w40, w86);
    not n25(w40, k);
    or  o96(w86, p, w58);
    and a41(w58, q, w26);
    not n72(w26, p);
endmodule // blackbox