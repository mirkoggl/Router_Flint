library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
use work.routerpack.all;
 
ENTITY tb_multi_router IS
END tb_multi_router;
 
ARCHITECTURE behavior OF tb_multi_router IS 
 
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
        
   --Inputs
   signal clk, reset : std_logic := '0';
   
   signal Data_In, Data_Out :  data_array_type := (others => (others => '0'));
   signal Ready_Out, Ack_Out, Valid_Out, Ready_In, Valid_In :  std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
   
   signal Data_In_00, Data_Out_00, Data_In_01, Data_Out_01, Data_In_10, Data_Out_10, Data_In_11, Data_Out_11 : data_array_type := (others => (others => '0'));
   signal Ready_In_00, Ready_Out_00, Ready_In_01, Ready_Out_01, Ready_In_10, Ready_Out_10, Ready_In_11, Ready_Out_11  :  std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
   signal Valid_In_00, Valid_Out_00, Valid_In_01, Valid_Out_01, Valid_In_10, Valid_Out_10, Valid_In_11, Valid_Out_11  :  std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
	
	-- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	Data_In_00(NORTH_ID) <= Data_In(NORTH_ID);
	Data_In_00(EAST_ID) <= Data_In(EAST_ID);
	Valid_In_00(NORTH_ID) <= Valid_In(NORTH_ID);
	Ready_In_00(NORTH_ID) <= Ready_In(NORTH_ID);
	Valid_In_00(EAST_ID) <= Valid_In(EAST_ID);
	Ready_In_00(EAST_ID) <= Ready_In(EAST_ID);
 	
	-- Instantiate the Unit Under Test (UUT)
	uut0 : router_mesh
		generic map(
			LOCAL_X => 0,
			LOCAL_Y => 0
		)
		port map(
			clk       => clk,
			reset     => reset,
			Data_In   => Data_In_00,
			Ready_Out => Ready_Out_00,
			Valid_In  => Valid_In_00,
			Data_Out  => Data_Out_00,
			Valid_Out => Valid_Out_00,
			Ready_In  => Ready_In_00
		);
	
	Data_In_01(EAST_ID)  <= Data_Out_00(WEST_ID);
	Data_In_01(SOUTH_ID) <= Data_Out_11(NORTH_ID);
	Ready_In_01(EAST_ID) <= Ready_Out_00(WEST_ID);
	Valid_In_01(EAST_ID) <= Valid_Out_00(WEST_ID);
	Ready_In_01(SOUTH_ID) <= Ready_Out_11(NORTH_ID);
	Valid_In_01(SOUTH_ID) <= Valid_Out_11(NORTH_ID);
	
	uut1 : router_mesh
		generic map(
			LOCAL_X => 0,
			LOCAL_Y => 1
		)
		port map(
			clk       => clk,
			reset     => reset,
			Data_In   => Data_In_01,
			Ready_Out => Ready_Out_01,
			Valid_In  => Valid_In_01,
			Data_Out  => Data_Out_01,
			Valid_Out => Valid_Out_01,
			Ready_In  => Ready_In_01
		);
		
	Data_In_10(NORTH_ID)  <= Data_Out_00(SOUTH_ID);
	Data_In_10(WEST_ID)   <= Data_Out_11(EAST_ID);
	Ready_In_10(NORTH_ID) <= Ready_Out_00(SOUTH_ID);
	Valid_In_10(NORTH_ID) <= Valid_Out_00(SOUTH_ID);
	Ready_In_10(WEST_ID)  <= Ready_Out_11(EAST_ID);
	Valid_In_10(WEST_ID)  <= Valid_Out_11(EAST_ID);	
		
	uut2 : router_mesh
		generic map(
			LOCAL_X => 1,
			LOCAL_Y => 0
		)
		port map(
			clk       => clk,
			reset     => reset,
			Data_In   => Data_In_10,
			Ready_Out => Ready_Out_10,
			Valid_In  => Valid_In_10,
			Data_Out  => Data_Out_10,
			Valid_Out => Valid_Out_10,
			Ready_In  => Ready_In_10
		);
	
	Data_In_11(NORTH_ID) <= Data_Out_01(SOUTH_ID);
	Data_In_11(EAST_ID) <= Data_Out_10(WEST_ID);
	Ready_In_11(NORTH_ID) <= Ready_Out_01(SOUTH_ID);
	Valid_In_11(NORTH_ID) <= Valid_Out_01(SOUTH_ID);
	Ready_In_11(EAST_ID)  <= Ready_Out_10(WEST_ID);
	Valid_In_11(EAST_ID)  <= Valid_Out_10(WEST_ID);	
		
	uut3 : router_mesh
		generic map(
			LOCAL_X => 1,
			LOCAL_Y => 1
		)
		port map(
			clk       => clk,
			reset     => reset,
			Data_In   => Data_In_11,
			Ready_Out => Ready_Out_11,
			Valid_In  => Valid_In_11,
			Data_Out  => Data_Out_11,
			Valid_Out => Valid_Out_11,
			Ready_In  => Ready_In_11
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