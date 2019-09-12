/* Sean McTiernan
** CMPS 350 - Fall 2018
** 11-24-18
** Final project 
** 8-bit ALU
*/

// 1-BIT 2:1 MUX
module onebit_2to1_mux(input a, input b, input sel, output out);
	assign out = (a&sel) | (b&~sel); // when sel = 1, select a; when sel = 0, select b
endmodule

// 8-BIT 2:1 MUX
module eightbit_2to1_mux(
	input [7:0] a,
	input [7:0] b,
	input select,
	output [7:0] out
);
	onebit_2to1_mux L7(a[7], b[7], select, out[7]);
	onebit_2to1_mux L6(a[6], b[6], select, out[6]);
	onebit_2to1_mux L5(a[5], b[5], select, out[5]);
	onebit_2to1_mux L4(a[4], b[4], select, out[4]);
	onebit_2to1_mux L3(a[3], b[3], select, out[3]);
	onebit_2to1_mux L2(a[2], b[2], select, out[2]);
	onebit_2to1_mux L1(a[1], b[1], select, out[1]);
	onebit_2to1_mux L0(a[0], b[0], select, out[0]);
endmodule

// 8-BIT ROTATE SHIFTER
// 'a' is shifted by 'b' places
module rotate_shifter_8bit(
	input [7:0] a,
	input [7:0] b,
	output [7:0] out
);
	wire [7:0] temp1, temp2, a_4bitr, rotate2bits, rotate1bit;

	assign a_4bitr[7] = a[3];
	assign a_4bitr[6] = a[2];
	assign a_4bitr[5] = a[1];
	assign a_4bitr[4] = a[0];
	assign a_4bitr[3] = a[7];
	assign a_4bitr[2] = a[6];
	assign a_4bitr[1] = a[5];
	assign a_4bitr[0] = a[4];

	eightbit_2to1_mux rotate_4bits(a_4bitr, a, b[2], temp1); 

	assign rotate2bits[7] = temp1[5];
	assign rotate2bits[6] = temp1[4];
	assign rotate2bits[5] = temp1[3];
	assign rotate2bits[4] = temp1[2];
	assign rotate2bits[3] = temp1[1];
	assign rotate2bits[2] = temp1[0];
	assign rotate2bits[1] = temp1[7];
	assign rotate2bits[0] = temp1[6];

	eightbit_2to1_mux rotate_2bits(rotate2bits, temp1, b[1], temp2);

	assign rotate1bit[7] = temp1[6];
	assign rotate1bit[6] = temp1[5];
	assign rotate1bit[5] = temp1[4];
	assign rotate1bit[4] = temp1[3];
	assign rotate1bit[3] = temp1[2];
	assign rotate1bit[2] = temp1[1];
	assign rotate1bit[1] = temp1[0];
	assign rotate1bit[0] = temp1[7];

	eightbit_2to1_mux rotate_1bit(rotate1bit, temp2, b[0], out);
endmodule

// 1-bit Full Adder Module used in the RCA
module full_adder_1bit(input a, input b, input Cin, output S, output Cout);
	assign Cout = ((a&Cin) | (a&b) | (b&Cin));
	assign S = ((a&~b&~Cin) | (~a&~b&Cin) | (a&b&Cin) | (~a&b&~Cin));
endmodule

// 8-bit RCA Module
module RCA_8bit(
	input [7:0] a,
	input [7:0] b,
	input cin,
	output [7:0] sum
);
	wire cout;
	wire [6:0] carry;

	full_adder_1bit a1(a[0], b[0], cin, sum[0], carry[0]);
	full_adder_1bit a2(a[1], b[1], carry[0], sum[1], carry[1]);
	full_adder_1bit a3(a[2], b[2], carry[1], sum[2], carry[2]);
	full_adder_1bit a4(a[3], b[3], carry[2], sum[3], carry[3]);
	full_adder_1bit a5(a[4], b[4], carry[3], sum[4], carry[4]);
	full_adder_1bit a6(a[5], b[5], carry[4], sum[5], carry[5]);
	full_adder_1bit a7(a[6], b[6], carry[5], sum[6], carry[6]);
	full_adder_1bit a8(a[7], b[7], carry[6], sum[7], cout);
endmodule

// ADD/SUB MODULE 
module addsub(
	input [7:0] a,
	input [7:0] b,
	input select,	// 1 = subtract; 0 = add
	output [7:0] out
);
	wire [7:0] not_b, result;
	assign not_b[7] = ~b[7];
	assign not_b[6] = ~b[6];
	assign not_b[5] = ~b[5];
	assign not_b[4] = ~b[4];
	assign not_b[3] = ~b[3];
	assign not_b[2] = ~b[2];
	assign not_b[1] = ~b[1];
	assign not_b[0] = ~b[0];

	eightbit_2to1_mux addorsub(not_b, b, select, result);
	RCA_8bit adder(a, result, select, out);
endmodule

// 8-BIT 8:1 MUX
module eight_to_one_8bit_mux(
	input [7:0] addition,
	input [7:0] subtraction,
	input [7:0] rotateResult,
	input [7:0] xorResult,
	input [7:0] orResult,
	input [7:0] andResult,
	input [2:0] opCode,	// Tells us what operation we are performing and serves as the select line
	output [7:0] out
);
	reg [7:0] dontcare = 8 'b00000000;
	wire [7:0] m6out, m5out, m4out, m3out, m2out, m1out;
	eightbit_2to1_mux m3(subtraction, addition, opCode[0], m3out);
	eightbit_2to1_mux m4(xorResult, rotateResult, opCode[0], m4out);
	eightbit_2to1_mux m5(andResult, orResult, opCode[0], m5out);
	eightbit_2to1_mux m6(dontcare, dontcare, opCode[0], m6out);
	eightbit_2to1_mux m1(m4out, m3out, opCode[1], m1out);
	eightbit_2to1_mux m2(m6out, m5out, opCode[1], m2out);
	eightbit_2to1_mux m0(m2out, m1out, opCode[2], out);
endmodule

// 8-bit ALU (top-level module)
module ALU_8bit;
	reg [7:0] a, b;
	reg [2:0] opCode;
	wire [7:0] addOrSubResult;
	wire [7:0] rotateShiftResult;
	wire [7:0] xorResult;
	wire [7:0] orResult;
	wire [7:0] andResult;
	wire [7:0] out;

	rotate_shifter_8bit rotation(a, b, rotateShiftResult);
	addsub addOrSub(a, b, opCode[0], addOrSubResult);
	assign xorResult = a^b;
	assign orResult = a|b;
	assign andResult = a&b;

	eight_to_one_8bit_mux eight_to_one_mux(
		addOrSubResult,
		addOrSubResult,
		rotateShiftResult,
		xorResult,
		orResult,
		andResult,
		opCode,
		out
	);

	initial
		begin
			$monitor("\n  Time = ", $time,
					 "\n\t a=\t", a[7], a[6], a[5], a[4], a[3], a[2], a[1], a[0], 
					 "\n\t b=\t", b[7], b[6], b[5], b[4], b[3], b[2], b[1], b[0],
					 "\n\t opCode=\t", opCode[2], opCode[1], opCode[0],
					 "\n\t out=\t", out[7], out[6], out[5], out[4], out[3], out[2], out[1], out[0]);
			#10 a = 8 'b00011001; b = 8 'b00011110; opCode = 3 'b000;
			#10 a = 8 'b00011110; b = 8 'b00011001; opCode = 3 'b001;
			#10 a = 8 'b00001010; b = 8 'b00000101; opCode = 3 'b010;
			#10 a = 8 'b00001111; b = 8 'b00000011; opCode = 3 'b011;
			#10 a = 8 'b00011111; b = 8 'b00001100; opCode = 3 'b101;
			#10 a = 8 'b00001100; b = 8 'b00000101; opCode = 3 'b100;
			#10 $finish;
		end
endmodule