//////////////////////////////////////////////////////////
//
// Author1: Jasmine Priatna <-- Fill in name here
// Author2: Harry Rosmann <-- Fill in partner name here
//
//////////////////////////////////////////////////////////
module datapath(

  input clk,	// system clock
  input addr,	// 1 select gain, 0 selects offset
  input mult,	// selects multiply result when high
  input WE,		// Write Enable to EEPROM
  input wrtTmp,	// enables temporary register to be written
  input [11:0] a2d,		// unsigned PTAT conversion value
  input [11:0] wdata,	// data to be written to EEPROM
  output [11:0] res		// ALU result
);
  
  
  /////////////////////////////////////////////////////////
  // declare any needed intermediate signals below here //
  ///////////////////////////////////////////////////////
logic [11:0] rdata, tempsum, sum, Q, product;
logic carryout;
logic [23:0] tempproduct;

  
  ///////////////////////////////
  // Instantiate EEPROM model //
  /////////////////////////////
  EEP iEEP(.clk(clk), .addr(addr), .WE(WE), .wdata(wdata),
           .rdata(rdata));

		   
  ///////////////////////////////
  // Implement saturating add //
  /////////////////////////////

// Using a 12-bit Ripple Carry Adder - inputs a2d and rdata
RCA12 rca(.A(a2d), .B(rdata), .Cin(1'b0), .S(tempsum), .Cout(carryout));

// Sum is saturated 
assign sum = ((carryout & ~rdata[11]) ? 3'hFFF : ((tempsum[11] & rdata[11]) ? 3'h000 : tempsum));
// If greater than 0xFFF -> 0xFFF, if negative ->0x000

			   
  /////////////////////////////////////////
  // Implement temporary register       //
  // (use vector of d_en_ff from AHW3) //
  //////////////////////////////////////

// D enabled fip flop - input result
d_en_ff DNF[0:11](.CLK(clk), .D(res), .CLRN(1'b1), 
	.PRN(1'b1), .nRST(1'b1), .EN(wrtTmp), .Q(Q));

  
  /////////////////////////
  // Implement multiply //
  ///////////////////////

// Multiplies rdata by output of the register
assign tempproduct = Q*rdata;
// Truncates product for bits [22:11] 
assign product = (tempproduct[23])? (3'hFFF):(tempproduct[22:11]);
// If bit 23 is one, saturate it to 0xFFF

  ////////////////////////
  // Implement res mux //
  //////////////////////

// if mult is 1 -> product, otherwise sum
assign res = (mult)? (product):(sum);
  
endmodule


///// EEPROM model defined below here //////
// Don't modify anything below this line //
module EEP(clk,addr,WE,wdata,rdata);
  
  input clk;
  input addr;	// 0=>Offset, 1=>Gain
  input WE;		// when asserted addressed location is written
  input [11:0] wdata;	// data to write
  output [11:0] rdata;	// data from addressed location
  
  reg [11:0]mem[0:1];	// declare memory of EEPROM
  
  assign rdata = mem[addr];
  
  always @(posedge clk)
    if (WE)
	  mem[addr] <= wdata;
	  
  //////////////////////////////////////////
  // EEPROM powers up with zero offset   //
  // and a gain of 0x800 which is unity //
  ///////////////////////////////////////  
  initial begin
    mem[0] = 12'h000;
	mem[1] = 12'h800;
  end
endmodule