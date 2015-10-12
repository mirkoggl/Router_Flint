library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
 
ENTITY tb_shifter IS
END tb_shifter;
 
ARCHITECTURE behavior OF tb_shifter IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    component shifter
    	generic(N : natural := 4);
    	port(
    		 vect_in   : in  std_logic_vector(N - 1 downto 0);
    		 num_shift : in  natural;
    		 vect_out  : out std_logic_vector(N - 1 downto 0)
    	);
    end component shifter;
        
	constant N : natural := 4;
   --Inputs   
   signal vect_in, vect_out : std_logic_vector(N - 1 downto 0);
   signal num_shift :  natural;
	
	-- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
 	
	-- Instantiate the Unit Under Test (UUT)
   uut : shifter
   	generic map(
   		N => N
   	)
   	port map(
   		vect_in   => vect_in,
   		num_shift => num_shift,
   		vect_out  => vect_out
   	);
 
 
   -- Stimulus process
   stim_proc: process
   begin		
   	-- hold reset state for 100 ns.
    	  
      wait for 100 ns;	
	  vect_in <= "0110";
	  num_shift <= 3;
	  
	  wait for 30 ns;
	  num_shift <= 1;
	  
	  wait for 30 ns;
	  num_shift <= 2;
	  
	  wait for 30 ns;
	  num_shift <= 0;

      wait;
   end process;

END;