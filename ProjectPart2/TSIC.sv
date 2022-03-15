module TSIC(
  input clk,rst_n,	// clock and active low reset
  input RX,			// serial data input
  output TX			// serial data output
);

  ///////////////////////////////////
  // Declare any internal signals //
  /////////////////////////////////
  logic addr,mult,WE,wrtTmp;		// datapath control signals
  logic [11:0] a2d;					// data from PTAT_A2D to datapath
  logic [15:0] cmd;					// command from serial comm unit
  logic [11:0] res;					// output of datapath to serial comm
  logic cmd_rdy,trmt;				// SM <--> serial comm
  logic strt,cmplt;					// SM <--> A2D
  

  ///////////////////////////
  // Instantiate datapath //
  /////////////////////////
  datapath iDP(.clk(clk),.addr(addr),.mult(mult),.WE(WE),
               .wrtTmp(wrtTmp),.a2d(a2d),.wdata(cmd[11:0]),.res(res));
				
  /////////////////////////////
  // Instantiate control SM //
  ///////////////////////////
  TSIC_cntrl iSM(.clk(clk), .rst_n(rst_n), .cmd_rdy(cmd_rdy), .cmd(cmd[15:14]),
                 .cmplt(cmplt), .strt(strt), .WE(WE), .addr(addr),
				 .wrtTmp(wrtTmp), .mult(mult), .trmt(trmt));

  ///////////////////////////////////
  // Instantiate serial comm unit //
  /////////////////////////////////
  serial_comm iCMM(.clk(clk),.rst_n(rst_n),.cmd_rdy(cmd_rdy),.cmd(cmd),
                   .txdata({4'h0,res}),.trmt(trmt),.RX(RX),.TX(TX));

  ////////////////////////////////////////
  // Instantiate model of PTAT and A2D //
  //////////////////////////////////////
  PTAT_A2D iA2D(.clk(clk),.rst_n(rst_n),.strt(strt),.cmplt(cmplt),.a2d(a2d));

endmodule  

				 