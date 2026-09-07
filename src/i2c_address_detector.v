// Detects a pre-programmed address
module i2c_address_detector (
input clk, rst, sda, scl, inhibit, [6:0] address,
output address_match
                             );

   // address bit matching states
   parameter RESET    = 0,
             B0_MATCH = 1,
             B1_MATCH = 2,
             B2_MATCH = 3,
             B3_MATCH = 4,
             B4_MATCH = 5,
             B5_MATCH = 6,
             B6_MATCH = 7;

   reg [3:0] state, next_state; // current and next state register

   assign address_match = (state == B6_MATCH) ? 1 : 0; // output match if all 7 bits match

   // Sequential FSM Logic
   always @ (posedge clk) begin
      if (!rst) begin
         state <= RESET; // reset if signal pulled low
      end else
        state <= next_state; // update state
   end

   reg scl_d;

   always @(posedge clk) begin
      if (!rst) begin
         scl_d <= 1'b1;
      end else begin
         scl_d <= scl;
      end
   end

wire scl_rising = scl & ~scl_d;

   // Combinational FSM Logic
   always @ (*) begin
      if (!rst)  begin
         next_state = RESET;
      end


      if (!inhibit && scl_rising) begin // allow disabling address matching (used to prevent matching on data portion of frames)
         case (state)
           RESET : begin
              if (sda == address[0]) next_state = B0_MATCH;
              //else next_state = RESET;
           end

           B0_MATCH : begin
              if (sda == address[1]) next_state = B1_MATCH;
              //else next_state = RESET;
           end

           B1_MATCH : begin
              if (sda == address[2]) next_state = B2_MATCH;
              //else next_state = RESET;
           end

           B2_MATCH : begin
              if (sda == address[3]) next_state = B3_MATCH;
              //else next_state = RESET;
           end

           B3_MATCH : begin
              if (sda == address[4]) next_state = B4_MATCH;
              //else next_state = RESET;
           end

           B4_MATCH : begin
              if (sda == address[5]) next_state = B5_MATCH;
              //else next_state = RESET;
           end

           B5_MATCH : begin
              if (sda == address[6]) next_state = B6_MATCH;
              //else next_state = RESET;
           end

           B6_MATCH : begin
              if (!rst) next_state = RESET; // hold match signal until told to reset
           end

         endcase // case (state)
      end // if (!inhibit)
   end // always @ (state or scl)



endmodule // i2c_address_detector
