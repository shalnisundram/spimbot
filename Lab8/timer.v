module timer(TimerInterrupt, cycle, TimerAddress,
             data, address, MemRead, MemWrite, clock, reset);
    output        TimerInterrupt;
    output [31:0] cycle;
    output        TimerAddress;
    input  [31:0] data, address;
    input         MemRead, MemWrite, clock, reset;
    wire          TimerRead, TimerWrite, Acknowledge;
    wire          eqCircuit1c, eqCircuit6c, eqCircuitInterr;
    wire          interrLineReset;

    // complete the timer circuit here

    // HINT: make your interrupt cycle register reset to 32'hffffffff
    //       (using the reset_value parameter)
    //       to prevent an interrupt being raised the very first cycle

    wire [31:0] aluOut, cycleCounterOut, interruptCycleOut;

    register cycleCounter(cycleCounterOut, aluOut, clock, 1, reset);
    register #(32, 32'hffffffff) int_cyc_reg(interruptCycleOut, data, clock, TimerWrite, reset);
    register interruptLine(TimerInterrupt, 1'h1, clock, eqCircuitInterr, interrLineReset);

    alu32 addAlu(aluOut, , , `ALU_ADD, cycleCounterOut, 32'h1);
    tristate tristate1(cycle, cycleCounterOut, TimerRead); 

    assign eqCircuitInterr = (interruptCycleOut == cycleCounterOut);
    assign eqCircuit1c = (address == 'hffff001c);
    assign eqCircuit6c = (address == 'hffff006c);

    assign TimerRead = (MemRead & eqCircuit1c);
    assign TimerWrite = (MemWrite & eqCircuit1c);
    assign Acknowledge = (MemWrite & eqCircuit6c);
    assign TimerAddress = (eqCircuit1c | eqCircuit6c);
    assign interrLineReset = (Acknowledge | reset);


endmodule
