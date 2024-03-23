`include "cache_sequence.sv"

class cache_read_sequence extends uvm_sequence #(cache_sequence_item);
  `uvm_object_utils(cache_read_sequence)
  
  cache_sequence_item cache_item;
  
  function new(input string path = "cache_read_sequence");
    
    super.new(path);
    
    cache_item = cache_sequence_item :: type_id :: create("cache_item");
  
  endfunction
  
  
  task body;
    
    repeat(10) begin
      
      cache_sequence_assert : assert(cache_item.randomize()) $info("Randomization successful"); else $error("Randomization failed");
      
      start_item(cache_item);
      
      cache_item.wr_en = 1'b0; //write enable 0 for read
      
      
      finish_item(cache_item);
     
    end
    
  endtask
  
endclass
