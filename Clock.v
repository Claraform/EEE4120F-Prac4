//`timescale 1ns / 1ps



module WallClock(
	//inputs - these will depend on your board's constraint files
    input CLK100MHZ,
    input buttonMin,
    input buttonHrs,
    input buttonReset,
    input [7:0] brightness,
	//outputs - these will depend on your board's constraint files
    output [3:0] SegmentDrivers,
    output reg [5:0] LED,
    output test,
    output [7:0] SevenSegment	
);

	//Define wires to carry button signals
    wire Reset;
	wire MButton;
	wire HButton;
	
	//Add delay for reset
	Delay_Reset delay1(CLK100MHZ, buttonReset, Reset);
	
	// Instantiate Debounce modules here
	Debounce dbMinutes(CLK100MHZ, buttonMin,MButton);
	Debounce dbHours(CLK100MHZ, buttonHrs,HButton);
	
	// registers for storing the time
	reg [29:0]Count=30'd0;
	reg [5:0]seconds=6'd0;
    reg [3:0]hours1=4'd0;
	reg [3:0]hours2=4'd0;
	reg [3:0]minutes1=4'd0;
	reg [3:0]minutes2=4'd0;
	
	// Speed of clock
	parameter speed = 78000000;
    
	//Initialize seven segment with pwm
	SS_Driver SS_pwm(CLK100MHZ, Reset, hours2, hours1, minutes2, minutes1, brightness, SegmentDrivers, SevenSegment, test);
	
	//The main logic
	always @(posedge CLK100MHZ) begin
        // Set LEDs to display seconds in binary format
	   	LED[5:0] = seconds[5:0];
		//LED[7:0] = brightness[7:0];
		// Check if minutes button pressed
		if (MButton) begin
		  minutes1 <= minutes1 + 1'b1;
		  // Check if minutes about to overflow
	       if (minutes1 == 4'd9) begin
	           // Check for overflow
	           if (minutes2 == 4'd5) begin
	               minutes1 <= 0;
	               minutes2 <= 0;
	           end
	           else begin
	               // Increment minutes
	               minutes2 <= minutes2 + 1'b1;
	               minutes1 <= 0;
	           end
	       end 
		end
		
		// Check if hours button pressed
		if (HButton) begin
		  hours1 <= hours1 + 1'b1;
		// Do hours
	       if (hours1 == 4'd9) begin
	           hours2 <= hours2 + 1'b1;
	           hours1 <= 4'd0;
	       end
	       else if (hours2 == 4'd2 && hours1 == 4'd3) begin
	           hours1 <= 4'd0;
	           hours2 <= 4'd0;
	       end
		end
		
		//Check if reset button pressed
		if (Reset) begin
		  hours1 <= 0;
		  hours2 <= 0;
		  minutes1 <= 0;
		  minutes2 <= 0;
		  Count <= 0;
		  seconds <= 0;
		end
		
		
		// Increment counter
		Count <= Count + 1'b1;
		// Check if counter has reached maximum
		if (Count == speed) begin
		  // Reset counter
		  Count <= 0;
		  // Increment seconds
		  seconds <= seconds + 1'b1;
	   end
	   // Check if minutes should be incremented
	   if (seconds == 60) begin
	   	   // Increment minutes
	       minutes1 <= minutes1 + 1'b1;
	       // Reset seconds
	       seconds <= 0;
	       // Check if minutes about to overflow
	       if (minutes1 == 4'd9) begin
	           // Check for overflow
	           if (minutes2 == 4'd5) begin
	               minutes1 <= 4'd0;
	               minutes2 <= 4'd0;
	               // Do hours
	               hours1 <= hours1 + 1'b1;
	               if (hours1 == 4'd9) begin
	                   hours1 <= 4'd0;
	                   hours2 <= hours2 + 1'b1;
	               end
	               if (hours2 == 4'd2 && hours1 == 4'd3) begin
	                   hours1 <= 4'd0;
	                   hours2 <= 4'd0;
	               end
	           end
	           else begin
	               // Increment minutes
	               minutes2 <= minutes2 + 1'b1;
	               minutes1 <= 4'd0;
	           end
	       end
	end
end
endmodule  
