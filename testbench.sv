// Code your testbench here
// or browse Examples

module tb;
  
  reg enable;
  wire clk;
  
  clk_gen #(.F(1e2), .D(60)) cg (.enable(enable), .clk(clk));
  
 // defparam cg.F = 1e9;
  
  initial enable = 'b0;
  
 /* initial begin
    $dumpfile("clock_generation.vcd");
    $dumpvars;
    
  end*/
  
  bit [5:0] delay;
  
 // always #20 enable = ~enable;
  
  initial begin
    $monitor("@%0t enable : %b clk :%b freq :%.1f duty : %0d", $time, enable, clk, cg.F, cg.D);
    
    for(int i = 0; i <5; i++) begin
      delay = i+1;
      #(delay) enable = ~enable;
    end
    
    
    #10000 $finish;
  end
  
  
endmodule