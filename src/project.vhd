/*
 * Copyright (c) 2024 Your Name
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

  // All output pins must be assigned. If not used, assign to 0.
  assign uo_out  = ui_in + uio_in;  // Example: ou_out is the sum of ui_in and uio_in
  assign uio_out = 0;
  assign uio_oe  = 0;

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, clk, rst_n, 1'b0};

 endmodule

-- -- VHDL Version of top level module
-- library IEEE;
-- use ieee.std_logic_1164.ALL;
-- use IEEE.NUMERIC_STD.ALL;

-- entity tt_um_garnetkoebel_communotron is
--   generic (MAX_COUNT : natural := 10_000_000);
--     port (
--         ui_in   : in  std_logic_vector(7 downto 0);
--         uo_out  : out std_logic_vector(7 downto 0);
--         uio_in  : in  std_logic_vector(7 downto 0);
--         uio_out : out std_logic_vector(7 downto 0);
--         uio_oe  : out std_logic_vector(7 downto 0);
--         ena     : in  std_logic;
--         clk     : in  std_logic;
--         rst_n   : in  std_logic
--     );
-- end tt_um_vhdl_seven_segment_seconds;

-- architecture communotron of tt_um_garnetkoebel_communotron is
--   signal reset    : std_logic;
--   signal led_out  : std_logic_vector(6 downto 0);
--   signal
-- begin

--   reset <= not rst_n;


-- -- 7-Segment Display BCD Decoder Circuit (sevensegdecoder.vhd)
-- -- Designer: Garnet Koebel
-- -- Created: 2020-11-18
-- -- Last Update: 2026-08-23
-- -- Purpose: Seven-Segment Display Decoder (common cathode)

-- -- Update Notes
-- -- 2020-11-23
-- -- Added encoding for digits A-F (forgot initially)

-- LIBRARY ieee;
-- USE ieee.std_logic_1164.ALL;
-- ENTITY sevensegdecoder IS
-- PORT(
-- input : IN BIT_VECTOR(0 to 3);
-- decode: OUT BIT_VECTOR(0 to 6));
-- END sevensegdecoder;
-- ARCHITECTURE decoder OF sevensegdecoder IS
-- BEGIN
-- WITH input SELECT
-- decode <= "0000001" WHEN "0000", -- display 0
-- 			 "1001111" WHEN "0001", -- display 1
-- 			 "0010010" WHEN "0010", -- display 2
-- 			 "0000110" WHEN "0011", -- display 3
-- 			 "1001100" WHEN "0100", -- display 4
-- 			 "0100100" WHEN "0101", -- display 5
-- 			 "0100000" WHEN "0110", -- display 6
-- 			 "0001111" WHEN "0111", -- display 7
-- 			 "0000000" WHEN "1000", -- display 8
-- 			 "0001100" WHEN "1001", -- display 9
-- 			 "0001000" WHEN "1010", -- display A
-- 			 "1100000" WHEN "1011", -- display B
-- 			 "0110001" WHEN "1100", -- display C
-- 			 "1000010" WHEN "1101", -- display D
-- 			 "0110000" WHEN "1110", -- display E
-- 			 "0111000" WHEN "1111", -- display F
-- 			 "1111111" WHEN others; -- display nothing
-- END decoder;
