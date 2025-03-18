`include "full_adder.v"

module shift_add_seq_multiplier#(parameter bit [9:0] num_bits = 32, parameter bit sign_op = 0)(input clk, load, bit sign_multiplicand, bit sign_multiplier, wire [(num_bits-1):0] multiplicand,  multiplier , signed [(num_bits-1) : 0] signed_multiplicand, signed_multiplier, output reg [(num_bits-1):0] result, reg signed [(num_bits-1):0] signed_result);
  
  reg [((2*num_bits)-1):0] partial_product;
  reg signed [((2*num_bits)-1):0] signed_partial_product; //store the partial sum of addition by multiplier
  
  reg [(num_bits-1):0] multiplier_reg;   //Second operand stored for shifting
  reg signed[(num_bits-1):0][1:0] multiplier_booth_recoded;  //register to store booth recoded version of signed multiplier
  reg [(num_bits/2):0][2:0] multiplicand_booth_recoded; //booth recode for signed multiplicand
  
  reg [($clog2(num_bits)):0] count;  //counter for tracking shifting and addition of partial product with multiplier;
  
  reg [(num_bits-1):0] carry_in;
  wire[(num_bits-1):0] sum_out, carry_out;
  reg [(num_bits-1):0] mux_val;
  
  reg signed[(num_bits-1):0] signed_carry_in;
  wire signed[(num_bits-1):0] signed_sum_out, signed_carry_out;
  reg signed[(num_bits-1):0] signed_mux_val;
  
  reg [(num_bits-1): 0] multiplicand_adder;
  wire [(num_bits-1):0] multiplicand_adder_sum, multiplicand_carry_out;
  reg[(num_bits-1):0] multiplicand_adder_carry_in;
  
  reg[(num_bits-1):0] multiplicand_prod_3;
  
 /*-----Conditional generate to construct adders for unsigned and signed multiplication-------- */ 
  
 generate
   if(!sign_op) begin 
 		for(genvar i = 0; i < num_bits ; i++) begin : generate_adders
      		fa fa_unsigned (partial_product[31+i], mux_val[i], carry_in[i], sum_out[i], carry_out[i]);
    	end : generate_adders
     	
     for(genvar j_0 = 0; j_0 < num_bits; j_0++)begin
       fa fa_multiplicand_adder(multiplicand_adder[j_0], multiplicand[j_0], multiplicand_adder_carry_in[j_0], multiplicand_adder_sum[j_0], multiplicand_carry_out[j_0]); //adder to compute 3*multiplicand
     end
   end

   	else begin
      for(genvar l = 0; l < num_bits ; l++) begin : generate_signed_adders
        fa fa_signed (signed_partial_product[31+l], signed_mux_val[l], signed_carry_in[l], signed_sum_out[l], signed_carry_out[l]);
    	end : generate_signed_adders
    end
    
    
  always_comb begin : set_carry_bits
    if(sign_op == 1'b0)
      begin
    	carry_in[0] = 1'b0;
        multiplicand_adder_carry_in[0] = 1'b0;
    	for(int j = 0; j < (num_bits - 1); j++) begin
    		carry_in[1+j] = carry_out[j];
          multiplicand_adder_carry_in[j+1] = multiplicand_carry_out[j];
    	end //for loop
      end //if
     else begin
     	signed_carry_in[0] = 1'b0;
     	for(int k = 0; k < (num_bits - 1); k++) begin
        	signed_carry_in[1+k] = signed_carry_out[k];
     	end //for
     end  //else   
  end : set_carry_bits
 
 endgenerate
  
  
  /*------------Function to calculate two's complement of either of the operands*/
  
  function automatic bit [num_bits:0] twos_complement ([(num_bits-1):0] operand);
    return ((~operand) + 1'b1);
  endfunction
  
  
  /*---------Function for Booth Recoding/Encoding -------------- */
  
  function automatic bit signed[(num_bits - 1): 0][3:0] booth_encoder([(num_bits-1):0] val);
    for(int i = 0; i <= num_bits-3 ; i++) begin
      case({val[i+2],val[i+1],val[i]})
        3'b000 : booth_encoder[i] = 4'b00_00;
        3'b001 : booth_encoder[i] = 4'b00_01;
        3'b010 : booth_encoder[i] = 4'b01_11;  //1, -1
        3'b011 : booth_encoder[i] = 4'b01_00;
        3'b100 : booth_encoder[i] = 4'b11_00;
        3'b101 : booth_encoder[i] = 4'b11_01;
        3'b110 : booth_encoder[i] = 4'b00_11;
        3'b111 : booth_encoder[i] = 4'b00_00;
        default: booth_encoder[i] = 0;
      endcase
    end
    
    return booth_encoder;
  endfunction
  
  //function for modified booth encoder
  
  function automatic bit signed [(num_bits/2):0][2:0] modif_booth(input bit [(num_bits-1):0][3:0] v);
  	for(int k = 0; k <= (num_bits-1); k++) begin
      case (v[k])
        4'b0000 : begin
          case(k)
            0: modif_booth[0] = 3'b000;
            default: modif_booth[((k/2)+1)] = 3'b000;
          endcase
        end
        4'b0001 : begin
          case(k)
            0: modif_booth[0] = 3'b001;
            default: modif_booth[((k/2)+1)] = 3'b001;
          endcase
        end
        4'b0111 : begin
          case(k)
            0: modif_booth[0] = 3'b001;
            default: modif_booth[((k/2)+1)] = 3'b001;
          endcase
        end
        4'b0100: begin
          case(k)
            0: modif_booth[0] = 3'b010;
            default: modif_booth[((k/2)+1)] = 3'b010;
          endcase
        end
        4'b1100: begin
          case(k)
            0: modif_booth[0] = 3'b110;
            default: modif_booth[((k/2)+1)] = 3'b110;
          endcase
        end
        4'b1101: begin
          case(k)
            0: modif_booth[0] = 3'b101;
            default: modif_booth[((k/2)+1)] = 3'b111;
          endcase
        end
        4'b0011: begin
          case(k)
            0: modif_booth[0] = 3'b101;
            default: modif_booth[((k/2)+1)] = 3'b111;
          endcase
        end
        default: modif_booth[(k/2)+1] = 0; //default value
      endcase
    end
  endfunction
/*-----------------Booth Encoder enclosed--------------------------- */    
  
  //Enumaration to model a Finite State Machine For Multiplication
  
  enum bit [2:0] {IDLE = 3'b000, LOAD = 3'b001, ADD = 3'b010, SHIFT = 3'b011, RES = 3'b100} OP;
  
  // Operation of load, shift, add, and produce output at the positive clock edge
  
  always @(*) multiplicand_prod_3 = multiplicand_adder_sum;
  
  always @(posedge clk) begin : multiplication
    case(OP)
        IDLE: begin
        	{result, signed_result} <= 'b0;
          	count <= 'b0;
          	{mux_val, signed_mux_val} <= 'b0;
          	{partial_product, signed_partial_product} <= 'b0;
          	OP <= load ? LOAD : IDLE;
          	multiplier_booth_recoded <= 'b0;
        end
      
    	LOAD: begin
          	multiplier_reg <= (~sign_multiplier) ? multiplier : 'b0;
          	multiplier_booth_recoded <= sign_multiplier ? modif_booth(booth_encoder(signed_multiplier)) : 'b0;
            multiplicand_adder <= (multiplicand << 1); //2* multiplicand
          	OP <= ADD;
    	end
    
   		ADD: begin
          if(count <= (num_bits/2)) begin
            
            if(sign_multiplier == 1'b0) begin
              mux_val <= multiplier_reg[1] ? multiplier_reg[0] ? multiplicand_prod_3 : (multiplicand_adder) : multiplier_reg[0] ? multiplicand : 'b0;
              {partial_product[(2*(num_bits-1)):(num_bits-1)], signed_partial_product[(2*(num_bits-1)):(num_bits-1)]} <= {sum_out[(num_bits-1):0], {num_bits{1'b0}}};
              {partial_product[((2*num_bits)-1)], signed_partial_product[((2*num_bits)-1)]} <= {carry_out[(num_bits-1)], 1'b0};
            end
            
            else begin
            	if(multiplier_booth_recoded[0] == 3'b110) begin
                  signed_mux_val <= (twos_complement(signed_multiplicand) <<< 1); //x (-2)
                  {partial_product[(2*(num_bits-1)):(num_bits-1)], signed_partial_product[(2*(num_bits-1)):(num_bits-1)]} <= {{num_bits{1'b0}},((signed_sum_out[(num_bits-1):0]))};
                  {partial_product[((2*num_bits)-1)], signed_partial_product[((2*num_bits)-1)]} <= {1'b0,$signed(carry_out[(num_bits-1)])};
              	end
              	else if(multiplier_booth_recoded[0] == 3'b010) begin
                  signed_mux_val <= ($signed(signed_multiplicand) <<< 1);   // x (2)
                  {partial_product[(2*(num_bits-1)):(num_bits-1)], signed_partial_product[(2*(num_bits-1)):(num_bits-1)]} <= {{num_bits{1'b0}},($signed(signed_sum_out[(num_bits-1):0]))};
                  {partial_product[((2*num_bits)-1)], signed_partial_product[((2*num_bits)-1)]} <= {1'b0,$signed(carry_out[(num_bits-1)])};
              	end
              	else if(multiplier_booth_recoded[0] == 3'b001) begin
                  signed_mux_val <= ($signed(signed_multiplicand));   // x (1)
                  {partial_product[(2*(num_bits-1)):(num_bits-1)], signed_partial_product[(2*(num_bits-1)):(num_bits-1)]} <= {{num_bits{1'b0}},($signed(signed_sum_out[(num_bits-1):0]))};
                  {partial_product[((2*num_bits)-1)], signed_partial_product[((2*num_bits)-1)]} <= {1'b0,$signed(carry_out[(num_bits-1)])};
              	end
              	else if(multiplier_booth_recoded[0] == 3'b111) begin
                  signed_mux_val <= (twos_complement(signed_multiplicand));   // x (-1)
                  {partial_product[(2*(num_bits-1)):(num_bits-1)], signed_partial_product[(2*(num_bits-1)):(num_bits-1)]} <= {{num_bits{1'b0}},($signed(signed_sum_out[(num_bits-1):0]))};
                  {partial_product[((2*num_bits)-1)], signed_partial_product[((2*num_bits)-1)]} <= {1'b0,$signed(carry_out[(num_bits-1)])};
              	end
              	
              	else begin
                	signed_mux_val <= ('b0); 
                  {partial_product[(2*(num_bits-1)):(num_bits-1)], signed_partial_product[(2*(num_bits-1)):(num_bits-1)]} <= {{num_bits{1'b0}}, $signed(signed_sum_out[(num_bits-1):0])};
                  {partial_product[((2*num_bits)-1)], signed_partial_product[((2*num_bits)-1)]} <= {{num_bits{1'b0}},$signed(signed_carry_out[(num_bits-1)])};
            	end
            end
              
            
      			count <= count + 1'b1;
            	OP <= SHIFT;
            
        	end
          	else OP <= RES;
         end
      
      	RES: begin
          {result, signed_result} <= sign_multiplier ? {{num_bits{1'b0}}, ($signed(signed_partial_product[(num_bits-1):0]))} : {partial_product[31:0], {num_bits{1'b0}}};
        	OP <= IDLE;
            end
        
    endcase
    
  end : multiplication
  
  
  always @(negedge clk) begin : shift_operation
    if(OP == SHIFT) begin
    	if(sign_multiplier == 1'b0)begin
          if(count < ((num_bits/2) + 2)) begin
            partial_product <= (count < ((num_bits/2)+1)) ?(partial_product >> 2) : (partial_product >> 1) ;
            multiplier_reg <= multiplier_reg >> 2; //2 bit shift
        	end //if  count
        end //sign_multiplier == 1
           
        else begin
          if(count <= 31) begin
                signed_partial_product <= (signed_partial_product >> 1);
        		multiplier_booth_recoded <= multiplier_booth_recoded >> 3;
        	end //if count
        end  //else
          
      	OP <= ADD;
    end // OP == SHIFT
    
      
  end : shift_operation
  
  
 
  
endmodule
  
  
 
  
endmodule
                             
