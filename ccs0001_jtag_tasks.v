
`define BYPASS 4'b0000
`define IDCODE 4'b1000
`define ADDR   4'b0100
`define WDATA  4'b1100
`define RDATA  4'b0010

// The flipped definitions:
//`define ADDR   4'b0010
//`define WDATA  4'b0011
//`define RDATA  4'b0100

//TODO: How to link tms, tdi, and tdo...etc. to the pads? DONE in test bench
//TODO: write TDO, TDI on negedge since they are captured on posedge DONE by changing to negedge blocking statements

task test_logic_reset;
  begin
    tms = 1'b1;
    repeat(5) begin
      @(negedge CLK);
    end
  end
endtask

task read_data_register;
  begin
    //run test idle
    @(negedge CLK);
    tdi = 1'b0;
    tms = 1'b0;
    //select DR scan
    @(negedge CLK);
    tms = 1'b1;
    //capture DR
    @(negedge CLK);
    tms = 1'b0;
    //shift DR
    @(negedge CLK);
    tms = 1'b0;
    //shift 31 remaining bits
    repeat(31) begin
      @(negedge CLK);
      tms = 1'b0;
    end
    //go into exit1 DR
    @(negedge CLK);
    tms = 1'b1;
    //update DR
    @(negedge CLK);
    tms = 1'b1;
    //run test idle
    @(negedge CLK);
    tms = 1'b0;
  end
endtask

task write_data_register (input integer data);
  //input [31:0] data;
  begin
     //run test idle
    @(negedge CLK);
    tms = 1'b0;
    //select DR scan
    @(negedge CLK);
    tms = 1'b1;
    //capture DR
    @(negedge CLK);
    tms = 1'b0;
    //shift DR (changing state)
    @(negedge CLK);
    tms = 1'b0;
    //shift DR (writing)
    @(negedge CLK);
    tms = 1'b0;
    //shift first 31 bits
    for(integer count = 0; count<31; count++) begin
      @(negedge CLK);
      tdi = data[count];
      tms = 1'b0;
    end
    @(negedge CLK);
    tdi = data[31]; // shift last bit while leaving shift DR state
    tms = 1'b1;     //go into exit1 DR - (will be next state)
    //update DR
    @(negedge CLK);
    tms = 1'b1;
    //run test idle
    @(negedge CLK);
    tms = 1'b0;
  end
endtask

task write_instruction_register(input integer instruction);
//input [3:0] instruction;
begin
  // Have to start from either test_logic_reset or run_test_idle
  //run test idle
  repeat(2) begin
    @(negedge CLK);
    tms = 1'b0;
  end
  //move to shift IR
  @(negedge CLK);
  tms = 1'b1;
  @(negedge CLK);
  tms = 1'b1;
  @(negedge CLK);
  tms = 1'b0;
  @(negedge CLK);
  tms = 1'b0;
  // shifting in IR value
  @(negedge CLK);
  tdi = instruction[0];
  @(negedge CLK);
  tdi = instruction[1];
  @(negedge CLK);
  tdi = instruction[2];
  @(negedge CLK);
  tdi = instruction[3];
  // move into latch IR
  //@(negedge CLK);
  tms = 1'b1;
  // move into run_test_idle
  @(negedge CLK);
  tms = 1'b1;
  @(negedge CLK);
  tms = 1'b0;
  @(negedge CLK);
  tms = 1'b0;
end
endtask


task jtag_write (input integer data,input integer addr);
  begin
    //Test logic reset
    test_logic_reset;
    //Make IR equal to address
    write_instruction_register(`ADDR);
    //Pass address
    write_data_register(addr);
    //Make IR equal to write
    write_instruction_register(`WDATA);
    //Pass data and write
    write_data_register(data);
  end
endtask

task jtag_read (input integer addr);
  begin
    //Test logic reset
    test_logic_reset;
    //Make IR equal to address
    write_instruction_register(`ADDR);
    //Pass address
    write_data_register(addr);
    //Make IR equal to data
    write_instruction_register(`RDATA);
    //Read out data
    read_data_register();
  end
endtask
