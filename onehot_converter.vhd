library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.logpack.all;
use work.routerpack.all;

entity onehot_converter is
	Port(
		vect_in  : in std_logic_vector(CHAN_NUMBER - 1 downto 0);
		vect_out : out std_logic_vector(SEL_WIDTH - 1 downto 0)
	);
end entity onehot_converter;

architecture RTL of onehot_converter is
	
begin
	
 onehot : process (vect_in) begin	
	case vect_in is
	  when "00001" =>   vect_out <= "000";
	  when "00010" =>   vect_out <= "001";
	  when "00100" =>   vect_out <= "010";
	  when "01000" =>   vect_out <= "011";
	  when "10000" =>	vect_out <= "100";
	  when others => vect_out <= "000";
	end case;
 end process;

end architecture RTL;
