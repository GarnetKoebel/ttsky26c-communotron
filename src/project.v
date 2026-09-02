/*
 * Copyright (c) 2026 Garnet Koebel
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_garnetkoebel_communotron (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

   // INPUTS
   // incoming i2c data line
   wire sda_in;
   assign sda_in = ui_in[0];

   // i2c clock line
   wire scl;
   assign scl = ui_in[1];

   // spi peripheral in controller out (only used if I get bi-directional comms working)
   wire spi_pico;
   assign spi_pico = ui_in[2];

   // OUTPUTS
   // outgoing i2c data line (for acking without messing with bi-directional pins)
   wire sda_out;
   assign sda_out = uo_out[0];

   // spi chip select 1
   wire spi_cs_1;
   assign spi_cs_1 = uo_out[1];

   // spi chip select 2
   wire spi_cs_2;
   assign spi_cs_2 = uo_out[2];

   // spi chip select 3
   wire spi_cs_3;
   assign spi_cs_3 = uo_out[3];

   // spi chip select 4
   wire spi_cs_4;
   assign spi_cs_4 = uo_out[4];

   // spi peripheral out controller in (translated i2c data comes out here)
   wire spi_poci;
   assign spi_poci = uo_out[5];


  // All output pins must be assigned. If not used, assign to 0.

  

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

  // communotron_fsm primary_fsm(clk, rst_n,);

   parameter address1 = 8'h42;


   address_1_detector i2C_address_detector(.clk(clk), .rst(rst_n), .sda(sda), .scl(scl), .inhibit(0), .address(address1) , .address_match(match1));




endmodule


module communotron_fsm (
                        input
                        clk,
                        rst,
                        start_detect,
                        stop_detect



                        );
endmodule // communotrom_fsm

// Detects the I2C Start Sequence
module i2c_start_detector (
  input
                           clk, // communotron clock signal
                           rst, // communotron reset signal
                           sda, // i2c data signal
                           scl,  // i2c clock signal

                           output start
                           );

   parameter RESET          = 0, // reset state
             SDA_LOW_FIRST  = 1, // sda pulling low is the first step of a i2c start
             SCL_LOW_SECOND = 2; // scl pulling low after sda is the confirmation that this is a i2c start

   reg [2:0] state, next_state;

   assign start = (state == SCL_LOW_SECOND) ? 1 : 0; // set match high if state indicates a i2c start just occured

   // Sequential Logic
   always @ (posedge clk) begin
      if (!rst) begin
         state <= RESET; // reset if signal pulled low
      end else
        state <= next_state; // update state
   end

   // Combinational Logic
   always @ (state or sda or scl) begin // update each time state, sda, or scl changes
      case (state)
        RESET : begin
           if (!sda) next_state = SDA_LOW_FIRST;
           else next_state = RESET;
        end

        SDA_LOW_FIRST : begin
           if (!scl) next_state = SCL_LOW_SECOND;
           else next_state = RESET;
        end

        SCL_LOW_SECOND : begin
           next_state = RESET;
        end
      endcase // case (state)
   end


endmodule // i2c_start_detector

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
             SDA_HIGH_FIRST  = 1, // sda going high is the first step of a i2c stop
             SCL_HIGH_SECOND = 2; // scl going high after sda is the confirmation that this is a i2c stop

   reg [2:0] state, next_state;

   assign stop = (state == SCL_HIGH_SECOND) ? 1 : 0; // set match high if state indicates a i2c start just occured

   // Sequential Logic
   always @ (posedge clk) begin
      if (!rst) begin
         state <= RESET; // reset if signal pulled low
      end else
        state <= next_state; // update state
   end

   // Combinational Logic
   always @ (state or sda or scl) begin // update each time state, sda, or scl changes
      case (state)
        RESET : begin
           if (sda) next_state = SDA_HIGH_FIRST;
           else next_state = RESET;
        end

        SDA_HIGH_FIRST : begin
           if (scl) next_state = SCL_HIGH_SECOND;
           else next_state = RESET;
        end

        SCL_HIGH_SECOND : begin
           next_state = RESET;
        end
      endcase // case (state)
   end

endmodule // i2c_stop_detector

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

   // Combinational FSM Logic
   always @ (state or scl) begin
      if (!inhibit) begin // allow disabling address matching (used to prevent matching on data portion of frames)
         case (state)
           RESET : begin
              if (sda == address[0]) next_state = B0_MATCH;
              else next_state = RESET;
           end

           B0_MATCH : begin
              if (sda == address[1]) next_state = B1_MATCH;
              else next_state = RESET;
           end

           B1_MATCH : begin
              if (sda == address[2]) next_state = B2_MATCH;
              else next_state = RESET;
           end

           B2_MATCH : begin
              if (sda == address[3]) next_state = B3_MATCH;
              else next_state = RESET;
           end

           B3_MATCH : begin
              if (sda == address[4]) next_state = B4_MATCH;
              else next_state = RESET;
           end

           B4_MATCH : begin
              if (sda == address[5]) next_state = B5_MATCH;
              else next_state = RESET;
           end

           B5_MATCH : begin
              if (sda == address[6]) next_state = B6_MATCH;
              else next_state = RESET;
           end

           B6_MATCH : begin
              if (rst) next_state = RESET; // hold match signal until told to reset
           end

         endcase // case (state)
      end // if (!inhibit)
   end // always @ (state or scl)



endmodule // i2c_address_detector
