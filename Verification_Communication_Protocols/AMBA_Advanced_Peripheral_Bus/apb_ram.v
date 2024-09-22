module APB_RAM(PCLK, PREADY, PSEL, PENABLE, PRESETn, PSLVERR, PWRITE, PADDR, PDATA, PRDATA);
  
  input wire PCLK, PSEL, PWRITE, PRESETn, PENABLE;
  input [31:0] PDATA, PADDR;
  
  output reg PSLVERR, PREADY;
  output reg [31:0]PRDATA; 
  
  reg [31:0] mem [32];
  
  enum {IDLE = 0, SETUP = 1, ACCESS = 2, TRANSFER = 3 } state;
  
  always @(posedge PCLK) begin
    if(!PRESETn) begin : reset_signal
      
      state <= IDLE;
      PRDATA <= {$bits(PDATA){1'b0}};
      PREADY <= 1'b0;
      PSLVERR <= 1'b0;
      
      foreach(mem[i]) begin
        mem[i] <= 0;
      end
      
    end : reset_signal
    
    else begin : operating_state
      case(state)
          
          IDLE: begin
            
            PRDATA <= {$bits(PDATA){1'b0}};
            PREADY <= 1'b0;
            PSLVERR <= 1'b0;
            state <= SETUP;
            
          end
          
          SETUP: begin
            
            if(PSEL) 
              state <= ACCESS;
            else
              state <= SETUP;
          
          end
          
          ACCESS: begin
            if(PWRITE && PENABLE) begin : write_data
              
              if(PADDR < 32)
                begin
              
                  mem[PADDR] <= PDATA;
                  state <= TRANSFER;
                  PREADY <= 1'b1;
                  PSLVERR <= 1'b0;
                  
                
                end
              
              else begin
                
                state <= TRANSFER;
                PREADY <= 1'b1;
                PSLVERR <= 1'b1;
                  
              end
              
            end :write_data
            
            else if (!PWRITE && PENABLE) begin : read_data
              if(PADDR < 32) begin
                
                PRDATA <= mem[PADDR];
                state <= TRANSFER;
                PSLVERR <= 1'b0;
                PREADY <= 1'b1;
                
                
              end
              
              else begin
                
                PRDATA <= {$bits(PDATA){1'bx}};
                PREADY <= 1'b1;
                PSLVERR <= 1'b1;
                state <= TRANSFER;
                
              end
              
            end :read_data
            
            else state <= SETUP; //if neither read nor write
          end
          
          TRANSFER: begin
            
            state <= SETUP;
            PREADY <= 1'b0;
            PSLVERR <= 1'b0;
          
          end
          
          default : state <= IDLE;
          
          endcase 
          
        end :operating_state    
          
  end
         
  
endmodule
