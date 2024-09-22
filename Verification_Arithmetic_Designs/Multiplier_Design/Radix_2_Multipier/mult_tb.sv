`include "shift_add_sequential_multiplier.sv"

module tb;
  
  reg clk;
  reg load;
  
  reg [31:0] a;
  reg [31:0] b;
  
  reg signed[31:0] signed_a;
  reg signed [31:0] signed_b;
  
  wire [31:0] out;
  wire signed [31:0] signed_out;
  
  reg sign_multiplicand;
  reg sign_multiplier;
  
  
  shift_add_seq_multiplier smtlr(.clk(clk), .load(load), .sign_multiplicand(sign_multiplicand), .sign_multiplier(sign_multiplier), .multiplicand(a), .multiplier(b), .signed_multiplicand(signed_a), .signed_multiplier(signed_b), .result(out), .signed_result(signed_out));
  defparam smtlr.sign_op = 1'b1;
  
  /* --Assertion to check number of cycles taken by the multiplier*/
  
  property multp_op;
    load |=> ##[1:$] out == a*b;
  endproperty
  
  assert property (@(posedge clk) (multp_op)) $info("Assertion Passed at time %0t", $realtime); else $display("Assertion failed at time %0t", $realtime);
    
 /*---------------------------------------------- */
    
  always #5 clk <= ~clk;

  
  initial clk = 1'b0;
  
  initial begin
    $monitor("At time %0t \t multiplicand : %d \t multiplier : %d \n partial_product : %d \t multiplier_reg : %d \t Expected Result : %d \t Received Result : %d", $realtime, a, (b), (smtlr.partial_product), (smtlr.multiplier_reg),(a*b),(out));
    
   
   
    load = 1'b0;
    
    {sign_multiplicand, sign_multiplier} = {1'b0, 1'b1};
    
    a = 5678982;
    signed_a = 24;
    signed_b = $signed (-24);
    b = (2502684);
    
    
    #5
    load = 1'b1;
    
    #5 load = 1'b0;
    
    #355 begin
      if(signed'(signed_a * signed_b) == signed'(signed_out))
        $display("Multiplier producing correct product");
      else
        $display("Multiplier displaying incorrect results");
    end
    
    #550 $finish(2);
    
  end
  
  initial begin
    $dumpfile("dump_multiples.vcd");
    $dumpvars(1);
  end
    
    initial begin
      $monitor("At time %0t \t multiplicand : %d \t multiplier : %d \n partial_product : %d \t multiplier_reg : %d \t Expected Result : %d \t Received Result : %d", $realtime, $signed(signed_a), $signed(signed_b),$signed(smtlr.signed_partial_product), $signed(smtlr.multiplier_booth_recoded),$signed(signed_a*signed_b),$signed(signed_out));
    end
endmodule 
