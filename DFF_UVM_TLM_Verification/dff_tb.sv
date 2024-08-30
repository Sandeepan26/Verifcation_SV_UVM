`include "dff_design.sv"

//--------UVM packages-----------------------------------------
`include "uvm_macros.svh"
import uvm_pkg::*;

/* ------------TRANSACTION CLASS------------------------ */

class dff_trns extends uvm_sequence_item;
  `uvm_object_utils(dff_trns)
  
  rand bit d;
  rand bit rst;
  bit q;
  
  constraint dff_cons{(d==1) <-> (rst==0);}
  
  function new(input string path = "dff_trns");
    super.new(path);
  endfunction 
  
endclass : dff_trns

/* ----SEQUENCE GENERATOR CLASS----------------*/

class dff_gen extends uvm_sequence #(dff_trns);
  `uvm_object_utils(dff_gen)
  
  dff_trns tr;
  
  function new(input string path = "dff_gen");
    super.new(path);
  endfunction
  
  task body;
    tr = dff_trns::type_id::create("tr");
    repeat (10) begin
      start_item(tr);
      
 sequence_assertion:assert(tr.randomize()) $info("Assertion passed"); else $info("Assertion Failed");
      
      tr.rst = 1'b0;
      
      finish_item(tr);
    end
   endtask : body
                                
endclass : dff_gen 

/* ---------------DRIVER CLASS----------------------*/

class driver extends uvm_driver #(dff_trns);
  `uvm_component_utils(driver)
  
  dff_trns tr;
  virtual dff_intf dfint;
  
  function new(input string path = "driver", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    if(!uvm_config_db #(virtual dff_intf) :: get(this, "", "dfint", dfint))
       `uvm_error("DRIVER", "Interface not accessible");
     
  endfunction

       virtual task run_phase(uvm_phase phase);
         tr = dff_trns::type_id::create("tr");
         
         forever begin
           seq_item_port.get_next_item(tr);
           
           dfint.d <= tr.d;
           dfint.rst <= tr.rst;
           
           seq_item_port.item_done();
           `uvm_info("DRIVER", $sformatf("Data sent as transaction------\n d: %b rst : %b", tr.d, tr.rst), UVM_NONE)
           
           repeat (10) @ (posedge dfint.clk);
         
         end
       endtask
       
       
endclass : driver
       
/*-----MONITOR CLASS----*/

class monitor extends uvm_monitor;
  `uvm_component_utils(monitor);
  
  uvm_analysis_port #(dff_trns) send;
  dff_trns tr;
  virtual dff_intf dfint;
  
  function new(input string path = "monitor", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    send = new("send", this);
    tr = dff_trns::type_id::create("tr");
    if(!uvm_config_db #(virtual dff_intf)::get(this, "", "dfint", dfint))
      `uvm_error("MONITOR", "Interface not accessible");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    tr = dff_trns::type_id::create("tr");
 
    repeat (10) @(posedge dfint.clk) begin
      tr.d = dfint.d;
      tr.rst = dfint.rst;
      tr.q = dfint.q;
      
      `uvm_info("MONITOR", $sformatf("Data received as transaction------\n d: %b rst : %b q :%b", tr.d, tr.rst, tr.q), UVM_NONE)
      send.write(tr); //broadcasting transaction
    end
   endtask
   
endclass : monitor
   
/*----SCOREBOARD CLASS----------- */

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)
  
  uvm_analysis_imp #(dff_trns, scoreboard) recv;
  
  function new(input string path = "scoreboard", uvm_component parent = null);
    super.new(path, parent);
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    recv = new("recv", this);
    
  endfunction
  
  virtual function void write(dff_trns tr);
    if(tr.rst ==1)
      `uvm_info("SCOREBOARD", "RESET APPLIED", UVM_NONE)
    
    else if((tr.rst==0) && (tr.q == tr.d))
      `uvm_info("SCOREBOARD","TEST PASSED", UVM_NONE)
    else
        `uvm_info("SCOREBOARD", "TEST FAILED", UVM_NONE)
        
   endfunction
      
      
endclass :scoreboard
      
/*-----AGENT CLASS---- */
     
class agent extends uvm_agent;
  `uvm_component_utils(agent)
  
  driver d;
  monitor m;
  uvm_sequencer#(dff_trns) sqr;
  
  function new(input string path = "agent", uvm_component parent = null);
    super.new(path, parent);
  endfunction 
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    d = driver::type_id::create("d", this);
    sqr = uvm_sequencer #(dff_trns)::type_id::create("sqr", this);
    m = monitor::type_id::create("m", this);
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    d.seq_item_port.connect(sqr.seq_item_export);
    endfunction 
  
  
  
endclass :agent
    
/*------------ENVIRONMENT CLASS----------- */
    
class environment extends uvm_env;
  `uvm_component_utils(environment)
  
  agent a;
  scoreboard scb;
  
  
  function new(input string path = "environment", uvm_component parent = null);
    super.new(path, parent);
    
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    a = agent::type_id::create("agent", this);
    scb = scoreboard::type_id::create("scoreboard", this);
    
  endfunction
  
  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    
    a.m.send.connect(scb.recv);
    
  endfunction
  
endclass : environment
    
/* -------TEST CLASS-------------------*/
   
class test extends uvm_test;
  `uvm_component_utils(test)
  
environment env;
dff_gen gen;
  
  function new(input string path = "test", uvm_component parent = null);
    super.new(path, parent);
  
  endfunction
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    env = environment::type_id::create("env", this);
    gen = dff_gen::type_id::create("gen");
    
  endfunction
  
  virtual task run_phase(uvm_phase phase);
   
      phase.raise_objection(this);
      gen.start(env.a.sqr);
      #5
      phase.drop_objection(this);
    
  endtask
  
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    
    uvm_top.print_topology();
  
  endfunction
  
endclass : test
    
/* -----TESTBENCH---------*/
    
module tb;
  
  dff_intf dfint();
  
  dff dff_inst(.d(dfint.d), .clk(dfint.clk), .rst(dfint.rst), .q(dfint.q));
  
  initial dfint.clk = 1'b0;
  
  always #20 dfint.clk = ~dfint.clk;
  
  property design_prop;
    @(posedge dfint.clk) dfint.d ##[1:$] dfint.q;
  endproperty
  
  dff_assert: assert property(design_prop) $info("Timing checked"); else $error("Timing violation");
  initial begin
    uvm_config_db#(virtual dff_intf)::set(null, "*", "dfint", dfint);
    run_test("test");
  end
  
endmodule
