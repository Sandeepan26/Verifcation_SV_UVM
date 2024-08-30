`include "clock_generator.v"

module tb;
  
  reg enable;
  wire clk;
  
  clk_gen #(.F(1e2), .D(60)) cg (.enable(enable), .clk(clk));
  
 // defparam cg.F = 1e9;
  
  initial enable = 'b0;
  
  bit [5:0] delay;
  
  initial begin
    $monitor("@%0t enable : %b clk :%b freq :%.1f duty : %0d", $time, enable, clk, cg.F, cg.D);
    
    for(int i = 0; i <5; i++) begin
      delay = i+1;
      #(delay) enable = ~enable;
    end
    
    
    #10000 $finish;
  end
  
  
endmodule
