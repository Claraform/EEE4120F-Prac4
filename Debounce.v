module Debounce(
    input clk, 
    input button,
    output reg out 
);

reg previous_state;
reg [21:0]Count; //assume count is null on FPGA configuration

//--------------------------------------------
always @(posedge clk) begin 
    // implement your logic here
 if (button && button != previous_state && &Count) begin		// reset block
    out <= 1'b1;					// reset the output to 1
	 Count <= 0;
	 previous_state <= 1;
  end 
  else if (button && button != previous_state) begin
	 out <= 1'b0;
	 Count <= Count + 1'b1;
  end 
  else begin
	 out <= 1'b0;
	 previous_state <= button;
  end

end 


endmodule

