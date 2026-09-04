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
   assign uo_out[0] = sda_out;

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
   assign uo_out[7] = 0;
   assign uio_out = 0;
   assign uio_oe = 0;

   wire _unused =&(ena);

  

  // communotron_fsm primary_fsm(clk, rst_n,);

/* -----\/----- EXCLUDED -----\/-----
   parameter address1 = 8'h41;
   parameter address2 = 8'h42;
   parameter address3 = 8'h43;
   parameter address4 = 8'h44;
 -----/\----- EXCLUDED -----/\----- */


   i2c_start_detector det_start(.clk(clk), .rst(rst_n), .sda(sda_in), .scl(scl), .start(sda_out));





endmodule


/* -----\/----- EXCLUDED -----\/-----
module communotron_fsm (
                        input
                        clk,
                        rst,
                        start_detect,
                        stop_detect



                        );
endmodule // communotrom_fsm
 -----/\----- EXCLUDED -----/\----- */

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

/* -----\/----- EXCLUDED -----\/-----
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
                             input  clk, rst, sda, scl, inhibit, [6:0] address,
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

// contains the i2c_address_detectors and cross-connected inhibit circuitry
module data_routing_unit (
                          input  clk, rst, sda_in, scl, spi_pico, [6:0] address_1, [6:0] address_2, [6:0] address_3, [6:0] address_4,
                          output sda_out, spi_cs_1, spi_cs_2, spi_cs_3, spi_cs_4, spi_poci, spi_clk

                          );

   // This module contains the bulk of the communotron data handling.

    // i2c data bit counter
   wire i2c_data_bit_counter_rollover;
   mod_n_counter #(N = 9, WIDTH = 5) i2c_data_bit_counter(.clk(scl), .rst_n(rst), .out(i2c_data_bit_counter_rollover));

   // i2c address match one-shot logic


   // one-shot ack logic for driving sda_out
   wire i2c_ack;
   assign i2c_ack = (i2c_data_bit_counter_rollover | i2c_address_match_oneshot);


   // Address Detector Inhibit Logic. These signals are used to disable all but one address detector once
   // a match has occured
   wire inhibit_1, inhibit_2, inhibit_3, inhibit_4;
   assign inhibit_1 = (spi_cs_2 | spi_cs_3 | spi_cs_4);
   assign inhibit_2 = (spi_cs_1 | spi_cs_3 | spi_cs_4);
   assign inhibit_3 = (spi_cs_1 | spi_cs_2 | spi_cs_4);
   assign inhibit_4 = (spi_cs_1 | spi_cs_2 | spi_cs_3);

   // Address detectors. Pre-programmed to detect a specific address defined in the top level module
   // The detectors generate our spi chipselect signal
   i2c_address_detector address_1_detector(.clk(clk), .rst(rst), .sda(sda_in), .scl(scl), .inhibit(inhibit_1), .address(address_1) , .address_match(spi_cs_1));
   i2C_address_detector address_2_detector(.clk(clk), .rst(rst), .sda(sda_in), .scl(scl), .inhibit(inhibit_2), .address(address_2) , .address_match(spi_cs_2));
   i2C_address_detector address_3_detector(.clk(clk), .rst(rst), .sda(sda_in), .scl(scl), .inhibit(inhibit_3), .address(address_3) , .address_match(spi_cs_3));
   i2C_address_detector address_4_detector(.clk(clk), .rst(rst), .sda(sda_in), .scl(scl), .inhibit(inhibit_4), .address(address_4) , .address_match(spi_cs_4));

   // i2c data bit counter, used to trigger ACKs and to stall spi clk in order to strip ACK bits.


   // data output logic
   wire spi_clk_en, spi_pico_en;
   //assign spi_pico_en;


endmodule // data_routing_unit

module mod_n_counter
  # (parameter N = 10,
     parameter WIDTH = 4)

  ( input   clk,
    input   rst_n,
   	output  reg[WIDTH-1:0] out);

  always @ (posedge clk) begin
    if (!rst_n) begin
      out <= 0;
    end else begin
      if (out == N-1)
        out <= 0;
      else
        out <= out + 1;
    end
  end
endmodule // mod_n_counter

// one-shot
module one_shot (
                 input  clk, in,
                 output out
                 );

   always @ (posedge clk) begin
      if (in) begin
         out = 1;


endmodule // one_shot
 -----/\----- EXCLUDED -----/\----- */
