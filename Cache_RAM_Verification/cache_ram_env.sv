`include "cache_ram_agent.sv"

class cache_ram_environment extends uvm_env;
  
 
  `uvm_component_utils(cache_ram_environment)
  
  cache_ram_agent cr_agent;  //agent instance
  
  cache_data_scoreboard cache_scb;  //scoreboard instance
  
  function new(string path = "cache_ram_environment", uvm_component pd = null);
    
    super.new(path, pd);
    
  endfunction
  
  function void build_phase(uvm_phase phase);
    
    super.build_phase(phase);
    
    cr_agent = cache_ram_agent :: type_id :: create("cr_agent", this);
    cache_scb = cache_data_scoreboard :: type_id :: create("cache_scb", this);
    
  endfunction
  
  function void connect_phase(uvm_phase phase);
    
    super.connect_phase(phase);
    cr_agent.cache_mon.monitor_to_scoreboard.connect(cache_scb.scoreboard_read);
    
  endfunction
  
endclass
