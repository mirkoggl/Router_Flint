library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all; 

entity shifter_ror is
	Generic(
		N : natural := 4
	);
	Port (		
		vect_in : in std_logic_vector(N - 1 downto 0);
		num_shift : in natural;
		vect_out : out std_logic_vector(N - 1 downto 0)
	);
end entity shifter_ror;

architecture RTL of shifter_ror is
	
begin
	
	vect_out <= std_logic_vector(unsigned(vect_in) ror num_shift);

end architecture RTL;