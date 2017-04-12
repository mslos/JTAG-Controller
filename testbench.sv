//macro for shifting a 32 bit register
`define DELAY_31 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1

`define DELAY_32 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1

`define BYPASS 4'b0000
`define IDCODE 4'b1000
`define ADDR   4'b0100
`define WDATA  4'b1100
`define RDATA  4'b0010

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

  task test_logic_reset;
    begin
      tms = 1'b1; #1 #1
      tms = 1'b1; #1 #1
      tms = 1'b1; #1 #1
      tms = 1'b1; #1 #1
      tms = 1'b1; #1 #1
      tms = 1'b1;
    end
   endtask

  task read_data_register;
    begin
      tdi = 1'b0;
      //run test idle
      tms = 1'b0; #1 #1
      //select DR scan
      tms = 1'b1; #1 #1
      //capture DR
      tms = 1'b0; #1 #1
      //shift DR
      tms = 1'b0; #1 #1
      //shift 31 remaining bits
      tms = 1'b0; `DELAY_31 `DELAY_31
      //go into exit1 DR
      tms = 1'b1; #1 #1
      //update DR
      tms = 1'b1; #1 #1
      //run test idle
      tms = 1'b0; #1 #1
      tms = 1'b0;
    end
  endtask

  task write_data_register;
    input [31:0] data;
    begin
       //run test idle
      tms = 1'b0; #1 #1
      //select DR scan
      tms = 1'b1; #1 #1
      //capture DR
      tms = 1'b0; #1 #1
      //shift DR (changing state)
      tms = 1'b0; #1 #1
      //shift DR (writing)
      tms = 1'b0;
      //shift first 31 bits
      for(integer count = 0; count<31; count++) begin
         tdi = data[count];
      		#1 #1
        tms = 1'b0;
      end
      // shift last bit while leaving shift DR state
      tdi = data[31];
      //go into exit1 DR - (will be next state)
      tms = 1'b1; #1 #1
      //update DR
      tms = 1'b1; #1 #1
      //run test idle
      tms = 1'b0; #1 #1
      tms = 1'b0;
    end
  endtask

  task write_instruction_register;
  input [3:0] instruction;
  begin
    // Have to start from either test_logic_reset or run_test_idle
    //run test idle
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    //move to shift IR
    tms = 1'b1; #1 #1
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0; #1 #1
    // shifting in IR value
    tdi = instruction[0]; #1 #1
    tdi = instruction[1]; #1 #1
    tdi = instruction[2]; #1 #1
    tdi = instruction[3];
    // move into latch IR
    tms = 1'b1; #1 #1
    // move into run_test_idle
    tms = 1'b1; #1 #1
    tms = 1'b0; #1 #1
    tms = 1'b0;
  end
  endtask

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


    test_logic_reset();


    write_instruction_register(`ADDR);
    write_data_register(32'h89abcdef);
    read_data_register();

    #2

    $finish;
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0);
  end

endmodule
