// Code your design here
`timescale 1ns/1ns

module clk_gen #(parameter F = 1e3, parameter D = 50, parameter P = 0)(input wire enable, output reg clk);
  
  real clk_period = 1.0/F * 1e9; //converting it to ns
  
  real t_on = D/100.00 * clk_period;
  
  real t_off = (100-D)/100.00 * clk_period;
  
  real clk_qtr = clk_period/4.0;
  
  real start_delay = clk_qtr * P/90.00;
  
 reg start_clk; //signal to start clock
  
  always @(posedge enable, negedge enable)begin
    if(enable)
      begin
        #0 start_clk = 1'b1;
      end
  
  	else begin
      #0 start_clk = 1'b0;
    end
  end
  
  
  initial clk = 'b0;
  initial start_clk = 'b0;
  
  always @(posedge start_clk)
    begin
      if(start_clk)
        clk = 'b1;
       
      while(start_clk)begin
        	#(t_on) clk = 'b0;
            #(t_off) clk ='b1;
        end
      
      clk = 'b1;
    end
  
endmodule
  