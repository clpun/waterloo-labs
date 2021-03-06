LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
--
-- 7segment driver hex: convert a 4-bit number to a displayed value of 0, 1, 2 ... F
--   This is created as an ENTITY so that it can be reused many times easily
--
ENTITY SevenSegment IS PORT(
		dataIn : IN STD_LOGIC_VECTOR(3 DOWNTO 0);		-- The 4 bit data to be displayed
		blanking: IN STD_LOGIC;							-- Blank the output if this is 1
		segmentsOut : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) );	-- 7 bits out to a 7-segment display
END SevenSegment;

architecture Behavioral of SevenSegment IS
BEGIN
-- 
-- On a 7-segment display the 7 leds are named A, B, C, D, E, F, G and the pattern is given in the Lab Manual Appendix
--
-- In VHDL you will nearly always deal with VECTORs - a bundle of wires.  The naming convention MyWire(3 DOWNTO 0) is another
--  way to say that there are 4 wires MyWire(3), MyWire(2), MyWire(1), MyWire(0)
--
-- The following SELECT statement converts a 4 bit number, called dataIn to a pattern of 7 bits, or wires, 
--   to connect to a 7-segment display called segmentsOut
--
-- The blanking input (one wire) is added to the 4 data wires to build the circuit with a single SELECT statement
--
	with blanking & dataIn SELECT		-- 7-segment bits are A to G but the LSB is A
		segmentsOut(6 DOWNTO 0) <=	"1000000" WHEN "00000",		-- 0
									"1111001" WHEN "00001",		-- 1
									"0100100" WHEN "00010", 	-- 2
									"0110000" WHEN "00011", 	-- 3
									"0011001" WHEN "00100",		-- 4
									"0010010" WHEN "00101", 	-- 5
									"0000010" WHEN "00110", 	-- 6
									"1111000" WHEN "00111",		-- 7
									"0000000" WHEN "01000", 	-- 8
									"0010000" WHEN "01001",		-- 9
									"0001000" WHEN "01010",		-- A
									"0000011" WHEN "01011",		-- b
									"0100111" WHEN "01100",		-- c
									"0100001" WHEN "01101",		-- d
									"0000110" WHEN "01110",		-- E
									"0001110" WHEN "01111",		-- F
									"1111111" WHEN OTHERS;		-- Blanking and for simulation
--
-- NOTE: WHEN OTHERS must always be used!
END Behavioral;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Lab4_PartA IS
	PORT(
		key			: IN	STD_LOGIC_VECTOR(3 DOWNTO 0);	-- 4 push buttons on the board
		sw			: IN	STD_LOGIC_VECTOR(17 DOWNTO 0);		-- 18 dip switches on the board
		clock_50	: IN	STD_LOGIC;

		ledr		: OUT	STD_LOGIC_VECTOR(17 DOWNTO 0);	-- LEDs, many Red ones are available
		ledg		: OUT	STD_LOGIC_VECTOR(8 DOWNTO 0);	-- LEDs, many Green ones are available
		hex0, hex4	: OUT	STD_LOGIC_VECTOR(6 DOWNTO 0)	-- seven segments to display numbers
		);
END Lab4_PartA;

ARCHITECTURE traffic_lights OF Lab4_PartA IS

	COMPONENT SevenSegment PORT(			-- Declare the 7 segment component to be used
		dataIn : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		blanking: IN STD_LOGIC;
		segmentsOut : OUT STD_LOGIC_VECTOR(6 DOWNTO 0) );
	END COMPONENT;

	CONSTANT Clk_Div_Size: INTEGER := 26;		-- size of vectors for the counters

	-- Now declare all signals for counters, etc and initialize them to 0 for simulation
	SIGNAL ModCount, TerminalCount:	UNSIGNED(Clk_Div_Size - 1 DOWNTO 0) := to_unsigned(0,Clk_Div_Size);		-- counter and terminal value for modulus clock

	SIGNAL ModCount1HZ: UNSIGNED(3 DOWNTO 0) := to_unsigned(0,4);	-- counter value for 1Hz modulus clock

	SIGNAL OneHzMod:	STD_LOGIC;			-- 1 Hz clock
	
	SIGNAL TenHzMod:	STD_lOGIC;			-- 10 Hz clock
	
	SIGNAL Counter:		UNSIGNED(3 DOWNTO 0);-- Counter for state transitions
	
	SIGNAL StateNumber:	STD_LOGIC_VECTOR(3 DOWNTO 0);	-- show what state we're in, as a 4-bit number
	
	TYPE states IS (Green1_Red2, Amber_Red2, Red1_Green2, Red1_Amber);      -- list all the states
	SIGNAL state:                  states;        -- Current state
	SIGNAL next_state:             states;        -- Calculated next state based upon current state and inputs

BEGIN

-- Modulus counter clock for 10Hz

ModClock10Hz: PROCESS(clock_50)
BEGIN
	IF (rising_edge(clock_50)) THEN
		IF (ModCount = "00001001100010010110100000") THEN
			ModCount <= to_unsigned(0,Clk_Div_Size);
			TenHzMod <= NOT (TenHzMod);
		ELSE
			ModCount <= ModCount + 1;
		END IF;
	END IF;
END PROCESS;

-- Modulus counter clock for 1Hz

ModClock1Hz: PROCESS(TenHzMod)
BEGIN
	IF (rising_edge(TenHzMod)) THEN
		IF (ModCount1Hz = "0101") THEN
			ModCount1Hz <= "0000";
			OneHzMod <= NOT (OneHzMod);
		ELSE
			ModCount1Hz <= ModCount1Hz + 1;
		END IF;
	END IF;
END PROCESS;
-- Counter for state transitions.
Count: PROCESS(OneHzMod)
BEGIN
		IF (rising_edge(OneHzMod)) THEN
			If (Counter = "1001") THEN
				Counter <= "0000";
				state <= next_state;
			ELSE
				Counter <= Counter + 1;
				state <= next_state;
			END IF;
		END IF;
END PROCESS;

CalcState: PROCESS(state, Counter)		-- State machine to determine the state
BEGIN
	CASE state IS
		WHEN Green1_Red2 =>
		StateNumber <= "0000";
			ledr(11 DOWNTO 0) <= "000000000001";		-- ledr(0) <= '1';
			ledg(8 DOWNTO 0) <= "100000000";		-- ledg(8) <= '1';
			
			IF (Counter = "1001") THEN
				next_state <= Amber_Red2;		-- Next state would be Amber_Red2 if the current count value is 9.
			ELSE
				next_state <= Green1_Red2;		-- Stay at the present state if the current count value is not 9.
			END IF;
			
		WHEN Amber_Red2 =>
		StateNumber <= "0001";
			ledg(8 DOWNTO 0) <= "000000000";			-- Turns off ledg(0)
			ledr(11 DOWNTO 0) <= "000000000001";		-- ledr(0) <= '1';
			IF (TenHzMod = '1') THEN					-- ledr(11) starts blinking;
				ledr(11 DOWNTO 0) <= "100000000001";
			ELSE
				ledr(11 DOWNTO 0) <= "000000000001";
			END IF;
			
			IF (Counter = "0000") THEN
				next_state <= Red1_Green2;		-- Next state would be Red1_Green2 if the current count value is 0.
			ELSE
				next_state <= Amber_Red2;		-- Stay at the present state if the current count value is not 0.
			END IF;
		
		WHEN Red1_Green2 =>
		StateNumber <= "0010";
			ledr(11 DOWNTO 0) <= "100000000000";	-- ledr(11) <= '1'
			ledg(8 DOWNTO 0) <= "010000000";	-- ledg(7) <= '1'
			
			IF (Counter = "1001") THEN
				next_state <= Red1_Amber;		-- Next state would be Red1_Amber if the current count value is 9.
			ELSE
				next_state <= Red1_Green2;		-- Stay at the present state if the current count value is not 9.
			END IF;
		
		WHEN Red1_Amber =>
		StateNumber <= "0011";
			ledg(8 DOWNTO 0) <= "000000000";			-- Turns off ledg(7)
			ledr(11 DOWNTO 0) <= "100000000000";		-- ledr(11) <= '1'
			IF (TenHzMod = '1') THEN					-- ledr(0) starts blinking
				ledr(11 DOWNTO 0) <= "100000000001";
			ELSE
				ledr(11 DOWNTO 0) <= "100000000000";
			END IF;
			
			IF (Counter = "0000") THEN
				next_state <= Green1_Red2;		-- Next state would be Green1_Red2 if the current count value is 0.
			ELSE
				next_state <= Red1_Amber;		-- Stay at the present state if the current count value is not 0.
			END IF;
			
		WHEN OTHERS =>
		StateNumber <= "0100";
			state <= Green1_Red2;
			
		END CASE;
END PROCESS;

ShowState: SevenSegment PORT MAP( StateNumber, '0', hex0 );	-- Displays the current state number on hex0.

ShowCount: SevenSegment PORT MAP( std_logic_vector(Counter), '0', hex4 );	-- Displays the count value on hex4.

END traffic_lights;