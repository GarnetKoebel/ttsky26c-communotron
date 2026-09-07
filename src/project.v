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
   wire spi_poci;
   assign spi_poci = ui_in[2];

   // OUTPUTS
   // outgoing i2c data line (for acking without messing with bi-directional pins)
   wire sda_out;
   assign uo_out[0] = sda_out;

   // spi chip select 1
   wire spi_cs_1;
   assign uo_out[1] = spi_cs_1;

   // spi chip select 2
   wire spi_cs_2;
   assign uo_out[2] = spi_cs_2;

   // spi chip select 3
   wire spi_cs_3;
   assign uo_out[3] = spi_cs_3;

   // spi chip select 4
   wire spi_cs_4;
   assign uo_out[4] = spi_cs_4;

   // spi peripheral out controller in (translated i2c data comes out here)
   wire spi_pico;
   assign uo_out[5] = spi_pico;

   wire spi_clk;
   assign uo_out[6] = spi_clk;


  // All output pins must be assigned. If not used, assign to 0.
   assign uo_out[7:1] = 0;
   assign uio_out = 0;
   assign uio_oe = 0;

   wire _unused =&(ena);

   communotron com1(.clk(clk), .rst(rst_n), .sda_in(sda_in), .scl(scl), .sda_out(sda_out),
                     .match_1(spi_cs_1), .match_2(spi_cs_2), .match_3(spi_cs_3), .match_4(spi_cs_4),
                     .spi_pico(spi_pico), .spi_clk(spi_clk));



endmodule
