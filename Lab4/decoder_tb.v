module decoder_test;
    reg [5:0] opcode, funct;

    initial begin
        $dumpfile("decoder.vcd");
        $dumpvars(0, decoder_test);

             opcode = `OP_OTHER0; funct = `OP0_ADD; // try addition
        # 10 opcode = `OP_OTHER0; funct = `OP0_SUB; // try subtraction
        # 10 opcode = `OP_OTHER0; funct = `OP0_AND; // try and
        # 10 opcode = `OP_OTHER0; funct = `OP0_OR; // try or
        # 10 opcode = `OP_OTHER0; funct = `OP0_XOR; // try xor
        # 10 opcode = `OP_OTHER0; funct = `OP0_NOR; // try nor
        # 10 opcode = `OP_ADDI; // try addi
        # 10 opcode = `OP_ANDI; // try andi
        # 10 opcode = `OP_ORI; // try ori
        # 10 opcode = `OP_XORI; // try xori

        #10 opcode = `OP0_SUBU; // test correct signals for writeenable and except

        # 10 $finish;
    end

    // use gtkwave to test correctness
    wire [2:0] alu_op;
    wire [1:0] alu_src2; 
    wire       rd_src, writeenable, except;
    mips_decode decoder(rd_src, writeenable, alu_src2, alu_op, except,
                        opcode, funct);
endmodule // decoder_test
