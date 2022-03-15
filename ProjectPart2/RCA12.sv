///////////////////////////////////////////////////////
// RCA4.sv  This design will add two 4-bit vectors  //
// plus a carry in to produce a sum and a carry out//
////////////////////////////////////////////////////
module RCA12(
  input 	[11:0]	A,B,	// two 4-bit vectors to be added
  input 			Cin,	// An optional carry in bit
  output 	[11:0]	S,		// 4-bit Sum
  output 			Cout  	// and carry out
);

	/////////////////////////////////////////////////
	// Declare any internal signals as type logic //
	///////////////////////////////////////////////
	logic [11:0] carryin;  // carryin across bit positions
  	logic [11:0] carryout; // carryout across bit positions

	
	/////////////////////////////////////////////////
	// Implement Full Adder as structural verilog //
	///////////////////////////////////////////////
	assign carryin = {carryout[10:0],Cin}; // construct carryin vector
  	assign Cout = carryout[11];            // extract cout from carryout vector

  	FA smarter[11:0](.A(A), .B(B), .Cin(carryin), .S(S), .Cout(carryout));

	
endmodule