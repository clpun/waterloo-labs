library ieee;
use ieee.std_logic_1164.all;

package heat_pkg is
  subtype heat_ty is std_logic_vector(1 downto 0);
  constant off  : heat_ty := "00";
  constant low  : heat_ty := "01";
  constant high : heat_ty := "11";
end heat_pkg;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.heat_pkg.all;

entity heatingsys is                           -- finite state machine
  port(i_cur_temp       : in signed(7 downto 0); -- current temp
       i_des_temp       : in signed(7 downto 0); -- desired temp
       i_reset          : in std_logic;          -- reset
       i_clock          : in std_logic;          -- clock
       o_heatmode       : out heat_ty            -- mode
      );
end heatingsys;

architecture main of heatingsys is
  signal state : heat_ty; 
signal tempdiff : signed (7 downto 0);
signal tempdiffcd : signed (7 downto 0);
begin
  tempdiff <= (i_des_temp - i_cur_temp);
  tempdiffcd <= (i_cur_temp - i_des_temp);
  process begin

  wait until rising_edge(i_clock);
  if(i_reset = '1') then
	state <= off;
  else
  case state is
	when off =>
		if(tempdiff>=5) then
			state <= high;
		elsif(tempdiff >=3 and tempdiff<5) then
			state <= low;
		end if;
	when low =>
		if(tempdiff>=7) then
			state<=high;
		elsif (tempdiffcd>2) then
			state<=off;
		end if;
	when high =>
		if(tempdiffcd>3) then
			state<=low;
		end if;
	when others =>
			state<=off;
   end case;
  end if;
 end process;
	o_heatmode<=state;
end main;

-- question 1
  --1-bit flip-flops (2) or 1 2-bit flip flop, 1-bit latches (0),
  --ANDs (12), ORs (12), XORs (0), NOTs (15), adders (0), subtracters (1), comparators (1), multiplexers(0).


