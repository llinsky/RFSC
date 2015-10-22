`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:50:50 07/22/2013 
// Design Name: 
// Module Name:    RFSC_state 
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
module RFSC_stateNew(Clk, Reset, Start, Pin, Cin, SPin, AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, EN, update
    );
	 
	input	Clk, Reset, Start;
	input [2:0] Pin;
	input [3:0] Cin;
	input [2:0] SPin;
	input EN;
	
	reg enable;
	reg [2:0] Pc;
	reg [3:0] Cc;
	reg [2:0] SPc;
	
	reg cycle;
	
	reg [2:0] temp1; // for comparing best state
	reg [2:0] temp2;
	reg [2:0] temp3;
	reg [2:0] temp4;
	reg [2:0] temp5;
	reg [2:0] temp6;
	reg [2:0] temp7;
	reg [2:0] temp8;
	
	reg [10:0] tempReject1; // for adding to queue
	reg [10:0] tempReject2; // also has extra bit so you know when it's empty
	reg [10:0] tempReject3;
	reg [10:0] tempReject4;
	
	reg [2:0] tempSP1; // for fully removing signals
	reg [2:0] tempSP2;
	reg [2:0] tempSP3;
	reg [2:0] tempSP4;
	
	reg [2:0] qtemp1; // for reordering existing queue elements (how far will each element move up?) *max 1 spot
	reg [2:0] qtemp2;
	reg [2:0] qtemp3;
	reg [2:0] qtemp4;
	reg [2:0] qtemp5;
	reg [2:0] qtemp6;
	reg [2:0] qtemp7;
	
	reg [2:0] rSP1; // for adding to queue what position does each rejected signal start at?
	reg [2:0] rSP2;
	reg [2:0] rSP3;
	reg [2:0] rSP4;
	
	output reg [10:0] AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8; 
														// active/inactive, priority, SP, config. 
														//Added one bit to represent empty
														
	reg [10:0] SP [7:0];
	
	reg[3:0] state;
	
	output reg update;
	
	reg [3:0] q_prior_count; //extra bit to prevent overflow
	reg [3:0] q_elem_count;
	
	reg [3:0] q1Length;
	reg [3:0] q2Length;
	reg [3:0] q3Length;
	reg [3:0] q4Length;
	reg [3:0] q5Length;
	reg [3:0] q6Length;
	reg [3:0] q7Length;
	
	
	
	reg new;
	reg tasksRemoved;
	reg flag1;				// flag: are we still cycling?
	
	reg [10:0] Q_1P [6:0];
	reg [10:0] Q_2P [6:0];
	reg [10:0] Q_3P [6:0];
	reg [10:0] Q_4P [6:0];
	reg [10:0] Q_5P [6:0];
	reg [10:0] Q_6P [6:0];
	reg [10:0] Q_7P [6:0];
	
	wire [10:0] current;
	assign current = {1'b1,Pc,SPc,Cc};
	
	wire [10:0] empty; //AC
	assign empty = {11'b01110000000};
	
	
	localparam 	
	Idle = 4'b0001, S_Load = 4'b0010, S_CheckEnable = 4'b0100, S_CheckDisable = 4'b1000, UNK = 4'bXXXX;
	
	

	
	always @(posedge Clk, posedge Reset)
	begin
		
		if (Reset)
		begin
			state = Idle;
			count = 0;
			new = 0;
			tasksRemoved = 0;
			update = 0;
			cycle = 0;
			enable = 0;
			
			AC1 = empty;
			AC2 = empty;
			AC3 = empty;
			AC4 = empty;
			AC5 = empty;
			AC6 = empty;
			AC7 = empty;
			AC8 = empty;
			
			SP[0] = 0;
			SP[1] = 0;
			SP[2] = 0;
			SP[3] = 0;
			SP[4] = 0;
			SP[5] = 0;
			SP[6] = 0;
			SP[7] = 0;
			
			Q_1P[0] = 0;
			Q_1P[1] = 0;
			Q_1P[2] = 0;
			Q_1P[3] = 0;
			Q_1P[4] = 0;
			Q_1P[5] = 0;
			Q_1P[6] = 0;
			Q_1P[7] = 0;
			
			Q_2P[0] = 0;
			Q_2P[1] = 0;
			Q_2P[2] = 0;
			Q_2P[3] = 0;
			Q_2P[4] = 0;
			Q_2P[5] = 0;
			Q_2P[6] = 0;
			Q_2P[7] = 0;
			
			Q_3P[0] = 0;
			Q_3P[1] = 0;
			Q_3P[2] = 0;
			Q_3P[3] = 0;
			Q_3P[4] = 0;
			Q_3P[5] = 0;
			Q_3P[6] = 0;
			Q_3P[7] = 0;
			
			Q_4P[0] = 0;
			Q_4P[1] = 0;
			Q_4P[2] = 0;
			Q_4P[3] = 0;
			Q_4P[4] = 0;
			Q_4P[5] = 0;
			Q_4P[6] = 0;
			Q_4P[7] = 0;
			
			Q_5P[0] = 0;
			Q_5P[1] = 0;
			Q_5P[2] = 0;
			Q_5P[3] = 0;
			Q_5P[4] = 0;
			Q_5P[5] = 0;
			Q_5P[6] = 0;
			Q_5P[7] = 0;
			
			Q_6P[0] = 0;
			Q_6[1] = 0;
			Q_6P[2] = 0;
			Q_6P[3] = 0;
			Q_6P[4] = 0;
			Q_6P[5] = 0;
			Q_6P[6] = 0;
			Q_6P[7] = 0;
			
			Q_7P[0] = 0;
			Q_7P[1] = 0;
			Q_7P[2] = 0;
			Q_7P[3] = 0;
			Q_7P[4] = 0;
			Q_7P[5] = 0;
			Q_7P[6] = 0;
			Q_7P[7] = 0;
			
			
			q1Length = 0;
			q2Length = 0;
			q3Length = 0;
			q4Length = 0;
			q5Length = 0;
			q6Length = 0;
			q7Length = 0;
			
			q_prior_count = 0;
			q_elem_count = 0;
			
			
			Pc = 0;
			Cc = 0;
			SPc = 0;
			
			temp1 = 0;
			temp2 = 0;
			temp3 = 0;
			temp4 = 0;
			temp5 = 0;
			temp6 = 0;
			temp7 = 0;
			temp8 = 0;
			
			tempReject1 = empty; //Do all these temps need to be initialized at reset?
			tempReject2 = empty;
			tempReject3 = empty;
			tempReject4 = empty;
			
			tempSP1 = 0;
			tempSP2 = 0;
			tempSP3 = 0;
			tempSP4 = 0;
			
			qtemp1 = 0;
			qtemp2 = 0;
			qtemp3 = 0;
			qtemp4 = 0;
			qtemp5 = 0;
			qtemp6 = 0;
			qtemp7 = 0;
			
			rSP1 = 0;
			rSP2 = 0;
			rSP3 = 0;
			rSP4 = 0;
			
			flag1 = 0;
		end
		
		else
			case(state)
				Idle:
					begin
						if (Start)
							begin
								state <= S_Load;
								new <= 1;
								enable <= EN;
							end
						else
							begin
								state <= Idle;
							end
					end
				S_Load:
					begin
						if (new || Start)
							begin
								new <= 0;
								Pc <= Pin;
								Cc <= Cin;
								SPc <= SPin;
								cycle <= 0;
								q_elem_count <= 0;
								q_prior_count <= 0;
								enable <= EN;
							end
						else if (cycle)
							begin
								flag1 = 1;
								case (q_prior_count)
									4'b0000:
										begin
											if (q_elem_count >= q1Length)
												begin
													if (Q_2P[0][0])
														begin
															q_prior_count <= 4'b0001;
														end
													else if (Q_3P[0][0])
														begin
															q_prior_count <= 4'b0010;
														end
													else if (Q_4P[0][0])
														begin
															q_prior_count <= 4'b0011;
														end
													else if (Q_5P[0][0])
														begin
															q_prior_count <= 4'b0100;
														end
													else if (Q_6P[0][0])
														begin
															q_prior_count <= 4'b0101;
														end
													else if (Q_7P[0][0])
														begin
															q_prior_count <= 4'b0110;
														end
													else
														begin
															cycle <= 0;
															q_elem_count <= 0;
															q_prior_count <= 0;
															flag1 = 0;
														end
												end
											else
												begin
													Pc <= Q_1[q_elem_count][9:7];
													SPc <= Q_1[q_elem_count][6:4];
													Cc <= Q_1[q_elem_count][3:0];
												end
										end
									4'b0001:
										begin
											if (q_elem_count >= q2Length)
												begin
													if (Q_3P[0][0])
														begin
															q_prior_count <= 4'b0010;
														end
													else if (Q_4P[0][0])
														begin
															q_prior_count <= 4'b0011;
														end
													else if (Q_5P[0][0])
														begin
															q_prior_count <= 4'b0100;
														end
													else if (Q_6P[0][0])
														begin
															q_prior_count <= 4'b0101;
														end
													else if (Q_7P[0][0])
														begin
															q_prior_count <= 4'b0110;
														end
													else
														begin
															cycle <= 0;
															q_elem_count <= 0;
															q_prior_count <= 0;
															flag1 = 0;
														end
												end
											else
												begin
													Pc <= Q_2[q_elem_count][9:7];
													SPc <= Q_2[q_elem_count][6:4];
													Cc <= Q_2[q_elem_count][3:0];
												end
										end
									4'b0011:
										begin
											if (q_elem_count >= q3Length)
												begin
													if (Q_4P[0][0])
														begin
															q_prior_count <= 4'b0011;
														end
													else if (Q_5P[0][0])
														begin
															q_prior_count <= 4'b0100;
														end
													else if (Q_6P[0][0])
														begin
															q_prior_count <= 4'b0101;
														end
													else if (Q_7P[0][0])
														begin
															q_prior_count <= 4'b0110;
														end
													else
														begin
															cycle <= 0;
															q_elem_count <= 0;
															q_prior_count <= 0;
															flag1 = 0;
														end
												end
											else
												begin
													Pc <= Q_3[q_elem_count][9:7];
													SPc <= Q_3[q_elem_count][6:4];
													Cc <= Q_3[q_elem_count][3:0];
												end
										end
									4'b0100:
										begin
											if (q_elem_count >= q4Length)
												begin
													if (Q_5P[0][0])
														begin
															q_prior_count <= 4'b0100;
														end
													else if (Q_6P[0][0])
														begin
															q_prior_count <= 4'b0101;
														end
													else if (Q_7P[0][0])
														begin
															q_prior_count <= 4'b0110;
														end
													else
														begin
															cycle <= 0;
															q_elem_count <= 0;
															q_prior_count <= 0;
															flag1 = 0;
														end
												end
											else
												begin
													Pc <= Q_4[q_elem_count][9:7];
													SPc <= Q_4[q_elem_count][6:4];
													Cc <= Q_4[q_elem_count][3:0];
												end
											end
									4'b0101:
										begin
											if (q_elem_count >= q5Length)
												begin
													if (Q_6P[0][0])
														begin
															q_prior_count <= 4'b0101;
														end
													else if (Q_7P[0][0])
														begin
															q_prior_count <= 4'b0110;
														end
													else
														begin
															cycle <= 0;
															q_elem_count <= 0;
															q_prior_count <= 0;
															flag1 = 0;
														end
												end
											else
												begin
													Pc <= Q_5[q_elem_count][9:7];
													SPc <= Q_5[q_elem_count][6:4];
													Cc <= Q_5[q_elem_count][3:0];
												end
										end
									4'b0110:
										begin
											if (q_elem_count >= q6Length)
												begin
													if (Q_7P[0][0])
														begin
															q_prior_count <= 4'b0110;
														end
													else
														begin
															cycle <= 0;
															q_elem_count <= 0;
															q_prior_count <= 0;
															flag1 = 0;
														end
												end
											else
												begin
													Pc <= Q_6[q_elem_count][9:7];
													SPc <= Q_6[q_elem_count][6:4];
													Cc <= Q_6[q_elem_count][3:0];
												end
										end
									4'b0111:
										begin
											if (q_elem_count >= q7Length)
												begin
													cycle <= 0;
													q_elem_count <= 0;
													q_prior_count <= 0;
													flag1 = 0;
												end
											else
												begin
													Pc <= Q_7[q_elem_count][9:7];
													SPc <= Q_7[q_elem_count][6:4];
													Cc <= Q_7[q_elem_count][3:0];
												end
										end
									default:
										begin
											state <= UNK;
										end
								endcase	
							end
						update <= 0;
						
						//NSL
						if ((new&&enable) || ((~new)&&flag1)) //cycle
							begin
								state <= S_CheckEnable;
							end
						else if (new&&(~enable))
							begin
								state <= S_CheckDisable;
							end
						else
							begin
								state <= Idle;
							end
					end
					
				S_CheckEnable:
					begin
						state <= S_Load;
						if (Cc == 4'b0101) // "01" 1 quadrant "01" on array 1 (only)
							begin
								if (Pc < AC1[9:7] || Pc < AC2[9:7] || Pc < AC3[9:7] || Pc < AC4[9:7] || (~AC1[10]) || (~AC2[10]) || (~AC3[10]) || (~AC4[10])) //is it valid?
									begin
										
										if ((~AC1[10]) || (~AC2[10]) || (~AC3[10]) || (~AC4[10]))
											begin
												if (~AC1[10])
													begin
														if (~AC4[10])
															begin
																AC1 <= current;
																SP[current[6:4]] <= 5'b00001;
															end
														else if (AC2[10] || AC3[10])
															begin
																AC1 <= current;
																SP[current[6:4]] <= 5'b00001;
															end
														else
															begin
																if (~AC3[10])
																	begin
																		AC3 <= current;
																		SP[current[6:4]] <= 5'b00011;
																	end
																else
																	begin
																		AC2 <= current;
																		SP[current[6:4]] <= 5'b00010;
																	end
															end
													end
												else if (~AC2[10])
													begin
														if (~AC3[10])
															begin
																AC2 <= current;
																SP[current[6:4]] <= 5'b00010;
															end
														else if (AC1[10] || AC4[10])
															begin
																AC2 <= current;
																SP[current[6:4]] <= 5'b00010;
															end
														else
															begin
																if (~AC1[10])
																	begin
																		AC1 <= current;
																		SP[current[6:4]] <= 5'b00001;
																	end
																else
																	begin
																		AC4 <= current;
																		SP[current[6:4]] <= 5'b00100;
																	end
															end
													end
												else if (~AC3[10])
													begin
														if (~AC2[10])
															begin
																AC3 <= current;
																SP[current[6:4]] <= 5'b00011;
															end
														else if (AC1[10] || AC4[10])
															begin
																AC3 <= current;
																SP[current[6:4]] <= 5'b00011;
															end
														else
															begin
																if (~AC1[10])
																	begin
																		AC1 <= current;
																		SP[current[6:4]] <= 5'b00001;
																	end
																else
																	begin
																		AC4 <= current;
																		SP[current[6:4]] <= 5'b00100;
																	end
															end
													end
												else if (~AC4[10])
													begin
														if (~AC1[10])
															begin
																AC4 <= current;
																SP[current[6:4]] <= 5'b00100;
															end
														else if (AC2[10] || AC3[10])
															begin
																AC4 <= current;
																SP[current[6:4]] <= 5'b00100;
															end
														else
															begin
																if (~AC3[10])
																	begin
																		AC3 <= current;
																		SP[current[6:4]] <= 5'b00011;
																	end
																else
																	begin
																		AC2 <= current;
																		SP[current[6:4]] <= 5'b00010;
																	end
															end
													end
											end
///////////////////////////////////////////////////////////// Above is for the case of an empty array, Below is for a full array
										else 
											begin
										
										
											temp1 = (AC1[9:7] > AC2[9:7] ? AC1[9:7] : AC2[9:7]);
											temp2 = (AC3[9:7] > AC4[9:7] ? AC3[9:7] : AC4[9:7]);
											temp3 = (temp1 > temp2 ? temp1 : temp2);
										
											if (temp3 == temp1)
												begin
													if (temp3 == AC1[9:7])
														begin
															AC1 <= current;
															tempReject1 = AC1;
															SP[current[6:4]] <= 5'b00001;
															qLength <= qLength + 1;
														end
													else
														begin
															AC2 <= current;
															tempReject1 = AC2;
															SP[current[6:4]] <= 5'b00010;
															qLength <= qLength + 1;
														end
												end
											else if (temp3 == temp2)
												begin
													if (temp3 == AC3[9:7])
														begin
															AC3 <= current;
															tempReject1 = AC3;
															SP[current[6:4]] <= 5'b00011;
															qLength <= qLength + 1;
														end
													else
														begin
															AC4 <= current;
															tempReject1 = AC4;
															SP[current[6:4]] <= 5'b00100;
															qLength <= qLength + 1;
														end
												end
											end
///////////////////////////////////////////////////////////////////// Below: deal with queue stuff and fully removing signals

										//remove signals
										if (tempReject1[10])
											begin
												SP[tempReject1[6:4]] <= 0;
												qLength <= qLength + 1;
												cycle <= 1;
												//count = count + 1;
												
												case(SP[tempReject1[6:4]]) //check 18 configurations to empty AC's. For this array we only need 9
													5'b00001: //state 1, panel 1 (see paper)
														begin
															//can't just set AC's to empty, need to only set AC's empty that new task won't be on
															//for this case, remove nothing (we only took off 1 AC)
														end
													5'b00010:
														begin
														
														end
													5'b00011:
														begin
														
														end
													5'b00100:
														begin
														
														end
													5'b00101:
														begin
															case(SP[current[6:4]]) // only can be going onto one of these 2 states, case by case basis
																5'b00001:
																	begin
																		AC2 <= empty;
																	end
																5'b00010:
																	begin
																		AC1 <= empty;
																	end
															endcase
														end
													5'b00110:
														begin
															case(SP[current[6:4]]) // only can be going onto one of these 2 states, case by case basis
																5'b00010:
																	begin
																		AC4 <= empty;
																	end
																5'b00100:
																	begin
																		AC2 <= empty;
																	end
															endcase
														end
													5'b00111:
														begin
															case(SP[current[6:4]]) // only can be going onto one of these 2 states, case by case basis
																5'b00011:
																	begin
																		AC4 <= empty;
																	end
																5'b00100:
																	begin
																		AC3 <= empty;
																	end
															endcase
														end
													5'b01000:
														begin
															case(SP[current[6:4]]) // only can be going onto one of these 2 states, case by case basis
																5'b00001:
																	begin
																		AC3 <= empty;
																	end
																5'b00011:
																	begin
																		AC1 <= empty;
																	end
															endcase
														end
													5'b01001:
														begin
															case(SP[current[6:4]]) // only can be going onto one of these 2 states, case by case basis
																5'b00001:
																	begin
																		AC2 <= empty;
																		AC3 <= empty;
																		AC4 <= empty;
																	end
																5'b00010:
																	begin
																		AC1 <= empty;
																		AC3 <= empty;
																		AC4 <= empty;
																	end
																5'b00011:
																	begin
																		AC1 <= empty;
																		AC2 <= empty;
																		AC4 <= empty;
																	end
																5'b00100:
																	begin
																		AC1 <= empty;
																		AC2 <= empty;
																		AC3 <= empty;
																	end
															endcase
														end
													default:
														begin
															state <= UNK; //error
														end
												endcase
												
											end
										
										
										new <= 0;
										
										qtemp1 = 0;
										qtemp2 = 1;
										qtemp3 = 2;
										qtemp4 = 3;
										qtemp5 = 4;
										qtemp6 = 5;
										qtemp7 = 6;
										
										rSP1 = 0;
										//rSP2 = 1;
										//rSP3 = 2; //.... etc
										
										// Below: Determine how far up each element in the queue has to move and position of removed tasks
										
										case(q_prior_count)
											4'b0000:
												begin
													
												end
											4'b0001:
												begin
												
												end
											4'b0010:
												begin
												
												end
											4'b0011:
												begin
												
												end
											4'b0100:
												begin
												
												end
											4'b0101:
												begin
												
												end
											4'b0110:
												begin
												
												end
											4'b0111:
												begin
												
												end
											default:
												begin
													state <= UNK;
												end
											endcase
										
										
										
										
											
										update <= 1;
										
										if (tempReject1[10])
											begin
												//SP[tempReject1[6:4]] <= 0;
												//qLength <= qLength + 1;
												//cycle <= 1;
												count <= count + 1;
											end
										
									end
								
////##############################################################################################################	
////##############################################################################################################	
////##############################################################################################################								
								
								else //not valid
									begin
										if (~cycle)
										begin
										tempReject1 = current;
										qLength <= qLength + 1;
										
										count = 0;
									
										new <= 0;
										cycle <= 1;
										
										qtemp1 = 0;
										qtemp2 = 1;
										qtemp3 = 2;
										qtemp4 = 3;
										qtemp5 = 4;
										qtemp6 = 5;
										qtemp7 = 6;
										
										rSP1 = 0;
										//rSP2 = 1;
										//rSP3 = 2; //.... etc
										
										
										
										case (qLength) //this case will just be to decide where to put the existing queue elements, not tempRejects
											4'b0000: // one of these cases for each tempReject. Instead of cascading, this can just be else if chain
												begin
													
												end
											4'b0001:
												begin
													if (tempReject1[9:7] < Q[0][9:7])
														begin
															qtemp1 = qtemp1 + 1;
														end
												end
											4'b0010:
												begin
													if (tempReject1[9:7] < Q[0][9:7])
														begin
															qtemp1 = qtemp1 + 1;
															qtemp2 = qtemp2 + 1;
														end
													else if (tempReject1[9:7] < Q[1][9:7])
														begin
															qtemp2 = qtemp2 + 1;
														end
												end
											4'b0011:
												begin
													if (tempReject1[9:7] < Q[0][9:7])
														begin
															qtemp1 = qtemp1 + 1;
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
														end
													else if (tempReject1[9:7] < Q[1][9:7])
														begin
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
														end
													else if (tempReject1[9:7] < Q[2][9:7])
														begin
															qtemp3 = qtemp3 + 1;
														end
												end
											4'b0100:
												begin
													if (tempReject1[9:7] < Q[0][9:7])
														begin
															qtemp1 = qtemp1 + 1;
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
														end
													else if (tempReject1[9:7] < Q[1][9:7])
														begin
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
														end
													else if (tempReject1[9:7] < Q[2][9:7])
														begin
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
														end
													else if (tempReject1[9:7] < Q[3][9:7])
														begin
															qtemp4 = qtemp4 + 1;
														end
												end
											4'b0101:
												begin
													if (tempReject1[9:7] < Q[0][9:7])
														begin
															qtemp1 = qtemp1 + 1;
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
														end
													else if (tempReject1[9:7] < Q[1][9:7])
														begin
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
														end
													else if (tempReject1[9:7] < Q[2][9:7])
														begin
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
														end
													else if (tempReject1[9:7] < Q[3][9:7])
														begin
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
														end
													else if (tempReject1[9:7] < Q[4][9:7])
														begin
															qtemp5 = qtemp5 + 1;
														end
												end
											4'b0110:
												begin
													if (tempReject1[9:7] < Q[0][9:7])
														begin
															qtemp1 = qtemp1 + 1;
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
														end
													else if (tempReject1[9:7] < Q[1][9:7])
														begin
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
														end
													else if (tempReject1[9:7] < Q[2][9:7])
														begin
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
														end
													else if (tempReject1[9:7] < Q[3][9:7])
														begin
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
														end
													else if (tempReject1[9:7] < Q[4][9:7])
														begin
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
														end
													else if (tempReject1[9:7] < Q[5][9:7])
														begin
															qtemp6 = qtemp6 + 1;
														end
												end
											4'b0111:
												begin
													if (tempReject1[9:7] < Q[0][9:7])
														begin
															qtemp1 = qtemp1 + 1;
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
															qtemp7 = qtemp7 + 1;
														end
													else if (tempReject1[9:7] < Q[1][9:7])
														begin
															qtemp2 = qtemp2 + 1;
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
															qtemp7 = qtemp7 + 1;
														end
													else if (tempReject1[9:7] < Q[2][9:7])
														begin
															qtemp3 = qtemp3 + 1;
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
															qtemp7 = qtemp7 + 1;
														end
													else if (tempReject1[9:7] < Q[3][9:7])
														begin
															qtemp4 = qtemp4 + 1;
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
															qtemp7 = qtemp7 + 1;
														end
													else if (tempReject1[9:7] < Q[4][9:7])
														begin
															qtemp5 = qtemp5 + 1;
															qtemp6 = qtemp6 + 1;
															qtemp7 = qtemp7 + 1;
														end
													else if (tempReject1[9:7] < Q[5][9:7])
														begin
															qtemp6 = qtemp6 + 1;
															qtemp7 = qtemp7 + 1;
														end
													else if (tempReject1[9:7] < Q[6][9:7])
														begin
															qtemp7 = qtemp7 + 1;
														end
												end
											default:
												begin
													qLength <= 0;
												end
										endcase
										
										// this one is for determining position of tempRejects, one case for each tempReject (1 for this case)
										case (qLength) 
											4'b0000: 
												begin
													
												end
											4'b0001:
												begin
													if (Q[0][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 1;
														end
												end
											4'b0010:
												begin
													if (Q[1][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 2;
														end
													else if (Q[0][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 1;
														end
												end
											4'b0011:
												begin
													if (Q[2][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 3;
														end
													else if (Q[1][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 2;
														end
													else if (Q[0][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 1;
														end
												end
											4'b0100:
												begin
													if (Q[3][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 4;
														end
													else if (Q[2][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 3;
														end
													else if (Q[1][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 2;
														end
													else if (Q[0][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 1;
														end
												end
											4'b0101:
												begin
													if (Q[4][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 5;
														end
													else if (Q[3][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 4;
														end
													else if (Q[2][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 3;
														end
													else if (Q[1][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 2;
														end
													else if (Q[0][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 1;
														end
												end
											4'b0110:
												begin
													if (Q[5][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 6;
														end
													else if (Q[4][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 5;
														end
													else if (Q[3][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 4;
														end
													else if (Q[2][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 3;
														end
													else if (Q[1][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 2;
														end
													else if (Q[0][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 1;
														end
												end
											4'b0111:
												begin
													if (Q[6][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 7;
														end
													else if (Q[5][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 6;
														end
													else if (Q[4][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 5;
														end
													else if (Q[3][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 4;
														end
													else if (Q[2][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 3;
														end
													else if (Q[1][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 2;
														end
													else if (Q[0][9:7] < tempReject1[9:7])
														begin
															rSP1 = rSP1 + 1;
														end
												end
											default:
												begin
													qLength <= 0;
												end
										endcase
										
										Q[rSP1] <= tempReject1;
										
										if (Q[0][10])
											begin
												Q[qtemp1] <= Q[0];
											end
										if (Q[1][10])
											begin
												Q[qtemp2] <= Q[1];
											end
										if (Q[2][10])
											begin
												Q[qtemp3] <= Q[2];
											end
										if (Q[3][10])
											begin
												Q[qtemp4] <= Q[3];
											end
										if (Q[4][10])
											begin
												Q[qtemp5] <= Q[4];
											end
										if (Q[5][10])
											begin
												Q[qtemp6] <= Q[5];
											end
										if (Q[6][10])
											begin
												Q[qtemp7] <= Q[6];
											end
											
										end
									
									
										else //not valid, in cycle
										begin
									
											count = count + 1;
											new <= 0;
										end
										
										end
							
							end
						else if (Cc == 4'b1001) //2 quadrants, array 1
							begin
							end
						else if (Cc == 4'b1101) //4 quadrants, array 1
							begin
							end
						else if (Cc == 4'b0110) //1 quadrant, array 2 (only)
							begin
							end
						else if (Cc == 4'b1010) //2 quadrants, array 2
							begin
							end
						else if (Cc == 4'b1110) //4 quadrants, array 2
							begin
							end
						else if (Cc == 4'b0111) // 1 quadrant, either array
							begin
							end
						else if (Cc == 4'b1011) // 2 quadrants, either array
							begin
							end
						else if (Cc == 4'b1111) // 4 quadrants, either array
							begin
							end
						else
							begin
								state <= UNK;
							end
					end
				S_CheckDisable:
					begin
						state <= S_Load;
					end
				default:
					begin
						state <= UNK;
					end
			endcase
	end
	
endmodule
