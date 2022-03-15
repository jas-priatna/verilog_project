module PTAT_A2D(
  input clk,rst_n,		// clock and active low resetstrt
  input strt,			// tells A2D to start a conversion
  output cmplt,			// asserted for 1 clock when A2D done
  output reg [11:0] a2d	// result of A2D conversion
);

  ////////////////////////////////////////////////////////////
  // NOTE: this is only a crude model of an A2D converter  //
  // You can edit the values stored in the "values" array //
  // below to test with values other than those provided //
  ////////////////////////////////////////////////////////
  
  // declare a memory to hold values for A2D results
  reg [11:0]values[0:7];
  
  initial begin
    /// edit below to test with different values for a2d[11:0]
    values[0] = 12'hABC;	// first A2D result
	values[1] = 12'h89A;	// 2nd A2D result
	values[2] = 12'hABC;	// 3rd A2D result
	values[3] = 12'hFFE;	// 4th A2D result
    values[4] = 12'h00C;	// 5th A2D result
	values[5] = 12'h012;	// 6th A2D result
	values[6] = 12'hFF0;	// 7th A2D result
	values[7] = 12'h789;	// 8th A2D result
  end
  
  reg [2:0] indx;	// index into values[]
  reg [3:0] cnt;	// count clocks till cmplt
   
  ///////////////////////////////////////////////////
  // increment indx into values[] upon completion //
  /////////////////////////////////////////////////
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  indx <= 3'b000;
	else if (cnt==4'hC)
	  indx <= indx + 1;
	  
  //////////////////////////////////////////////////
  // cnt times out the conversion.  Freezes at F //
  ////////////////////////////////////////////////  
  always_ff @(posedge clk, negedge rst_n)
    if (!rst_n)
	  cnt <= 4'hF;
	else if (strt)
	  cnt <= 4'h0;
	else if (~&cnt)
	  cnt <= cnt + 4'h1;

  ////////////////////////////////////////
  // flop values[indx] upon completion //
  //////////////////////////////////////
  always_ff @(posedge clk)
    if (cnt==4'hC)
      a2d <= values[indx];

  assign cmplt = (cnt==4'hD) ? 1'b1 : 1'b0;

endmodule  
  
  