`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   21:16:50 08/06/2013
// Design Name:   RFSC_stateNew
// Module Name:   C:/Xilinx_projects/RFSC/RFSC_stateNew_tb.v
// Project Name:  RFSC
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: RFSC_stateNew
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module RFSC_stateNew_tb;

	// Inputs
	reg Clk;
	reg Reset;
	reg Start;
	reg [2:0] Pin;
	reg [3:0] Cin;
	reg [2:0] SPin;
	reg EN;

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

	// Instantiate the Unit Under Test (UUT)
	RFSC_stateNew uut (
		.Clk(Clk), 
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
	
	always  begin #10; Clk = ~ Clk; end

	initial begin
		// Initialize Inputs
		Clk = 0;
		Reset = 0;
		Start = 0;
		Pin = 0;
		Cin = 0;
		SPin = 0;
		EN = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		Reset = 1;
		#50;
		Reset = 0;
		#50;
		
		#100;
		
		Pin = 3'b011;
		Cin = 4'b0101;
		SPin = 3'b001;
		
		#25;
		Start = 1;
		EN = 1;
		
		#15;
		Start = 0;
		EN = 0;
		//////////////////////////////////
		#100;
		
		Pin = 3'b011;
		Cin = 4'b0101;
		SPin = 3'b011;
		
		#25;
		Start = 1;
		EN = 1;
		
		#15;
		Start = 0;
		EN = 0;
		//////////////////////////////////
		#100;
		
		Pin = 3'b101;
		Cin = 4'b0101;
		SPin = 3'b010;
		
		#25;
		Start = 1;
		EN = 1;
		
		#15;
		Start = 0;
		EN = 0;
		//////////////////////////////////
		#100;
		
		Pin = 3'b110;
		Cin = 4'b0101;
		SPin = 3'b101;
		
		#25;
		Start = 1;
		EN = 1;
		
		#15;
		Start = 0;
		EN = 0;
		//////////////////////////////////
		#100;
		
		Pin = 3'b100;
		Cin = 4'b0101;
		SPin = 3'b110;
		
		#25;
		Start = 1;
		EN = 1;
		
		#15;
		Start = 0;
		EN = 0;
		
		//////////////////////////////////
		
		#100;
		
		Pin = 3'b011;
		Cin = 4'b0101;
		SPin = 3'b100;
		
		#25;
		Start = 1;
		EN = 1;
		
		#15;
		Start = 0;
		EN = 0;
		
		//////////////////////////////////
		
		#100;
		
		Pin = 3'b001;
		Cin = 4'b0101;
		SPin = 3'b111;
		
		#25;
		Start = 1;
		EN = 1;
		
		#15;
		Start = 0;
		EN = 0;
		
		
		
		
		#200;

	end
      
endmodule

