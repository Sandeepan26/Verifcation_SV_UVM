`include "spi_slave.v"
`timescale 1ns/1ps
/*---------------SPI MASTER/CONTROLLER------------------------------ */
module spi_master(input clk, rst, wr, [7:0] din, [7:0]addr, wire miso, ready, op_done, output reg mosi,cs,done, err, wire [7:0] dout);
  
  reg[16:0] d_reg;
  reg [7:0] do_reg;
  
  int count = 0;
  
  enum bit[2:0] {idle = 0, load = 1, check_op, send_data, read_data1, read_data2, error, check_rdy} state;
  
  always @(posedge clk) begin
    if(rst)      //active high
      begin
        state <= idle;
        mosi <= 1'b0;
        cs <= 1'b1;
        count <= 0;
        err <= 1'b0;
        done <= 1'b0;
      end //rst 
    else begin
      case(state)
        idle: 
          begin
          	mosi <= 1'b0;
          	cs <= 1'b1;
          	err <= 1'b0;
          	done <= 1'b0;
          	state <= load;
        end
        load:
          begin
            d_reg <= {din, addr, wr}; //wr in LSB, data in MSB
            state <= check_op;
          end
        check_op:
          begin
            if(wr && (addr<32))
              begin : write_data
              cs <= 1'b0; //chip select is active low
              state <= send_data;
              end : write_data
            else if(!wr && (addr<32))
              begin : reading_data
                cs <= 1'b0;
                state <= read_data1;
              end : reading_data
            else begin
              state<= error;
              cs <= 1'b1;
            end
          end //check_op
        send_data:
          begin
            if(count <= 16)
              begin
                count <= count + 1;
                mosi <= d_reg[count];
                state <= send_data;
              end
            else begin
              cs <= 1'b1;
              mosi <= 1'b0;
              if(op_done) begin
                count <= 0;
                done <= 1'b1;
                state <= idle;
              end
              else 
                state <= send_data;
            end //else block
          end //send_data
        read_data1:
          begin
            if(count<=8)
              begin
                count <= count + 1;
                mosi <= d_reg[count];
                state <= read_data1;
              end
            else begin
              count <= 0;
              cs <= 1'b1;
              state <= check_rdy;
            end
          end //read_data1
        check_rdy:
          state <= ready? read_data2 : check_rdy;
        read_data2:
          begin
            if(count <= 7) begin
              count <= count + 1;
              do_reg[count] <= miso;
              state <= read_data2;
            end
            else begin
              count <= 0;
              done <= 1'b1;
              state <= idle;
            end
          end //read_data2
        error:
          begin
            err <= 1'b1;
            state <= idle;
            done <= 1'b1;
          end
        default:
          begin
            state <= idle;
            count <= 0;
          end
      endcase //case block
   end //else block
 end //always block 
endmodule


