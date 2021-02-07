module logicunit_test;
    // exhaustively test your logic unit implementation by adapting mux4_tb.v
    reg A = 0;
    always #1 A = !A;
    reg B = 0;
    always #2 B = !B;
    reg C = 0;
    always #4 C = !C;
    reg D = 0;
    always #8 D = !D;
     
    reg [1:0] control = 0;
     
    initial begin
        $dumpfile("logicunit.vcd");
        $dumpvars(0, logicunit_test);

        // control is initially 0
        # 16 control = 01; // wait 16 time units (why 16?) and then set it to 1
        # 16 control = 10; // wait 16 time units and then set it to 2
        # 16 control = 11; // wait 16 time units and then set it to 3
        # 16 $finish; // wait 16 time units and then end the simulation
    end

    wire out;
    logicunit l1(out, A, B, C, D, control);
endmodule // logicunit_test
