// mips_decode: a decoder for MIPS arithmetic instructions
//
// rd_src      (output) - should the destination register be rd (0) or rt (1)
// writeenable (output) - should a new value be captured by the register file
// alu_src2    (output) - should the 2nd ALU source be a register (0), zero extended immediate or sign extended immediate
// alu_op      (output) - control signal to be sent to the ALU
// except      (output) - set to 1 when the opcode/funct combination is unrecognized
// opcode      (input)  - the opcode field from the instruction
// funct       (input)  - the function field from the instruction
//

module mips_decode(rd_src, writeenable, alu_src2, alu_op, except, opcode, funct);
    output       rd_src, writeenable, except;
    output [1:0] alu_src2;
    output [2:0] alu_op;
    input  [5:0] opcode, funct;
    //sub, and, or, nor, xor, addi, andi, ori, xori.

    wire addOut = (opcode == `OP_OTHER0) && (funct == `OP0_ADD); // same opcode for all operations without immediate
    wire subOut = (opcode == `OP_OTHER0) && (funct == `OP0_SUB); 
    wire andOut = (opcode == `OP_OTHER0) && (funct == `OP0_AND);
    wire orOut = (opcode == `OP_OTHER0) && (funct == `OP0_OR);
    wire norOut = (opcode == `OP_OTHER0) && (funct == `OP0_NOR);
    wire xorOut = (opcode == `OP_OTHER0) && (funct == `OP0_XOR);
    wire addiOut = (opcode == `OP_ADDI ); // no funct codes for immediate
    wire andiOut = (opcode == `OP_ANDI);
    wire oriOut = (opcode == `OP_ORI);
    wire xoriOut = (opcode == `OP_XORI);
    
    assign rd_src = (addiOut | andiOut | oriOut | xoriOut);
    assign writeenable = (addOut | subOut | andOut | orOut | norOut | xorOut | addiOut | andiOut | oriOut | xoriOut);
    assign alu_src2[0] = (addiOut);
    assign alu_src2[1] = (oriOut | andiOut | xoriOut);
    assign alu_op[0] = (subOut | orOut | xorOut | oriOut | xoriOut);
    assign alu_op[1] = (addOut | subOut | norOut | xorOut | addiOut | xoriOut);
    assign alu_op[2] = (andOut | orOut | norOut | xorOut | andiOut | oriOut | xoriOut);
    assign except = ~(addOut | subOut | andOut | orOut | norOut | xorOut | addiOut | andiOut | oriOut | xoriOut);

endmodule // mips_decode
