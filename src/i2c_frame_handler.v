`timescale 1ns / 100ps

// I2C Frame Handler
// This module tracks the current state of a i2c message and generates signals accordingly. One-shot pulses are generated
// for i2c_start, i2c_stop, and every 9 bits of frame data. As well latched outputs are output to allow external circuitry to
module i2c_frame_handler (
                   input clk, rst, sda_in, scl,
                   output state_start, state_stop, state_address, state_data, start_oneshot, stop_oneshot, frame_end_oneshot
                   );


   // one shots
   reg scl_d, start_d, stop_d, frame_end_d;

   wire start, stop, frame_end;


   always @(posedge clk) begin
      if (!rst) begin
         scl_d <= 1'b1;
         start_d <= 1'b1;
         stop_d <= 1'b1;
      end else begin
         scl_d <= scl;
         start_d <= start;
         stop_d <= stop;
      end
   end

   always @(posedge scl) begin
      if (!rst) begin
         frame_end_d <= 1'b1;
      end else begin
         frame_end_d <= frame_end;
      end
   end

   /* verilator  lint_off UNUSEDSIGNAL */
   wire scl_rising = scl & ~scl_d;
   /* verilator lint_on UNUSEDSIGNAL */
   assign start_oneshot = start & ~start_d;
   assign stop_oneshot = stop & ~stop_d;
   assign frame_end_oneshot = frame_end & ~frame_end_d;

   assign state_start = (state == START);
   assign state_stop = (state == STOP);
   assign state_address = (state == ADDRESS);
   assign state_data = (state == DATA);



   i2c_start_detector start_det(.clk((clk && (state == RESET))), .rst(rst), .sda(sda_in), .scl(scl), .start(start));
   i2c_stop_detector stop_det(.clk((clk && (state == DATA))), .rst(rst), .sda(sda_in), .scl(scl), .stop(stop));
   mod_n_counter frame_det(.clk((scl && ((state == ADDRESS) || (state == DATA)))), .rstn(rst), .out(frame_end));

   // i2c message state FSM
   parameter RESET = 0, // reset state
             START = 1, // start condition occuring (may not use put here in case a future use can use the 1 clock period to do something)
             ADDRESS = 2, // address portion of the message, will use externally to enable match unit
             DATA = 3, // data portion of the frame, will use externally to enable data passthrough
             STOP = 4;  // stop condition occuring (see start state brackets)

   reg [3:0] state, next_state;


   // Sequential FSM Logic
   always @ (posedge clk) begin
      if (!rst) begin
         state <= RESET; // reset if signal pulled low
      end else
        state <= next_state; // update state
   end

   // Combinational FSM Logic
   always @ (*) begin
      if (!rst) begin
         next_state = RESET;
      end

      case (state)
        RESET : begin
           if (start_oneshot) next_state = START;
        end

        START : begin
           next_state = ADDRESS;
        end

        ADDRESS : begin
           if (frame_end_oneshot) next_state = DATA;
        end

        DATA : begin
           if (stop_oneshot) next_state = STOP;
        end

        STOP : begin
           next_state = RESET;
        end

      endcase // case (state)
    end


endmodule // match_unit
