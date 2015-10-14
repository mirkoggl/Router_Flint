library ieee;
use ieee.std_logic_1164.all;  
use ieee.numeric_std.all; 

entity shifter_rol is
	Generic(
		N : natural := 4
	);
	Port (		
		vect_in : in std_logic_vector(N - 1 downto 0);
		num_shift : in natural;
		vect_out : out std_logic_vector(N - 1 downto 0)
	);
end entity shifter_rol;

architecture RTL of shifter_rol is
	
begin
	
	vect_out <= std_logic_vector(unsigned(vect_in) rol num_shift);

end architecture RTL;
