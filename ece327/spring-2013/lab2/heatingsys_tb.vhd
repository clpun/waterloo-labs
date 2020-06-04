------------------------------------------------------------------------
-- heating system testbench
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity heatingsys_tb is
end entity;

architecture main of heatingsys_tb is
	signal i_cur_temp       : signed(7 downto 0); -- current temp
	signal i_des_temp       : signed(7 downto 0); -- desired temp
	signal i_reset          : std_logic;          -- reset
	signal i_clock          : std_logic;          -- clock
	signal o_heatmode       : std_logic_vector(1 downto 0);          -- mode
begin
uut : entity work.heatingsys(main)
  port map (
    i_cur_temp => i_cur_temp,
    i_des_temp => i_des_temp,
    i_reset => i_reset,
	i_clock => i_clock,
	o_heatmode => o_heatmode
     );

process
begin
i_clock <= '1';
wait for 5 ns;
i_clock <= '0';
wait for 5 ns;
end process;

  process
  begin
    -- --------------------round 1
    i_reset<='1';  -- off
    wait for 10 ns;
    -- --------------------
    i_reset<='0'; i_cur_temp <= to_signed(30,8); i_des_temp <= to_signed(33,8); --low
    wait for 10 ns;
    -- --------------------

    i_reset <='1'; --off
    wait for 10 ns;
    -- -------------------- round 2
    i_reset<='0'; i_cur_temp <= to_signed(30,8); i_des_temp <= to_signed(33,8); --low
    wait for 10 ns;
    -- --------------------

    i_reset<='0'; i_cur_temp <= to_signed(33,8); i_des_temp <= to_signed(30,8); --off
    wait for 10 ns;

    --round 3

    i_reset<='0'; i_cur_temp <= to_signed(30,8); i_des_temp <= to_signed(34,8); --low
    wait for 10 ns;

    i_reset<='0'; i_cur_temp <= to_signed(30,8); i_des_temp <= to_signed(37,8); --high
    wait for 10 ns;
	-- --------------------
    i_reset<='0'; i_cur_temp <= to_signed(36,8); i_des_temp <= to_signed(30,8); --low
    wait for 10 ns;
    
    -- --------------------
    i_reset<='0'; i_cur_temp <= to_signed(30,8); i_des_temp <= to_signed(27,8); --off
    wait for 10 ns;
    -- -------------------- round 4

    i_reset<='0'; i_cur_temp <= to_signed(30,8); i_des_temp <= to_signed(37,8); --high
    wait for 10 ns;
	-- --------------------
    i_reset<='1'; --off
    wait for 10 ns;

    --round 5

    i_reset<='0'; i_cur_temp <= to_signed(30,8); i_des_temp <= to_signed(38,8); --high
    wait for 10 ns;

	-- --------------------
    i_reset<='0'; i_cur_temp <= to_signed(36,8); i_des_temp <= to_signed(30,8); --low
    wait for 10 ns;
    
    -- --------------------
    i_reset<='0'; i_cur_temp <= to_signed(30,8); i_des_temp <= to_signed(27,8); --off
    wait for 10 ns;


end process;
  

end architecture;
