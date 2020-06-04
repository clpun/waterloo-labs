LIBRARY ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
-- The above libaries lines must be included in every VHDL file, before EVERY ENTITY!
--
-- This is the main circuit Entity, which connects all wires to the FPGA board (lights and switches)
-- First we have a PORT mapping - naming all wires going to the outside world and if they are INputs or OUTputs
--
ENTITY Lab1Part1 IS PORT(
-- Note that all signal names here are fixed by the CSV file which you use for every lab
key : IN std_logic_vector(3 downto 0); -- 4 push buttons on the board - nominally HIGH or 1 !!
sw : IN std_logic_vector(5 downto 0); -- use 6 of 18 dip switches on the board - 0 when down towards edge of board
ledr : OUT std_logic_vector(1 downto 0); -- Red LEDs, only 2 used
ledg : OUT std_logic_vector(1 downto 0) -- Green LEDs, only 2 used
);
END Lab1Part1;

ARCHITECTURE SimpleCircuit OF Lab1Part1 IS
-- Create any signals, or temporary variables, to be used
--
-- Signals are either a VECTOR or not. A VECTOR is a group of more than 1 wires
--
-- Note that there are two basic types and we nearly always use std_logic
--
-- UNSIGNED is a signal which can be used to perform math operations such as +, -, *
-- std_logic_vector is a signal which can be used for logic operations such as OR, AND, NOT, XOR
--
signal input_a, input_b: std_logic; -- two signals for inputs
signal red_led0, red_led1: std_logic; -- two signals for Red LED outputs
signal my_4sw_input: std_logic_vector(3 downto 0); -- call a 4 switch vector by another name
-- Now the circuit BEGINs
BEGIN
-- First connect to the outside world, but use better names
my_4sw_input <= sw(3 downto 0); -- connect the lowest 4 switches to a signal called my_4sw_input
input_a <= my_4sw_input(0); -- input_a = sw(0)
input_b <= my_4sw_input(3); -- input_b = sw(3)
ledr(0) <= red_led0; -- set ledr(0) and ledr(1) to signals to show use of signal names
ledr(1) <= red_led1; -- this isn't used right now
-- Here is a simple OR circuit and a more complex AND circuit
ledg(0) <= sw(0) or sw(1);
ledg(1) <= sw(0) and not ( sw(1) ); -- the NOT function inverts a signal
-- Here is a simple electronic switch, or multiplexer
-- It will choose between one of two inputs and display that on red_led0 and red_led1.
-- key(0) will choose if input_a or input_b gets displayed
--
with key(0) select -- key(0) selects one of two things
red_led0 <= input_a when '0', -- 0
input_b when others; -- 1
-- Note that one can select (choose) between signals, constants or equations, or a mix of them
-- Here is a way to choose between 4 options using two switches
-- with sw(5 downto 4) select -- sw(5) and sw(4) selects one of four things
-- red_led1 <= input_a when "00", -- 0, output input_a
-- '0' when "01", -- 1, output constant, always 0
-- input_a and input_b when "10", -- 2, output equation input_a AND input_b
--
-- input_b when others; -- 3, output input_b
END SimpleCircuit;