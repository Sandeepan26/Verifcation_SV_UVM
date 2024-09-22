module spi_slave(clk, rst, cs, mosi, miso, ready, op_done);
  input clk, rst, cs, mosi;
  output reg ready, miso, op_done;
  
  reg [7:0] memory [31:0] ='{default : 1'b0}; //32 addresses each with 8 bits
  int count = 0;
  reg [15:0] din;
  reg[7:0] dout;
  
  enum bit[2:0]{idle = 0, detect = 1, store = 2, send_addr = 3, send_data = 4}state; //FSM for operation
  
  always@(posedge clk)
    begin
      if(rst) begin
        state <= idle;
        miso <= 1'b0;
        ready <= 1'b0;
        count <= 1'b0;
        op_done <= 1'b0;
      end
      else begin
        case(state)
          idle:
            begin
              miso <= 1'b0;
              count <= 0;
              ready<= 1'b0;
              state <= cs ? detect : idle;
              op_done <= 1'b0;
            end
          detect:
            state <= miso ? store : send_addr;
          
          store:
            begin
              if(count < 16)begin
                din[count] <= mosi;
                count <= count + 1;
                state <= store;
              end
              else begin
                memory[din[7:0]]  <= din[15:8];
                count <= 0;
                state <= idle;
                op_done <= 1'b1;
              end
            end
          send_addr:
            begin
              if(count <8)
                begin
                  count <= count + 1;
                  din[count] <= mosi;
                  state <= send_addr;
                end
              else begin
                state <= send_data;
                ready <= 1'b1;
                dout <= memory[din];
              end
            end
          send_data :begin
            ready <= 1'b0;
            if(count < 8) begin
              count <= count + 1;
              miso <= memory[din];
              state <= send_data;
            end
            else begin
              count <= 0;
              state <= idle;
              op_done <= 1'b1;
            end
          end
            default: state <= idle;
        endcase
      end
    end
endmodule
