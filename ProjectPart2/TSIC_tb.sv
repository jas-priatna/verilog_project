//////////////////////////////////////////////////////////
//
// Author1:  _________________ <-- Fill in name here
// Author2:  _________________ <-- Fill in partner name here
//
//////////////////////////////////////////////////////////
module TSIC_tb();

  ///////////////////////////////
  // Declare stimulus signals //
  /////////////////////////////
  logic clk,rst_n;		// clock and active low reset
  logic [15:0] cmd;		// command to set to TSIC
  logic snd_cmd;		// initiate send of cmd to TSIC
  
  ///////////////////////////////////////////
  // Declare any needed testbench signals //
  /////////////////////////////////////////
  integer timeout;
  
  ///////////////////////////////////
  // Declare any internal signals //
  /////////////////////////////////
  wire RX_TX;		// RX of TSIC, TX of testbench comm unit
  wire TX_RX;		// TX of TSIC, RX of testbench comm unit
  wire resp_rdy;	// indicates response came back from TSIC
  wire [15:0] resp;	// response from TSIC (lower 12-bits are temp)
  
  ////////////////////////////////////////////////////////////////////
  // Instantiate TSIC (DUT) your data_path and TSIC_cntrl reside   //
  // inside this block.  This block also contains the PTAT block  //
  // You might want to edit that block to send different raw     // 
  // A2D readings so you can test different cases.              //
  ///////////////////////////////////////////////////////////////
  TSIC iDUT(.clk(clk),.rst_n(rst_n),.RX(RX_TX),.TX(TX_RX));
  
  /////////////////////////////////////////////////////////////
  // Instantiate serial comm unit used to interface to TSIC //
  ///////////////////////////////////////////////////////////
  serial_comm iCOMM(.clk(clk),.rst_n(rst_n),.cmd_rdy(resp_rdy),.cmd(resp),
              .txdata(cmd),.trmt(snd_cmd),.RX(TX_RX),.TX(RX_TX));
  
  initial begin
    clk = 0;
	rst_n = 0;			// assert reset
	@(negedge clk);
	rst_n = 1;			// deasser reset
	
	
	////////////////////////////////////////
	// Test case1: write 0x00B to offset //
	// register and look for response   //
	/////////////////////////////////////
	cmd = 16'h000B;		// write 0x00B to offset register
	snd_cmd = 1;		// send write offset
	@(negedge clk);
	snd_cmd = 0;
	////////////////////////////////////////////////
	// Now look for response from TSIC.  If TSIC //
	// responds resp_rdy of iCOMM will go high. //
	/////////////////////////////////////////////
	timeout = 0;
	while ((timeout<5000) & !resp_rdy) begin
	  @(negedge clk);
	  timeout++;
	end
	if (timeout<5000)
	  $display("GOOD: write offset provided a response");
	else begin
	  $display("ERR: timed out waiting for response on write offset");
	  $stop();
	end
	//// You fill in more test cases ////
	rst_n = 0;			// assert reset
	@(negedge clk);
	rst_n = 1;			// deasser reset
	
	
	////////////////////////////////////////
	// Test case1: write 0x00B to offset //
	// register and look for response   //
	/////////////////////////////////////
	cmd = 16'h001B;		// write 0x00B to offset register
	snd_cmd = 1;		// send write offset
	@(negedge clk);
	snd_cmd = 0;
	////////////////////////////////////////////////
	// Now look for response from TSIC.  If TSIC //
	// responds resp_rdy of iCOMM will go high. //
	/////////////////////////////////////////////
	timeout = 0;
	while ((timeout<5000) & !resp_rdy) begin
	  @(negedge clk);
	  timeout++;
	end
	if (timeout<5000)
	  $display("GOOD: write offset provided a response");
	else begin
	  $display("ERR: timed out waiting for response on write offset");
	  $stop();
	end

	$display("YAHOO! all tests passed");
	$stop();
 end

  //////////////////////////////////////////////////////
  // This block generates clock...don't mess with it //
  ////////////////////////////////////////////////////
  always
    #5 clk = ~clk;
  
endmodule