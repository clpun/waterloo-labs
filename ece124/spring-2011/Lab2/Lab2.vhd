--
-- This circuit demonstrates a few VHDL tricks.

-- SW15 .. SW17 are connected to LEDR15 .. LED17 and HEX7
-- SW0 .. SW2 are connected to LEDR0 .. LED2 and HEX5
-- KEY0 choosed between AND and OR of those two inputs and displays the results on LEDR10 .. LEDR12 and HEX0

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
--
-- 7segment driver hex: convert a 4-bit number to a displayed value of 0, 1, 2 ... F
--   This is created as an entity so that it can be reused many times easily
--
entity SevenSegment is port(
		dataIn : in std_logic_vector(3 downto 0);		-- The 4 bit data to be displayed
		blanking: in std_logic;							-- Blank the output if this is 1
		segmentsOut : out std_logic_vector(6 downto 0) );	-- 7 bits out to a 7-segment display
end SevenSegment;

architecture Behavioral of SevenSegment is
begin
-- 
-- On a 7-segment display the 7 leds are named A, B, C, D, E, F, G and the pattern is given in the Lab Manual Appendix
--
-- In VHDL you will nearly always deal with VECTORs - a bundle of wires.  The naming convention MyWire(3 downto 0) is another
--  way to say that there are 4 wires MyWire(3), MyWire(2), MyWire(1), MyWire(0)
--
-- The following select statement converts a 4 bit number, called dataIn to a pattern of 7 bits, or wires, 
--   to connect to a 7-segment display called segmentsOut
--
-- The blanking input (one wire) is added to the 4 data wires to build the circuit with a single select statement
--
	with blanking & dataIn select		-- 7-segment bits are A to G but the LSB is A
		segmentsOut(6 downto 0) <=	"1000000" when "00000",		-- 0
									"1111001" when "00001",		-- 1
									"0100100" when "00010", 	-- 2
									"0110000" when "00011", 	-- 3
									"0011001" when "00100",		-- 4
									"0010010" when "00101", 	-- 5
									"0000010" when "00110", 	-- 6
									"1111000" when "00111",		-- 7
									"0000000" when "01000", 	-- 8
									"0010000" when "01001",		-- 9
									"0001000" when "01010",		-- A
									"0000011" when "01011",		-- b
									"0100111" when "01100",		-- c
									"0100001" when "01101",		-- d
									"0000110" when "01110",		-- E
									"0001110" when "01111",		-- F
									"1111111" when OTHERS;		-- blank and for simulation
--
-- NOTE: when OTHERS must always be used!
end Behavioral;

library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity Lab2 is
	PORT(
		-- Declare the input and output signals we will be using.
		sw			: in	std_logic_vector(17 downto 0); 
		ledr		: out	std_logic_vector(8 downto 0);
		hex0, hex1, hex2, hex4, hex5, hex6, hex7	: out	std_logic_vector(6 downto 0)	
		);
end Lab2;

ARCHITECTURE SimpleCircuit OF Lab2 is

	component SevenSegment port(
		dataIn : in std_logic_vector(3 downto 0);
		blanking: in std_logic;
		segmentsOut : out std_logic_vector(6 downto 0));
	end component;

signal myInput: std_logic_vector(7 downto 0); -- Internal signal for signal A.
signal myOtherInput: std_logic_vector(7 downto 0); -- Internal signal for signal B.
signal  combine  :  std_logic_vector(1 downto 0); -- Internal signal for combination of sw(17) and sw(16).
signal result: std_logic_vector(8 downto 0); -- Result storage internal signal.

begin
	myInput <= sw(7 downto 0); -- Takes signals for sw(7 downto 0).
	myOtherInput <= sw(15 downto 8); -- Takes signals for sw(15 downto 8).
	
	ShowNumber1: SevenSegment port map( myOtherInput(7 downto 4), '0', hex7 ); -- Connect myOtherInput(7 downto 4) to hex7.
	ShowNumber2: SevenSegment port map( myOtherInput(3 downto 0), '0', hex6 ); -- Connect myOtherInput(3 downto 0) to hex6.

	ShowSignal1: SevenSegment port map( myInput(7 downto 4), '0', hex5 ); -- Connect myInput(7 downto 4) to hex5.
	ShowSignal2: SevenSegment port map( myInput(3 downto 0), '0', hex4 ); -- Connect myInput(3 downto 0) to hex4.
	
	combine <= sw(17 downto 16); -- Combine signals sw17 and sw16.
	
	with combine select
		result <= std_logic_vector(unsigned ('0'&(sw(7 downto 0)))+unsigned ('0'&(sw(15 downto 8)))) when "00", -- ADD operation.
					'0'&(sw(7 downto 0) AND sw(15 downto 8)) when "01", -- AND operation.
					'0'&(sw(7 downto 0) XOR sw(15 downto 8)) when "10", -- XOR operation.
					'0'&(sw(7 downto 0) OR sw(15 downto 8)) when others; -- OR operation.
	
	ShowOneOf1: SevenSegment port map( result(3 downto 0), '0', hex0 ); -- Connect result(3 downto 0) to hex0.
	ShowOneOf2: SevenSegment port map( result(7 downto 4), '0', hex1 ); -- Connect result(7 downto 4) to hex1.
	ShowOneOf3: SevenSegment port map( "000" & result(8), '0', hex2 ); -- Connect result(8) to hex2.
	
	ledr(8 downto 0) <= result(8 downto 0); -- Connect leds to result signals.

end SimpleCircuit;
