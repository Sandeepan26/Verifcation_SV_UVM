`include "cache_package.sv"
`include "ram.sv"
`include "cache_ram_interface.sv"

module cache_mem(input w_e, clk, [31:0] cpu_address, [31:0] cpu_data, [31:0] mem_to_cache_data, output reg [31:0] cache_data_out, cache_to_mem_data, wire[31:0] cache_to_mem_address, wire wr_mem);
  
  assign cache_to_mem_address = cpu_address;
  assign wr_mem = w_e ? 1'b1 : 1'b0;
    
  import cache_ram :: cache_block;  //importing the structure to this scope only
  
  enum bit [1:0] {idle = 2'b00, compare_tag = 2'b01, allocate = 2'b10, write_through = 2'b11} operation;
  
  cache_block cache_blk [0:1023];  //1024 cache blocks
  
  
bit hit, miss;
reg [31:0] req_address;
  
  
  always @(posedge clk)
    begin
    case(operation)
      idle: operation = compare_tag;
      
      compare_tag : 
        begin
          if(cache_blk[(cpu_address[11:2])].tag == cpu_address[31:12])  //tags compared
           begin
             if(cache_blk[cpu_address[11:2]].valid == 1'b1) begin //checked valid bit
            	cache_data_out = cache_blk[cpu_address[11:2]].data;
            	hit = ((cache_blk[cpu_address[11:2]].data == cpu_address[31:12]) && cache_blk[cpu_address[11:2]].valid);
      			operation = idle;
          	end
        	else begin //valid bit not set, no data found, it's a miss
            	miss = 1'b1;
        		operation = allocate;
            end
          end
          else begin
            cache_blk[cpu_address[11:3]].tag = cpu_address[31:12]; //storing tag
            operation = allocate;
          end
        end 
      allocate:
          begin
            if(w_e == 1'b0) begin  // w_e == 0 ? write else read..
              cache_data_out = mem_to_cache_data;
              cache_blk[cpu_address[11:2]].data = mem_to_cache_data;
        		  cache_blk[cpu_address[11:2]].valid = 1'b1; //valid bit set for data available
              operation = (cache_blk[cpu_address[11:2]].valid == 1'b1) ? compare_tag : allocate;
      		end
      		else  //write enable, cache should take the address and data and write it to the main memory 
        		operation = write_through; 
          end
      write_through:
      begin 
      	req_address = cpu_address;
      	//cache_to_mem_address = req_address;
        cache_blk[cpu_address[11:2]].data = cpu_data;  //storing cpu data as a write back buffer 
      	//wr_mem = 'b1;  //for writing to the main memory
        cache_to_mem_data = cache_blk[cpu_address[11:2]].data;  //sending data to main memory for update
    
        operation = idle;
      end
      
    endcase
    
  end
  
  
endmodule
