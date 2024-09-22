module branch_predictor(input branch_instr, [31:0] branch_address, output reg hit, reg [31:0] predicted_branch);
  
  typedef struct{
    bit [19:0] branch_tag;
    bit predict;   // 0 for not taken, 1 for taken
    bit [1:0] direction; //weakly_taken = 2'b00, weakly_not_taken = 2'b01, strongly_not_taken = 2'b10, strongly_taken = 2'b11 
    bit [31:0] branch_address_history;
  } branch_pattern_table;
  
  
  branch_pattern_table pattern_history[1023:0]; //pattern table with 1024 elements
  
  reg [9:0] counter [1023:0]; //counter to store predictions of branch instructions
  bit [1:0] cptr; //counter pointer
  
  
  enum bit [1:0] {idle = 0, predict_branch = 1, predict_direction = 2} operation;
  
  always@(branch_address) begin
    case(operation)
      idle: begin
        {hit, predicted_branch} = 'b0;
      	operation = branch_instr? predict_branch : idle;
      end
      
      predict_branch: begin
      	if(pattern_history[branch_address[11:2]].branch_tag == branch_address[31:12]) begin
          if(pattern_history[branch_address[11:2]].predict) begin
            	hit = 1'b1;    //branch instruction found
          		predicted_branch = pattern_history[branch_address[11:2]].branch_address_history;
            	operation = predict_direction;
            	counter[branch_address[11:2]][cptr] = pattern_history[branch_address[11:2]].predict;
            	cptr = (cptr == 2'b11)? 0 : cptr + 1;
            	counter[branch_address[11:2]] = counter[branch_address[11:2]] << 1;
          end
          else begin
            hit = 1'b0;
            counter[branch_address[11:2]][cptr] = pattern_history[branch_address[11:2]].predict;
            cptr = (cptr == 2'b11)? 0 : cptr + 1;
            counter[branch_address[11:2]] = counter[branch_address[11:2]] << 1;
          end
          
        end
        else begin
          pattern_history[branch_address[11:2]].branch_tag = branch_address[31:12];
          pattern_history[branch_address[11:2]].branch_address_history = branch_address;
          pattern_history[branch_address[11:2]].predict = 1'b1;
          counter[branch_address[11:2]][cptr] = pattern_history[branch_address[11:2]].predict;
          cptr = (cptr == 2'b11)? 0 : cptr + 1;
          counter[branch_address[11:2]] = counter[branch_address[11:2]] << 1;
          operation = predict_direction;
          predicted_branch = branch_address;
        end
      end
          
      predict_direction:
        begin
          
          if(counter[branch_address[11:2]][1:0] == 2'b00)
            pattern_history[branch_address[11:2]].direction = 2'b00;
          else if(counter[branch_address[11:2]][1:0] == 2'b01)
            pattern_history[branch_address[11:2]].direction = 2'b01;
          else if(counter[branch_address[11:2]][1:0] == 2'b10)
            pattern_history[branch_address[11:2]].direction = 2'b10;
          else if(counter[branch_address[11:2]][1:0] == 2'b11)
            pattern_history[branch_address[11:2]].direction = 2'b11;
          else
            pattern_history[branch_address[11:2]].direction = pattern_history[branch_address[11:2]].direction;
          
        end
       
    endcase
      
  end
  
endmodule
