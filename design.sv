// JTAG Registers + TAP Controller
  
//====================================================
// JTAG Implementation
// Design Name : design
// File Name   : design.v
//=====================================================
module jtag (
	input TCK, // clock
	input TDI,
	output reg TDO,
	input TMS
);
//=============Internal Constants======================
parameter REGISTER_SIZE = 32;
parameter IR_SIZE = 4;
parameter STATE_SIZE = 4;
//=============States==================================
parameter TEST_LOGIC_RESET = 4'h0, 
  RUN_TEST_IDLE = 4'hf, 
  SELECT_DR_SCAN = 4'he, 
  CAPTURE_DR = 4'hd, 
  SHIFT_DR = 4'hc, 
  EXIT_1_DR = 4'hb, 
  PAUSE_DR = 4'ha, 
  EXIT_2_DR = 4'h9, 
  UPDATE_DR = 4'h8, 
  SELECT_IR_SCAN = 4'h7, 
  CAPTURE_IR = 4'h6, 
  SHIFT_IR = 4'h5, 
  EXIT_1_IR = 4'h4, 
  PAUSE_IR = 4'h3, 
  EXIT_2_IR = 4'h2, 
  UPDATE_IR = 4'h1;
//=============Input MUX===============================
  parameter BYPASS = 4'b0000;
  parameter IDCODE = 4'd1000;
//=============Internal Variables======================
  reg [IR_SIZE-1:0] IR;
  reg [IR_SIZE-1:0] LATCH_IR;
  reg [STATE_SIZE-1:0] state;
  reg [STATE_SIZE-1:0] next_state;
//==========Code startes Here==========================
always @ (posedge TCK)
begin : JTAG
 case(state)
	TEST_LOGIC_RESET : if (TMS == 1'b1) begin
	             state <= TEST_LOGIC_RESET;
	           end else if (TMS == 1'b0) begin
	             state <= RUN_TEST_IDLE;
	           end
	RUN_TEST_IDLE : if (TMS == 1'b1) begin
	            state <= SELECT_DR_SCAN;
	          end else if (TMS == 1'b0) begin
	            state <= RUN_TEST_IDLE;
	          end
	SELECT_DR_SCAN : if (TMS == 1'b1) begin
	            state <= SELECT_IR_SCAN;
	          end else if (TMS == 1'b0) begin
	            state <= CAPTURE_DR;
	          end
	CAPTURE_DR : if (TMS == 1'b1) begin
	            state <= EXIT_1_DR;
	          end else if (TMS == 1'b0) begin
	            state <= SHIFT_DR;
	          end
	SHIFT_DR : if (TMS == 1'b1) begin
	            state <= EXIT_1_DR;
	          end else if (TMS == 1'b0) begin
	            state <= SHIFT_DR;
	          end
	EXIT_1_DR : if (TMS == 1'b1) begin
	            state <= UPDATE_DR;
	          end else if (TMS == 1'b0) begin
	            state <= PAUSE_DR;
	          end
	PAUSE_DR : if (TMS == 1'b1) begin
	            state <= EXIT_2_DR;
	          end else if (TMS == 1'b0) begin
	            state <= PAUSE_DR;
	          end
	EXIT_2_DR : if (TMS == 1'b1) begin
	            state <= UPDATE_DR;
	          end else if (TMS == 1'b0) begin
	            state <= SHIFT_DR;
	          end
	UPDATE_DR : if (TMS == 1'b1) begin
	            state <= SELECT_DR_SCAN;
	          end else if (TMS == 1'b0) begin
	            state <= RUN_TEST_IDLE;
	          end
	SELECT_IR_SCAN : if (TMS == 1'b1) begin
	            state <= TEST_LOGIC_RESET;
	          end else if (TMS == 1'b0) begin
	            state <= CAPTURE_IR;
	          end
	CAPTURE_IR : if (TMS == 1'b1) begin
	            state <= EXIT_1_IR;
	          end else if (TMS == 1'b0) begin
	            state <= SHIFT_IR;
	          end
	SHIFT_IR : if (TMS == 1'b1) begin
	            state <= EXIT_1_IR;
	          end else if (TMS == 1'b0) begin
	            state <= SHIFT_IR;
	          end
	EXIT_1_IR : if (TMS == 1'b1) begin
	            state <= UPDATE_IR;
	          end else if (TMS == 1'b0) begin
	            state <= PAUSE_IR;
	          end
	PAUSE_IR : if (TMS == 1'b1) begin
	            state <= EXIT_2_IR;
	          end else if (TMS == 1'b0) begin
	            state <= PAUSE_IR;
	          end
	EXIT_2_IR : if (TMS == 1'b1) begin
	            state <= UPDATE_IR;
	          end else if (TMS == 1'b0) begin
	            state <= SHIFT_IR;
	          end
	UPDATE_IR : if (TMS == 1'b1) begin
	            state <= SELECT_DR_SCAN;
	          end else if (TMS == 1'b0) begin
	            state <= RUN_TEST_IDLE;
	          end
	default : state <= TEST_LOGIC_RESET;
  endcase
end

  
//inspiration from opencores.org
reg instruction_tdo;
 
always @ (posedge TCK)
begin
  if (state == TEST_LOGIC_RESET)
    IR[IR_SIZE-1:0] <= 0;
  else if(state == CAPTURE_IR)
    IR <= 4'b0000;
  else if(state == SHIFT_IR)
    IR[IR_SIZE-1:0] <= {TDI, IR[IR_SIZE-1:1]};
end
 
assign instruction_tdo = IR[0];
 
// Updating IR (Instruction Register)
always @ (negedge TCK)
begin
 if (state == TEST_LOGIC_RESET)
    LATCH_IR <= 4'b0000;
  else if(state == UPDATE_IR)
    LATCH_IR <= IR;
end
  
  
// Bypass register
wire  bypassed_tdo;
reg   bypass_reg;
 
always @ (posedge TCK)
begin
  if (state == TEST_LOGIC_RESET)
    bypass_reg <= 1'b0;
  else if (LATCH_IR == BYPASS && state == CAPTURE_DR)
    bypass_reg<= 1'b0;
  else if(LATCH_IR == BYPASS && state == SHIFT_DR)
    bypass_reg<= TDI;
end
 
assign bypassed_tdo = bypass_reg;



// ID Code register
reg [REGISTER_SIZE:0] DR_IDCODE;
wire        idcode_tdo;
 
always @ (posedge TCK)
begin
  if (state == TEST_LOGIC_RESET)
    DR_IDCODE <= 32'hf0f0f0f0;
  else if(LATCH_IR == IDCODE && state == CAPTURE_DR)
    DR_IDCODE <= 32'hf0f0f0f0;
  else if(LATCH_IR == IDCODE && state == SHIFT_DR)
    DR_IDCODE <=  {TDI, DR_IDCODE[REGISTER_SIZE-1:1]};
end
 
assign idcode_tdo = DR_IDCODE[0];
  
  
  
  
// Set TDO
always @ (negedge TCK)
  begin
    case(LATCH_IR)
      IDCODE:            TDO = idcode_tdo;
      default:           TDO = bypassed_tdo;
    endcase
  end
  

 
  
endmodule
