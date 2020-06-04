------------------------------------------------------------------------
-- fir test bench
------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.fir_synth_pkg.all;

entity fir_tb is
end entity;

------------------------------------------------------------------------

architecture main of fir_tb is
  signal i_data: word;
  signal clk :  std_logic;
  signal o_data  : word;
  
begin
   --u_low: entity work.fir(low_pass)
   uut : entity work.fir(avg)
     port map (
       clk => clk,
	   i_data => i_data,
	   o_data => o_data
     );
 
process
begin
clk <= '1';
wait for 10 ns;
clk <= '0';
wait for 10 ns;
end process;

process
begin
i_data<=x"0000";
wait until rising_edge(clk);
wait until rising_edge(clk);
wait until rising_edge(clk);
wait until rising_edge(clk);
i_data<=x"1000";
wait until rising_edge(clk);
i_data<=x"0000";
wait;
end process;

end architecture;
------------------------------------------------------------------------

