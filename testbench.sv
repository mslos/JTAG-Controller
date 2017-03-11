//macro for shifting a 32 bit register
`define DELAY_31 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1

// testbench for JTAG
module jtag_test ();
  localparam REGISTER_SIZE = 4;
  localparam MUX_SIZE = 3;
  localparam  STATE_SIZE = 4;

  reg tck;
  reg tdi;
  wire tdo;
  reg tms;
  reg hresp;
  wire hwrite;
  wire [1:0] htrans;
  wire [31:0] hwdata;
  wire [31:0] haddr;

  // invert clock every 1 cycle
  always #1 tck <= ~tck;

  jtag
  #(.REGISTER_SIZE(32),
    .IR_SIZE(4),
    .STATE_SIZE(4)
   ) jtag_inst
  	(
      .TCK(tck),
      .TDI(tdi),
      .TDO(tdo),
      .TMS(tms),
      .HREADY(1'b1), //permanently ready to write
      .HRDATA(32'hF00F), //data to read from AHB-Lite bus
      .HWRITE(hwrite),
      .HRESP(hresp),
      .HTRANS(htrans),
      .HWDATA(hwdata),
      .HADDR(haddr)
    );

  initial begin
    // init vars
    tck = 1'b0; // clock
    tdi = 1'b0; // input
    tms = 1'b1; // TAP state machine control
    #1

    $display("Starting testbench");

    //Enters test logic reset state
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1

//<-Test of IDCODE register->
    /*
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = 1'b0;
    tms = 1'b0; #1 #1
    tdi = 1'b0;
    tms = 1'b0; #1 #1
    tdi = 1'b0;
    tms = 1'b0; #1 #1
    tdi = 1'b1;
    // move into latch IR
    tms = 1'b1; #1 #1
    //move into shift DR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1;
    `DELAY_31
    `DELAY_31
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1

*/

//<-Test of AHBL ADDRESS instruction->
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = 1'b0; #1 #1
    tdi = 1'b0; #1 #1
    tdi = 1'b1; #1 #1
    tdi = 1'b0;
    // move into latch IR
    tms = 1'b1; #1 #1
    //move into shift DR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1;
    `DELAY_31
    `DELAY_31
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1



//<-Test of AHBL WRITE instruction->
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = 1'b0; #1 #1
    tdi = 1'b0; #1 #1
    tdi = 1'b1; #1 #1
    tdi = 1'b1;
    // move into latch IR
    tms = 1'b1; #1 #1
    //move into shift DR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1;
    `DELAY_31
    `DELAY_31
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1


/*
//<-Test of AHB READ instruction->
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = 1'b0; #1 #1
    tdi = 1'b1; #1 #1
    tdi = 1'b0; #1 #1
    tdi = 1'b0;
    // move into latch IR
    tms = 1'b1; #1 #1
    //move into shift DR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1; #1 #1
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1


    //<-Change IR and set val to read->
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move into shift DR
    tms = 1'b0; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    //shift 32 bits
    tdi = 1'b1;
    `DELAY_31
    `DELAY_31
    //go into exit1 DR
    tms = 1'b1; #1 #1
    //return to run test idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
*/
    #2

    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

endmodule
