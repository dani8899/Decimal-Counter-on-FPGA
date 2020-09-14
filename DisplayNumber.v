`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 	Daniel Ram
// 
// Create Date:    16:08:12 09/04/2020 
// Design Name: 	
// Module Name:    DisplayNumber 
// Project Name: 
// Target Devices: Spartan 3A - XC3S50A
// Tool versions: 
// Description: 
//	Clock Frequency: 12MHz
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//	This circuit control 7 segment display using multiplexing.
//	It display decimal counter to count up to 999 using binary codded decimal.
//////////////////////////////////////////////////////////////////////////////////
module DisplayNumber(
    input clk,
    output [7:0] DATA,
    output [2:0] CTL
    );

	reg reset, increment;
	reg [3:0] digit_one, digit_two, digit_three;
	reg [9:0] number;
	reg [23:0] counter;
	reg [23:0] counter_s;
	reg [1:0] sel;

	wire [1:0] select;
	wire [3:0] mux_to_main_dec;
	wire [7:0] data_out;
	wire [2:0] ctl_out;
	
	assign select = sel;
	
	initial 
	begin
		counter <= 24'd0;
		counter_s <= 24'd0;
		number <= 0;
		digit_one <= 0;
		digit_two <= 0;
		digit_three <= 0;
		reset <= 0;
		increment <= 1;
		sel <= 2'b00;
	end
	

	//BCD counter
	always @(posedge clk)
	begin
		counter <= counter + 1;
		counter_s <= counter_s + 1;
		if(counter >= 12000000)
		begin
			counter <= 0;
			number <= number + 1;
			if(reset)
			begin
				reset <= 0;
				increment <= 1;
				digit_one <= 0;
				digit_two <= 0;
				digit_three <= 0;
				number <= 0;
				sel <= 2'b00;
			end
			else if(increment)
			begin
				//BCD values wrap at 9 
				if(digit_one == 4'd9)
					digit_one <= 0;
				else
					digit_one <= digit_one + 1;

				//Carry when previous digit wraps
				if(digit_one == 4'd9)
				begin
					if(digit_two == 4'd9)
						digit_two <= 0;
					else
						digit_two <= digit_two + 1;
				
					if(digit_two == 4'd9)
					begin
						if(digit_three == 4'd9)
							digit_three <= 0;
						else
							digit_three <= digit_three + 1;
					end		 
				end
			end
		end
		// Multiplex display digits every 0.83ms
		if(counter_s == 10000)
		begin
			counter_s <= 24'd0;
			if(number > 9 && number < 100)
			begin
				sel[0] <= ~sel[0];
			end
			if(number > 99)
			begin
				sel <= sel >= 2'b10 ? 2'b00 : sel + 1;
			end
			if(number > 999)
				reset <= 1;
		end
	end
	
	// Multiplexer between 3 digits
	mux3_1 selector(
		.a(digit_one),
		.b(digit_two),
		.c(digit_three),
		.sel(select),
		.out(mux_to_main_dec)
		);
	
	// Decoder to convert from a number to digit to display
	num_to_digit decoder(
		.clk(clk),
		.num(mux_to_main_dec),
		.digit(data_out)
		);
	
	// Small decoder to select the digit
	small_decoder small_dec(
		.in(select),
		.c(ctl_out)
		);

	assign DATA = ~data_out;
	assign CTL = ~ctl_out;

endmodule

module num_to_digit(
	input clk,
	input [3:0] num,
	output reg [7:0] digit
	);
	
	always @ (posedge clk) begin
		case (num)
			4'b0000 : digit <= 8'b00111111;
			4'b0001 : digit <= 8'b00000110;
			4'b0010 : digit <= 8'b01011011;
			4'b0011 : digit <= 8'b01001111;
			4'b0100 : digit <= 8'b01100110;
			4'b0101 : digit <= 8'b01101101;
			4'b0110 : digit <= 8'b01111101;
			4'b0111 : digit <= 8'b00000111;
			4'b1000 : digit <= 8'b01111111;
			4'b1001 : digit <= 8'b01101111;
			default : digit <= 8'b00000000;
		endcase
	end
	
endmodule

module mux3_1(
	input wire [3:0] a,
	input wire [3:0] b,
	input wire [3:0] c,
	input [1:0] sel,
	output reg [3:0] out
	);
	
	
	always @ (*)
	begin
		case (sel)
			2'b00 : out <= a;
			2'b01 : out <= b;
			2'b10 : out <= c;
			2'b11 : out <= a;
		endcase
	end


endmodule

module small_decoder(
	input [1:0] in,
	output reg [2:0] c
	);
	
	always @ (in[0] or in[1])
	begin
		case (in)
			2'b00 : c <= 3'b100;
			2'b01 : c <= 3'b010;
			2'b10 : c <= 3'b001;
			default : c <= 3'b001;
		endcase
	end
	
endmodule