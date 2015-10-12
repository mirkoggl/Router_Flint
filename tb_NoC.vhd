library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
use work.routerpack.all;
 
ENTITY tb_NoC IS
END tb_NoC;
 
ARCHITECTURE behavior OF tb_NoC IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    component NoC
    	port(clk      : in  std_logic;
    		 reset    : in  std_logic;
    		 Data_In  : in  data_array_type;
    		 Valid_In : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Data_Out : out data_array_type;
    		 Ready_In : in  std_logic_vector(CHAN_NUMBER - 1 downto 0));
    end component NoC;
        
	constant LOCAL_X : natural := 1;
	constant LOCAL_Y : natural := 1; 
   --Inputs
   signal clk, reset : std_logic := '0';
   
   signal Data_In, Data_Out :  data_array_type := (others => (others => '0'));
   signal Ready_Out, Full_Out, Full_In, Valid_Out, Ready_In, Valid_In :  std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
	
	-- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
 	
	-- Instantiate the Unit Under Test (UUT)
   uut : NoC
   	port map(
   		clk      => clk,
   		reset    => reset,
   		Data_In  => Data_In,
   		Valid_In => Valid_In,
   		Data_Out => Data_Out,
   		Ready_In => Ready_In
   	);
 
   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
   	-- hold reset state for 100 ns.
   	  reset <= '1';
   	  Data_In(LOCAL_ID) <= x"3004"; -- Local X=2 Y=1 (south)
    	  
      wait for 100 ns;	
	  reset <= '0';
	  Ready_In <= (others => '0');
	  Valid_In(LOCAL_ID) <= '1';
	  
	  wait for clk_period;
	  Data_In(LOCAL_ID) <= x"3007"; -- Local X=2 Y=3 (south)
	  
	  wait for clk_period;
	  Data_In(LOCAL_ID) <= x"300E"; -- Local X=2 Y=3 (local)

	  wait for clk_period;
	  Data_In(LOCAL_ID) <= x"3013"; -- Local X=2 Y=3 (north)
   	
	  wait for clk_period;
	  Valid_In <= (others => '0');

      wait;
   end process;

END;