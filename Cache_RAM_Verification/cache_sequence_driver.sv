`include "cache_sequencer.sv"

class cache_sequence_driver extends uvm_driver #(cache_sequence_item);
  
  `uvm_component_utils(cache_sequence_driver)
  
  virtual cache_ram_interface crintf;  //when an interface is used inside a class, it is declared virtual
  
  cache_sequence_item cache_item;
  
  function new(input string path = "cache_sequence_driver", uvm_component parent = null);
    
    super.new(path, parent);
    
    
  endfunction
  
  
  function void build_phase(uvm_phase phase);  //works during elaboration
    
    super.build_phase(phase);
    
    if (uvm_config_db #(virtual cache_ram_interface) :: get(this, " ", "crintf", crintf))
      `uvm_info("Cache Sequence Driver", $sformatf("Interface accessible, proceeding with transaction"), UVM_NONE)
    else
      `uvm_error("Cache Sequence Driver", "Interface not accessible, cannot proceed with the transaction");
    
   
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    
    cache_item = cache_sequence_item :: type_id :: create("cache_item");
    
    forever begin
     // @(posedge crintf.clk);
    seq_item_port.get_next_item(cache_item);   //get_next_item helps with fine grain transaction from the sequencer
    
    //transaction for writing data to the cache and subsequently to the memory
    
    crintf.wr_en <= cache_item.wr_en;
    crintf.cache_request_addr <= cache_item.wr_addr;
    crintf.cache_request_data <= cache_item.wr_data;
    crintf.cache_read_data <= cache_item.rd_data;
    
      
      `uvm_info("Cache Driver", $sformatf("Data sent to the cache as address_sent : %b \t read_write : %b \t data_read_from_memory :%b\t", cache_item.wr_addr, cache_item.wr_en, cache_item.rd_data), UVM_NONE)
      @(posedge crintf.clk);
    seq_item_port.item_done();
    
    
    //@(posedge crintf.clk);
   
      repeat(20) @(posedge crintf.clk);
    end
      
  endtask
  
  
endclass
