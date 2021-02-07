module alu1_test;

    reg A = 0;
    always #1 A = !A;
    reg B = 0;
    always #2 B = !B;
    reg [2:0] control = 0;
    reg carry_in = 0;
    always #4 carry_in = !carry_in;

    initial begin
        $dumpfile("alu1.vcd");
        $dumpvars(0, alu1_test);
        // change controls
        # 8 control = `ALU_ADD;
        # 8 control = `ALU_SUB;
        # 8 control = `ALU_AND;
        # 8 control = `ALU_OR;
        # 8 control = `ALU_XOR;
        # 8 control = `ALU_NOR;
        # 8 $finish;
    end

    wire out, cout;
    alu1 al1(out, cout, A, B, carry_in, control);
    // exhaustively test your 1-bit ALU implementation by adapting mux4_tb.v
endmodule
