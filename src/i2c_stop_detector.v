// Detects the I2C Stop Sequence
module i2c_stop_detector (
                          input
                                 clk, // communotron clock signal
                                 rst, // communotron reset signal
                                 sda, // i2c data signal
                                 scl, // i2c clock signal

                          output stop
                           );

   parameter RESET           = 0, // reset state
             SCL_HIGH_FIRST  = 1, // sda going high is the first step of a i2c stop
             SDA_HIGH_SECOND = 2; // scl going high after sda is the confirmation that this is a i2c stop

   reg [2:0] state, next_state;

   assign stop = (state == SDA_HIGH_SECOND) ? 1 : 0; // set match high if state indicates a i2c start just occured


   // Sequential Logic
   always @ (posedge clk) begin
      if (!rst) begin
         state <= RESET; // reset if signal pulled low
      end else
        state <= next_state; // update state
   end

   // Combinational Logic
   always @ (*) begin // update each time state, sda, or scl changes
      if (!rst) begin
         next_state = RESET;
      end

         case (state)
           RESET : begin
              if (scl && !sda) next_state = SCL_HIGH_FIRST;
              else next_state = RESET;
           end

           SCL_HIGH_FIRST : begin
              if (sda && scl) next_state = SDA_HIGH_SECOND;
              else next_state = RESET;
           end

           SDA_HIGH_SECOND : begin
              next_state = RESET;
           end
         endcase // case (state)

   end

endmodule // i2c_stop_detector
