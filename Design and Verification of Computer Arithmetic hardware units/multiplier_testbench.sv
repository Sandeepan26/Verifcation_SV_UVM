`include "radix_2_multiplier.sv"

`timescale 1ns/1ns

module tb;
  
  reg clk;
  reg reset;
  reg load;
  reg [31:0] a;
  reg [31:0] b;
  wire [31:0] out;
  
  
  shift_add_seq_multiplier smtlr(clk, load, reset, a, b, out);
  
  always #5 clk <= ~clk;

  
  initial clk = 1'b0;
  
  initial begin
    $monitor("At time %0t \t multiplicand : %d \t multiplier : %d \n partial_product : %d \t Expected Result : %d \t result : %d", $realtime, a, b, smtlr.partial_product, a*b, out);
    
   
    reset = 1'b0;
    load = 1'b0;
    
    a = 2048;
    
    b = 2048;
    
    
    #5
    load = 1'b1;
    
    #5 load = 1'b0;
    
    
    #550 $finish(1);
    
  end
  
  
endmodule
