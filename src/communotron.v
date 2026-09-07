// Communotron Main Module, it is assumed that signals above this level get passed to external pins
module communotron (
                   input clk, rst, sda_in, scl,
                   output sda_out, spi_pico, spi_clk, match_1, match_2, match_3, match_4
                   );

   // This iteration of the communotron uses hard-wired addresses
   parameter match_address_1 = 7'h41;
   parameter match_address_2 = 7'h42;
   parameter match_address_3 = 7'h43;
   parameter match_address_4 = 7'h44;

   wire      match_unit_inhibit;
   wire      match_oneshot, start_oneshot, stop_oneshot, frame_end_oneshot;
   wire      state_start, state_stop, state_address, state_data;

  


   // module responsible for tracking where in the i2c message we are
   i2c_frame_handler frame_handler(.clk(clk), .rst(rst), .sda_in(sda_in), .scl(scl), .state_start(state_start), .state_stop(state_stop),
                                   .state_address(state_address), .state_data(state_data), .start_oneshot(start_oneshot),
                                   .stop_oneshot(stop_oneshot), .frame_end_oneshot(frame_end_oneshot));

   // module responsible for detecting addresses in the SDA bitstream
   match_unit det_match(.clk(clk), .rst(rst), .sda(sda_in), .scl(scl), .inhibit(match_unit_inhibit),
                        .address_1(match_address_1), .address_2(match_address_2),
                        .address_3(match_address_3), .address_4(match_address_4),
                        .match_1(match_1), .match_2(match_2), .match_3(match_3), .match_4(match_4),
                        .match_shot(match_oneshot));

   assign match_unit_inhibit = !state_address; // match unit should only be matching when in address part of frame
   assign sda_out = !frame_end_oneshot; // this is our ACK signal

   assign spi_pico = sda_in; // we can always have the spi side match the i2c side since the clock will be stalled during acks
   assign spi_clk = (scl && !frame_end_oneshot); // stall the clock passthrough during ACK bits.

endmodule // communotron
