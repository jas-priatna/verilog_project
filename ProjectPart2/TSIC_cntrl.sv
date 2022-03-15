//////////////////////////////////////////////////////////
//
// Author1:  Harry Rosmann <-- Fill in name here
// Author2:  Jasmine Priatna <-- Fill in partner name here
//
//////////////////////////////////////////////////////////
module TSIC_cntrl(
  input clk,rst_n,		// clock and active low reset
  input cmd_rdy,		// indicates new command from serial comm ready
  input [1:0] cmd,		// upper 2-bits of command
  input cmplt,			// indicates A2D conversion complete
  output logic strt,	// tells A2D to start conversion
  output logic WE,		// Write Enable to EEPROM
  output logic addr,	// address to EEPROM (0=> offset, 1=>gain)
  output logic wrtTmp,	// enables temporary register to update
  output logic mult,	// selects multiply operation as result
  output logic trmt		// tells serial comm to transmit result
);

    //////////////////////////////////////////////////////////////////////////
	// Define your SM states.  This is just example code.  You should give //
	// states meaningful names and you may need more states than shown    //
	///////////////////////////////////////////////////////////////////////
	typedef enum logic[5:0] {INIT=6'b000001, OFF_GAIN=6'b000010, TEMP_OFF=6'b000100,
		TEMP_GAIN=6'b001000, WAIT=6'b010000} state_t;
  
  	///////////////////////////////////////////
	// Declare state register.  Again your  //
	// number of states could be different //
	////////////////////////////////////////
	state_t nxt_state;
	logic [5:0] state;
	
	//////////////////////////////
	// Instantiate state flops //
	////////////////////////////
    state6_reg iST(.CLK(clk),.CLRN(rst_n),.nxt_state(nxt_state),.state(state));
	
	//////////////////////////////////////////////
	// State transitions and outputs specified //
	// next as combinational logic with case  //
	///////////////////////////////////////////		
	always_comb begin
		/////////////////////////////////////////
		// Default all SM outputs & nxt_state //
		///////////////////////////////////////
		nxt_state = state_t'(state);	// OK...nxt_state done for you
		strt=1'b0; WE=1'b0; addr=1'b0; wrtTmp=1'b0; mult=1'b0; trmt=1'b0;
		
		case (state)
			INIT: begin
				if (cmd_rdy) begin
					if (cmd[1] == 1'b0) begin
						nxt_state = OFF_GAIN;
					end
					else if (cmd == 2'b10) begin
						strt = 1'b1;
						nxt_state = TEMP_OFF;
					end
				end
			end
			OFF_GAIN: begin
				WE = 1'b1;
				addr = cmd[0];
				$display("%b", cmd[0]);
				trmt = 1'b1;
				nxt_state = INIT;
			end
			TEMP_OFF: begin
			wrtTmp = 1'b1;
				if (cmplt) begin
					addr = 1'b0;
					mult = 1'b0;
					nxt_state = TEMP_GAIN;
				end
			end
			TEMP_GAIN: begin
				addr = 1'b1;
				mult = 1'b1;
				nxt_state =  WAIT;
			end
			WAIT: begin
				addr = 1'b1;
				mult = 1'b1;
				trmt = 1'b1;
				nxt_state = INIT;
			end
		endcase
	end	
endmodule	