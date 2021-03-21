`define STATUS_REGISTER 5'd12
`define CAUSE_REGISTER  5'd13
`define EPC_REGISTER    5'd14

module cp0(rd_data, EPC, TakenInterrupt,
           wr_data, regnum, next_pc,
           MTC0, ERET, TimerInterrupt, clock, reset);
    output [31:0] rd_data;
    output [29:0] EPC;
    output        TakenInterrupt;
    input  [31:0] wr_data;
    input   [4:0] regnum;
    input  [29:0] next_pc;
    input         MTC0, ERET, TimerInterrupt, clock, reset;

    wire [31:0] user_status;
    wire [31:0] status_register;
    wire [31:0] cause_register;
    wire [31:0] mtcOut;
    wire [31:0] extended_EPC;
    wire excLevelReset;
    wire EPCEnable;
    wire mtcOut12, mtcOut14;
    wire [29:0] nextPCMuxOut;
    wire topToTakenInterr, bottomToTakenInterr, notStatReg;
    wire exception_level;

    // your Verilog for coprocessor 0 goes here
    register #(32) userStatus(user_status, wr_data, clock, mtcOut12, reset);
    register #(30) EPCRegister(EPC, nextPCMuxOut, clock, EPCEnable, reset);
    
    dffe #(32) exceptionLevel(exception_level, 1'h1, clock, TakenInterrupt, excLevelReset);

    decoder32 decoder1(mtcOut, regnum, MTC0);

    mux2v #(30) nextPCMux(nextPCMuxOut, wr_data[31:2], next_pc, TakenInterrupt);
    mux32v #(32) rdDataMux(rd_data, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, status_register, cause_register, extended_EPC, 
    32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, 32'b0, regnum); // check this

    assign topToTakenInterr = (cause_register[15] & status_register[15]);
    assign bottomToTakenInterr = (notStatReg & status_register[0]);
    assign TakenInterrupt = (topToTakenInterr & bottomToTakenInterr);
    assign notStatReg = (~status_register[1]);

    assign excLevelReset = (reset | ERET);
    assign EPCEnable = (mtcOut14 | TakenInterrupt);

    assign mtcOut12 = mtcOut[12];
    assign mtcOut14 = mtcOut[14];

    // hardcoding status register bits
    assign status_register[31:16] = 16'b0;
    assign status_register[15:8] = user_status[15:8];
    assign status_register[7:2] = 6'b0;
    assign status_register[1] = exception_level;
    assign status_register[0] = user_status[0];

    // hardcoding cause register bits
    assign cause_register[31:16] = 16'b0;
    assign cause_register[15] = TimerInterrupt;
    assign cause_register[14:0] = 15'b0;

    assign extended_EPC[31:2] = EPC[29:0];
    assign extended_EPC[1:0] = 2'b0;

endmodule
