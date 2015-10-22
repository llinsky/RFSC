`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    23:52:10 08/06/2013 
// Design Name: 
// Module Name:    RFSC_stateNew_top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module RFSC_stateNew_top(MemOE, MemWR, RamCS, FlashCS, QuadSpiFlashCS, // Disable the three memory chips

        ClkPort,                           // the 100 MHz incoming clock signal
		
		BtnL, BtnU, BtnD, BtnR,            // the Left, Up, Down, and the Right buttons BtnL, BtnR,
		BtnC,                              // the center button (this is our reset in most of our designs)
		Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0, // 8 switches
		Ld7, Ld6, Ld5, Ld4, Ld3, Ld2, Ld1, Ld0, // 8 LEDs
		An3, An2, An1, An0,			       // 4 anodes
		Ca, Cb, Cc, Cd, Ce, Cf, Cg,        // 7 cathodes
		Dp                                 // Dot Point Cathode on SSDs
	  );
	  
	  	/*  INPUTS */
	// Clock & Reset I/O
	input		ClkPort;	
	// Project Specific Inputs
	input		BtnL, BtnU, BtnD, BtnR, BtnC;	
	input		Sw7, Sw6, Sw5, Sw4, Sw3, Sw2, Sw1, Sw0;
	
	
	/*  OUTPUTS */
	// Control signals on Memory chips 	(to disable them)
	output 	MemOE, MemWR, RamCS, FlashCS, QuadSpiFlashCS;
	// Project Specific Outputs
	// LEDs
	output 	Ld0, Ld1, Ld2, Ld3, Ld4, Ld5, Ld6, Ld7;
	// SSD Outputs
	output 	Cg, Cf, Ce, Cd, Cc, Cb, Ca, Dp;
	output 	An0, An1, An2, An3;	

	
	/*  LOCAL SIGNALS */
	wire		Reset, ClkPort;
	wire		board_clk, sys_clk;
	wire [1:0] 	ssdscan_clk;
	reg [26:0]	DIV_CLK;
	
	
	wire Start;
	wire [2:0] Pin;
	wire [3:0] Cin;
	assign Cin = 4'b0101;
	wire [2:0] SPin;
	wire EN;

	// Outputs
	wire [10:0] AC1;
	wire [10:0] AC2;
	wire [10:0] AC3;
	wire [10:0] AC4;
	wire [10:0] AC5;
	wire [10:0] AC6;
	wire [10:0] AC7;
	wire [10:0] AC8;
	wire update;
	
	
	assign {Pin,SPin} = {Sw5,Sw4,Sw3,Sw2,Sw1,Sw0};
	assign EN = Sw6;
	
	assign Start = BtnL;
	assign Reset = BtnC;
//------------	
// Disable the three memories so that they do not interfere with the rest of the design.
	assign {MemOE, MemWR, RamCS, FlashCS, QuadSpiFlashCS} = 5'b11111;
	
	BUFGP BUFGP1 (board_clk, ClkPort); 	
	// BUFGP BUFGP2 (Reset, BtnC); In the case of Spartan 3E (on Nexys-2 board), we were using BUFGP to provide global routing for the reset signal. But Spartan 6 (on Nexys-3) does not allow this.
	assign Reset = BtnC;
	
	always @(posedge board_clk, posedge Reset) 	
    begin							
        if (Reset)
		DIV_CLK <= 0;
        else
		DIV_CLK <= DIV_CLK + 1'b1;
    end
//-------------------	
	// In this design, we run the core design at full 50MHz clock!
	assign	sys_clk = board_clk;
	//assign	sys_clk = DIV_CLK[24];
	

	// Instantiate the Unit Under Test (UUT)
	RFSC_stateNew uut (
		.Clk(sys_clk), 
		.Reset(Reset), 
		.Start(Start), 
		.Pin(Pin), 
		.Cin(Cin), 
		.SPin(SPin), 
		.AC1(AC1), 
		.AC2(AC2), 
		.AC3(AC3), 
		.AC4(AC4), 
		.AC5(AC5), 
		.AC6(AC6), 
		.AC7(AC7), 
		.AC8(AC8), 
		.EN(EN), 
		.update(update)
	);
	
	assign Ld7 = update;

endmodule
