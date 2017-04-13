//macro for shifting a 32 bit register
`define DELAY_31 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1

`define DELAY_32 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1 #1

`define BYPASS 4'b0000
`define IDCODE 4'b1000
`define ADDR   4'b0100
`define WDATA  4'b1100
`define RDATA  4'b0010

//TODO: How to link tms, tdi, and tdo...etc. to the pads?

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

task write_data_register (input integer data);
  //input [31:0] data;
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

task write_instruction_register(input integer instruction);
//input [3:0] instruction;
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
    write_instruction_registers();
    //Read out data
    read_data_register();
  end
endtask
