`include "cache_ram_env.sv" 

class cache_test extends uvm_test;
  
  `uvm_component_utils(cache_test)

  cache_ram_environment cache_env;  //environment instance
  
  cache_read_sequence cache_rd_seq; //write sequence instance
  
  
  function new(string ch = "cache_test", uvm_component pd = null);
    
    super.new(ch, pd);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    cache_env = cache_ram_environment :: type_id ::create("cache_env", this);
    
    cache_rd_seq = cache_read_sequence :: type_id :: create("cache_rd_seq");
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    phase.raise_objection(this);
    
    cache_rd_seq.start(cache_env.cr_agent.cseqr);
    
    #50
    
    phase.drop_objection(this);
   
  endtask
  
endclass
