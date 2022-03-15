module datapath_tb();

  //////////////////////////////////////
  // Declare stimulus signals to DUT //
  ////////////////////////////////////
  logic clk,addr,mult,WE,wrtTmp;
  logic [11:0] a2d,wdata;
 
  //////////////////////////////////////////////////////
  // Declare res[11:0] to connect to DUT output, we  //
  // monitor and check this signal in the testbench //
  ///////////////////////////////////////////////////
  logic [11:0] res;
  
  integer error_cnt;	// used to count test case errors

  //////////////////////
  // Instantiate DUT //
  ////////////////////
  datapath iDUT(.clk(clk),.addr(addr),.mult(mult),.WE(WE),
                .wrtTmp(wrtTmp),.a2d(a2d),.wdata(wdata),.res(res));
				
  ////////////////////////////////////////////////////////
  // Heart of testbench is next.  The initial block    //
  // that applies the stimulus and checks the results //
  /////////////////////////////////////////////////////
  initial begin
    /////////////////////////////////////
	// initialize all stimulus to DUT //
	///////////////////////////////////
	error_cnt = 0;
    clk = 0;
	addr = 0;			// select offset
	mult = 0;			// select Add
	WE = 0;
	wrtTmp = 1;			// writing to temp
	a2d = 12'h89A;		// PTAT = 0x89A
	wdata = 12'hFEE;	// negative 2
	
	@(negedge clk);		// wait for negative edge of clk
	                    // a positive edge occured prior and
						// temporary register was written.
						
	wrtTmp = 0;			// Now ensuring tmp reg does not write
	a2d = 12'h000;		// when it shouldn't
	
	@(negedge clk);		// temp register should still have 0x89A
	
	///////////////////////////////////////////////////////////
	// Next we multiply tmp reg by gain (which is unity) so //
	// result should be what was stored in tmp reg (0x89A) //
	////////////////////////////////////////////////////////
	mult = 1;			// now mutliply by gain term (which is 0x800)
	addr = 1;			// select gain term from EEPROM
	@(negedge clk);		// 0x800 is unity gain
	if (res!==12'h89A) begin
	  $display("ERR: result should be 89A, was %h",res);
	  $display("     Failed a provided test!!!");
    end

    /// Now wrt gain with 0xC00 (which is equivalent to 1.5)
    wdata = 12'hC00;
    WE = 1'b1;
    addr = 1'b1;		// gain will be written on next pos edge

    @(negedge clk);		// wait for next negative edge
    WE = 0;
    ////////////////////////////////////////////////////////////
	// tmp reg should still contain 0x89A, but we are now    //
	// multiplying by 1.5 (0xC00) so result should be 0xCE7 //
	/////////////////////////////////////////////////////////
    @(negedge clk);
	if (res!==12'hCE7) begin		// 89A * 1.5 = CE7
	  $display("ERR: result should be CE7, was %h",res);
	  $display("     Failed a provided test!!!");
	end
	
	//// You fill in many more testcases ////
	
	/////////////////////////////////////
	// Test case if multiply overflow //
	///////////////////////////////////
	$display("---- Testing Multiply Overflow ----\n");
	a2d = 12'hABC;		// load temp with 0xABC
	addr = 0;
	wrtTmp = 1;
	mult = 0;			// select offset
	@(negedge clk);
	addr = 1;			// select gain
	mult = 1;			// now multiplying 0xABC*1.5 = saturate to FFF
	wrtTmp = 0;
	@(negedge clk);
	if (res!==12'hFFF) begin		// ABC * 1.5 = saturate FFF
	  $display("ERR: result should be FFF, was %h\n",res);
	  error_cnt = error_cnt + 1;
	end else $display("GOOD: Mutiply overflow test passed!\n");

	////////////////////////////////////////////////////
	// Test case of negative offset but positive sum //
	//////////////////////////////////////////////////
	$display("---- Testing negative offset with positive sum ----\n");
    wdata = 12'h800;	// return to unity gain
    WE = 1;
    addr = 1;			// write unity to gain
    @(negedge clk);
    wdata = 12'hffe;	// offset of -2
    addr = 0;			// write to offset
    @(negedge clk);
	WE = 0;
    a2d = 12'h003;		// result should be 12'h001
    mult = 0;
    wrtTmp = 1;
    @(negedge clk);		// temp register should have 0x001 now
	wrtTmp = 0;
    mult = 1;
	addr = 1;
    @(negedge clk);
	if (res!==12'h001) begin		// 0x001 * 1 = 0x001
	  $display("ERR: result should be 001, was %h\n",res);
	  error_cnt = error_cnt + 1;
	end else $display("GOOD: negative offset but + sum passed!\n");
	///////////////////////////////////////////////
	// Test case of -PTAT that causes underflow //
	/////////////////////////////////////////////
	$display("---- Testing negative offset that causes underflow ----\n");
	a2d = 12'h001;		// underflow in adder results in 0x000
	mult = 0;
	wrtTmp = 1;
	@(negedge clk);		// temp register should have 0x000 now
	mult = 1;
	addr = 1;
	wrtTmp = 0;
	@(negedge clk);
	if (res!==12'h000) begin		// 0x000 * 1 = 0x000
	  $display("ERR: result should be 000, was %h\n",res);
	  error_cnt = error_cnt + 1;
	end $display("GOOD: passed sum underflow case!\n");
	//////////////////////////////////////////////
	// Test case that causes addition overflow //
	////////////////////////////////////////////
    $display("---- Testing case of addition overflow ----\n");	
	wdata = 12'h555;
	addr = 0;
	WE = 1;				// write offset to 0x555
	@(negedge clk);
	mult = 0;
	WE = 0;
	a2d = 12'hABC;		// 0xABC + 0x555 will overflow
	wrtTmp = 1;
	@(negedge clk);		// temp reg should be 0xFFF
	wrtTmp = 0;
	mult = 1;
	addr = 1;
	@(negedge clk);
	if (res!==12'hFFF) begin		// 0xFFF * 1 = 0xFFF
	  $display("ERR: result should be FFF, was %h\n",res);
	  error_cnt = error_cnt + 1;
	end	else $display("GOOD: case of addition overflow passed!\n");
	/////////////////////////////////////////////
	// Test case with less than unity scaling //
	///////////////////////////////////////////
	$display("---- Testing less than unity scaling ----\n");
    wdata = 12'h600;  	// 0.75
	addr = 1;
    WE = 1;
    @(negedge clk);		// gain is now 0.75
	a2d = 12'h456;
	mult = 0;
	WE = 0;
	wrtTmp = 1;
	addr = 0;
	@(negedge clk);		// temp reg should be 0x9AB
	mult = 1;
	addr = 1;
	wrtTmp = 0;
	@(negedge clk);
	if (res!==12'h740) begin		// 0x9AB * 0.75 = 0x740
	  $display("ERR: result should be 740, was %h\n",res);
	  error_cnt = error_cnt + 1;
	end else $display("GOOD: test with gain < 1 passed!\n");		
	
	if (error_cnt) begin
	  $display("--- FAILED: %d of 5 tests ---",error_cnt);
	  $display("--- PASSED: %d of 5 tests ---\n",5-error_cnt);
	end else
	  $display("YAHOO!! All 5 tests passed!!!");
	$stop();
	  
  end
  
  always
    #5 clk = ~clk;
	
endmodule