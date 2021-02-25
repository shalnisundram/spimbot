// mips_decode: a decoder for MIPS arithmetic instructions
//
// alu_op       (output) - control signal to be sent to the ALU
// writeenable  (output) - should a new value be captured by the register file
// rd_src       (output) - should the destination register be rd (0) or rt (1)
// alu_src2     (output) - should the 2nd ALU source be a register (0) or an immediate (1)
// except       (output) - set to 1 when we don't recognize an opdcode & funct combination
// control_type (output) - 00 = fallthrough, 01 = branch_target, 10 = jump_target, 11 = jump_register 
// mem_read     (output) - the register value written is coming from the memory
// word_we      (output) - we're writing a word's worth of data
// byte_we      (output) - we're only writing a byte's worth of data
// byte_load    (output) - we're doing a byte load
// slt          (output) - the instruction is an slt
// lui          (output) - the instruction is a lui
// addm         (output) - the instruction is an addm
// opcode        (input) - the opcode field from the instruction
// funct         (input) - the function field from the instruction
// zero          (input) - from the ALU
//

module mips_decode(alu_op, writeenable, rd_src, alu_src2, except, control_type,
                   mem_read, word_we, byte_we, byte_load, slt, lui, addm,
                   opcode, funct, zero);
    output [2:0] alu_op;
    output [1:0] alu_src2;
    output       writeenable, rd_src, except;
    output [1:0] control_type;
    output       mem_read, word_we, byte_we, byte_load, slt, lui, addm;
    input  [5:0] opcode, funct;
    input        zero;
    // // bne, beq, j, jr, lui, slt, lw, lbu, sw, sb, addm
   // wire op_add, op_sub, op_and, op_or, op_nor, op_xor, op_addi, op_andi, op_ori, op_xori, op_beq, op_bne, op_j, op_jr, op_lui, op_slt, op_lw, op_lbu, op_sw, op_sb, op_addm;

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

    wire beqOut = (opcode == `OP_BEQ);
    wire bneOut = (opcode == `OP_BNE);
    wire jOut = (opcode == `OP_J);
    wire jrOut = (opcode == `OP_OTHER0) && (funct == `OP0_JR);
    wire luiOut = (opcode == `OP_LUI);
    wire sltOut = (opcode == `OP_OTHER0) && (funct == `OP0_SLT); 
    wire lwOut = (opcode == `OP_LW);
    wire lbuOut = (opcode == `OP_LBU);
    wire swOut = (opcode == `OP_SW);
    wire sbOut = (opcode == `OP_SB);
    wire addmOut = (opcode == `OP_OTHER0) && (funct == `OP0_ADDM);
    
    assign alu_op[0] = (subOut | orOut | xorOut | oriOut | xoriOut | beqOut | bneOut | sltOut);
    assign alu_op[1] = (addOut | subOut | norOut | xorOut | addiOut | xoriOut | beqOut | bneOut | swOut | lwOut | lbuOut | sltOut | sbOut | addmOut);
    assign alu_op[2] = (andOut | orOut | norOut | xorOut | andiOut | oriOut | xoriOut);
    assign rd_src = (addiOut | andiOut | oriOut | xoriOut | luiOut | lwOut| lbuOut | sbOut | swOut);

    assign except = ~(addOut | subOut | andOut | orOut | norOut | xorOut | addiOut | andiOut | oriOut | xoriOut | bneOut | beqOut | jOut | jrOut | luiOut | sltOut | lwOut | lbuOut | swOut | sbOut | addmOut);
    
    assign writeenable = (addOut | subOut | andOut | orOut | norOut | xorOut | addiOut | andiOut | oriOut | xoriOut | luiOut | sltOut | lwOut | lbuOut);
    assign alu_src2[0] = (addiOut | lwOut | lbuOut | swOut | sbOut);
    assign alu_src2[1] = (oriOut | andiOut | xoriOut);
    //assign alu_src2 = (addiOut | andiOut | oriOut | xoriOut | luiOut | lwOut | lbuOut | swOut | sbOut);

    assign control_type[0] = (beqOut & zero | (bneOut & ~zero)| jrOut);
    assign control_type[1] = (jOut | jrOut);
    assign mem_read = (lwOut | lbuOut);
    assign word_we = swOut;
    assign byte_we = sbOut;
    assign byte_load = lbuOut;
    assign lui = luiOut;
    assign slt = sltOut;
    assign addm = addmOut; 

endmodule // mips_decode
