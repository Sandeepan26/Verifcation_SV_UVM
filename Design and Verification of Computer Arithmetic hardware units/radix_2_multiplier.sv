`include "full_adder.v"

module shift_add_seq_multiplier#(parameter num_bits = 32)(input clk, load, reset, [(num_bits-1):0] multiplier, multiplicand, output reg [(num_bits-1):0] result);
  
  reg [((2*num_bits)-1):0] partial_product; 
  
  reg [(num_bits-1):0] multiplier_reg;   //Second operand
  reg [(num_bits-1):0] multiplicand_reg; //First operand
  
  reg [($clog2(num_bits)):0] count;  //counter for tracking shifting and addition of partial product with multiplier;
  
  reg [(num_bits-1):0] carry_in;
  wire [(num_bits-1):0] sum_out, carry_out;
  reg [(num_bits-1):0] mux_val;
  
  
    for(genvar i = 0; i < num_bits ; i++) begin : generate_adders
      fa fa_inst[i] (partial_product[31+i], mux_val[i], carry_in[i], sum_out[i], carry_out[i]);
    end : generate_adders
  
  always_comb begin : set_carry_bits
  	for(int j = 0; j < (num_bits - 1); j++) begin
    	carry_in[0] = 1'b0;
      carry_in[1+j] = carry_out[j];
     end
  end : set_carry_bits
  
      
  
  always @(posedge clk) begin : addition
    
    if(load) begin
      multiplier_reg <= multiplier;
      multiplicand_reg <= multiplicand;
      count <= 'b0;
      mux_val <= 'b0;
      partial_product <= 'b0;
    end
    
    else begin
      if(count < 32) begin
        	mux_val <= multiplier_reg[0] ? multiplicand_reg : 'b0;  //adding with multiplicand is LSB of multiplier is not 0 else 0 be added to the partial_product
      		partial_product[62:31] <= sum_out[31:0]; //storing sum of ith value in (k+i-1)th position in partial_product
      		partial_product[63] <= carry_out[31]; //storing carry out to 2k-1 bit
      		count <= count + 1;
        	result <= 'b0;
        end
      
      else 
        result <= partial_product[31:0];
      
    end
    
  end : addition
  
  
  always @(negedge clk) begin : shift_operation
    
    if(count < 32) begin
    	partial_product <= partial_product >> 1;
    	multiplier_reg <= multiplier_reg >> 1;
    end
    
    else
    {partial_product, multiplier_reg} <= {partial_product, multiplier_reg};
    
  end : shift_operation
  
  
 
  
endmodule
