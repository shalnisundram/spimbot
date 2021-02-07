//implement a test bench for your 32-bit ALU
module alu32_test;
    reg [31:0] A = 0, B = 0;
    reg [2:0] control = 0;

    initial begin
        $dumpfile("alu32.vcd");
        $dumpvars(0, alu32_test);

        // add more test cases here!
             A = 8; B = 4; control = `ALU_ADD; // try adding 8 and 4
        # 10 A = 2147483632; B = 2147483632; control = `ALU_ADD;
        # 10 A = -1879048208; B = -1879048208; control = `ALU_ADD;
        # 10 A = 1; B = 0; control = `ALU_ADD; // test that zero flag = 1
        # 10 A = 36; B = 2147483632; control = `ALU_SUB; // try subtracting a large positive number from a small number
        # 10 A = 2147483632; B = -1879048208; control = `ALU_SUB;
        # 10 A = 2; B = 5; control = `ALU_SUB; // try subtracting 5 from 2  
        # 10 A = 5; B = 5; control = `ALU_SUB; // try subtracting a number from itself
        # 10 A = 1; B = 1; control = `ALU_AND;
        # 10 A = 0; B = 0; control = `ALU_OR;
        # 10 A = 1; B = 0; control = `ALU_NOR;
        # 10 A = 0; B = 1; control = `ALU_XOR;
        # 10 A = 0; B = 1; control = `ALU_NOR;
        # 10 A = 1; B = 0; control = `ALU_XOR;
        # 10 $finish;
    end

    wire [31:0] out;
    wire overflow, zero, negative;
    alu32 a(out, overflow, zero, negative, A, B, control);  
endmodule // alu32_test
