module d_en_ff(
  input CLK,
  input D,			// D input to be flopped
  input CLRN,		// asynch active low clear (reset)
  input PRN,		// asynch active low preset (sets to 1)
  input nRST,		// synch active low reset
  input EN,			// enable signal
  output logic Q
);

  ////////////////////////////////////////////////////
  // Declare any needed internal sigals below here //
  //////////////////////////////////////////////////
logic min1, min2, D_next;
  
  //////////////////////////////////////////////////
  // Using structural verilog (instantiations of //
  // verilog gate primitives) form the D_next   //
  // logic necessary.                          //
  //////////////////////////////////////////////
and and0(min1, nRST, EN, D);
and and1(min2, nRST, ~EN, Q);
or or0(D_next, min1, min2);
  
  //////////////////////////////////////////////
  // Instantiate simple d_ff without enable  //
  // and tie PRN inactive.  Connect D input //    
  // to logic you inferred above.          //
  //////////////////////////////////////////
  d_ff iDFF(.CLK(CLK),.D(D_next),.CLRN(CLRN),.PRN(PRN),.Q(Q));

endmodule
