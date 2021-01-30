module blackbox_test;
    reg q, p, k;
    wire out;

    blackbox box(out, q, p, k);

    initial begin
        $dumpfile("blackbox.vcd");
        $dumpvars(0, blackbox_test);

        q = 0; p = 0; k = 0; #10;
        q = 0; p = 0; k = 1; #10;
        q = 0; p = 1; k = 0; #10;
        q = 0; p = 1; k = 1; #10;
        q = 1; p = 0; k = 0; #10;
        q = 1; p = 0; k = 1; #10;
        q = 1; p = 1; k = 0; #10;
        q = 1; p = 1; k = 1; #10;

        $finish;
    end

    initial
        $monitor("At time %2t, q = %d p = %d k = %d out = %d",
            $time, q, p, k, out);

endmodule // blackbox_test
