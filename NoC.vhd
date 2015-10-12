library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
use work.routerpack.all;

entity NoC is
	Port (
		clk   : in std_logic;
		reset : in std_logic;
		
		Data_In  : in  data_array_type;
		Valid_In : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
		Data_Out : out data_array_type;
		Ready_In : in  std_logic_vector(CHAN_NUMBER - 1 downto 0)
	);
end entity NoC;

architecture RTL of NoC is
	
	COMPONENT router_mesh
		Generic(
			LOCAL_X : natural := 1;
			LOCAL_Y : natural := 1
		);
		Port(clk       : in  std_logic;
			 reset     : in  std_logic;
			 Data_In   : in  data_array_type;
			 Ready_Out : out std_logic_vector(CHAN_NUMBER - 1 downto 0);
			 Valid_In  : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
			 Full_Out  : out std_logic_vector(CHAN_NUMBER - 1 downto 0);
			 Data_Out  : out data_array_type;
			 Valid_Out : out std_logic_vector(CHAN_NUMBER - 1 downto 0);
			 Full_In   : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
			 Ready_In  : in  std_logic_vector(CHAN_NUMBER - 1 downto 0)
		);
	END COMPONENT;
	
	type noc_data_array is array (0 to ROW_LENGTH * COL_LENGTH - 1 ) of data_array_type;
	
	signal data_in_00, data_in_01, data_out_00, data_out_01 : data_array_type := (others => (others => '0'));
	signal ready_out_00, ready_out_01, valid_in_00, valid_in_01, full_out_00, full_out_01 : std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
	signal valid_out_00, valid_out_01, full_in_00, full_in_01, ready_in_00, ready_in_01 : std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
		
begin
	
--   Router_GEN_X : for i in 0 to ROW_LENGTH - 1 generate
--     Router_GEN_Y : for j in 0 to COL_LENGTH - 1 generate 
--	      RouterX : router_mesh
--	      	Generic Map(
--	      		LOCAL_X => i,
--	      		LOCAL_Y => j
--	      	)
--	      	Port Map(
--	      		clk       => clk,
--	      		reset     => reset,
--	      		Data_In   => data_in((i+1)*j),
--	      		Ready_Out => Ready_Out,
--	      		Valid_In  => Valid_In,
--	      		Full_Out  => Full_Out,
--	      		Data_Out  => Data_Out,
--	      		Valid_Out => Valid_Out,
--	      		Full_In   => Full_In,
--	      		Ready_In  => Ready_In
--	      	);
--	   end generate Router_GEN_Y;
--  end generate Router_GEN_X;

	data_in_00(LOCAL_ID) <= Data_In(LOCAL_ID);
	valid_in_00(LOCAL_ID) <= Valid_In(LOCAL_ID);
	ready_in_00(LOCAL_ID) <= Ready_In(LOCAL_ID);

	Router_00 : router_mesh
		generic map(
			LOCAL_X => 0,
			LOCAL_Y => 0
		)
		port map(
			clk       => clk,
			reset     => reset,
			Data_In   => data_in_00,
			Ready_Out => ready_out_00,
			Valid_In  => valid_in_00,
			Full_Out  => full_out_00,
			Data_Out  => data_out_00,
			Valid_Out => valid_out_00,
			Full_In   => full_in_00,
			Ready_In  => ready_in_00
		);
	
	data_in_01(WEST_ID)  <= data_out_00(EAST_ID);
	valid_in_01(WEST_ID) <= valid_out_00(EAST_ID);
	ready_in_00(EAST_ID) <= ready_out_01(WEST_ID);
	full_in_00(EAST_ID)  <= full_out_01(WEST_ID);
	
	Router_01 : router_mesh
		generic map(
			LOCAL_X => 0,
			LOCAL_Y => 1
		)
		port map(
			clk       => clk,
			reset     => reset,
			Data_In   => data_in_01,
			Ready_Out => ready_out_01,
			Valid_In  => valid_in_01,
			Full_Out  => full_out_01,
			Data_Out  => data_out_01,
			Valid_Out => valid_out_01,
			Full_In   => full_in_01,
			Ready_In  => ready_in_01
		);
	
	ready_in_01(EAST_ID) <= '1';
	Data_Out <= data_out_01;

end architecture RTL;
