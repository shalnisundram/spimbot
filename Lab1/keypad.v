module keypad(valid, number, a, b, c, d, e, f, g);
   output 	valid;
   output [3:0] number;
   input 	a, b, c, d, e, f, g;
   wire abc, wD, wE, wF, wG;
    
   // determine if key was pressed (valid) 
   or o2(valid, wD, wE, wF, wG);
   or o1(abc, a, b, c);

   and a1(wD, abc, d);
   and a2(wE, abc, e);
   and a3(wF, abc, f);
   and a4(wG, b, g);

   assign number[0] = (a && d) || (c && d) || (b && e) || (a && f) || (c && f);
   assign number[1] = (b && d) || (c && d) || (c && e) || (a && f);
   assign number[2] = (a && e) || (b && e) || (c && e) || (a && f);
   assign number[3] = (b && f) || (c && f);

endmodule // keypad
