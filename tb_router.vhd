library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
use work.routerpack.all;
 
ENTITY tb_router IS
END tb_router;
 
ARCHITECTURE behavior OF tb_router IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    component router_mesh
    	generic(LOCAL_X : natural := 1;
    		    LOCAL_Y : natural := 1);
    	port(clk       : in  std_logic;
    		 reset     : in  std_logic;
    		 Data_In   : in  data_array_type;
    		 Ready_Out : out std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Valid_In  : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Data_Out  : out data_array_type;
    		 Valid_Out : out std_logic_vector(CHAN_NUMBER - 1 downto 0);
    		 Ready_In  : in  std_logic_vector(CHAN_NUMBER - 1 downto 0));
    end component router_mesh;
        
	constant LOCAL_X : natural := 1;
	constant LOCAL_Y : natural := 1; 
   --Inputs
   signal clk, reset : std_logic := '0';
   
   signal Data_In, Data_Out :  data_array_type := (others => (others => '0'));
   signal Ready_Out, Ack_Out, Valid_Out, Ready_In, Valid_In :  std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
	
	-- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
 	
	-- Instantiate the Unit Under Test (UUT)
   uut : router_mesh
   	generic map(
   		LOCAL_X => LOCAL_X,
   		LOCAL_Y => LOCAL_Y
   	)
   	port map(
   		clk       => clk,
   		reset     => reset,
   		Data_In   => Data_In,
   		Ready_Out => Ready_Out,
   		Valid_In  => Valid_In,
   		Data_Out  => Data_Out,
   		Valid_Out => Valid_Out,
   		Ready_In  => Ready_In
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
   	  Data_In(LOCAL_ID) <= x"9001"; -- Local X=2 Y=1 (south)
   	  Data_In(NORTH_ID) <= x"1002"; -- North X=0 Y=1 (north)
   	  Data_In(EAST_ID)  <= x"5003"; -- East  X=1 Y=1 (local)
   	  Data_In(WEST_ID)  <= x"7004"; -- West  X=1 Y=3 (east)
   	  Data_In(SOUTH_ID) <= x"4005"; -- South X=1 Y=0 (west)
    	  
      wait for 100 ns;	
	  reset <= '0';
	  Ready_In <= (others => '1');
	  Valid_In <= (others => '1');
	  
	  wait for clk_period;
	  Data_In(LOCAL_ID) <= x"B006"; -- Local X=2 Y=3 (south)
   	  Data_In(NORTH_ID) <= x"7007"; -- North X=0 Y=1 (east)
   	  Data_In(EAST_ID)  <= x"4008"; -- East  X=1 Y=1 (west)
   	  Data_In(WEST_ID)  <= x"3009"; -- West  X=1 Y=3 (north)
   	  Data_In(SOUTH_ID) <= x"500A"; -- South X=1 Y=0 (local)
	  Valid_In <= (others => '1');
	  
	  wait for clk_period;
	  Data_In(LOCAL_ID) <= x"500B"; -- Local X=2 Y=3 (local)
   	  Data_In(NORTH_ID) <= x"400C"; -- North X=0 Y=1 (west)
   	  Data_In(EAST_ID)  <= x"B00D"; -- East  X=1 Y=1 (south)
   	  Data_In(WEST_ID)  <= x"700E"; -- West  X=1 Y=3 (east)
   	  Data_In(SOUTH_ID) <= x"300F"; -- South X=1 Y=0 (north)
	  Valid_In <= (others => '1');

	  wait for clk_period;
	  Data_In(LOCAL_ID) <= x"1010"; -- Local X=2 Y=3 (north)
   	  Data_In(NORTH_ID) <= x"B011"; -- North X=0 Y=1 (south)
   	  Data_In(EAST_ID)  <= x"5012"; -- East  X=1 Y=1 (local)
   	  Data_In(WEST_ID)  <= x"7013"; -- West  X=1 Y=3 (east)
   	  Data_In(SOUTH_ID) <= x"4014"; -- South X=1 Y=0 (west)
	  Valid_In <= (others => '1');
	  
	  wait for clk_period;
	  Valid_In <= (others => '0');

      wait;
   end process;

END;