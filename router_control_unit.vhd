library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
use work.routerpack.all;

entity router_control_unit is
	Generic (
		LOCAL_X : natural := 1;
		LOCAL_Y : natural := 1
	);
	Port (
		clk   : in std_logic;
		reset : in std_logic;
		Data_In  : in data_array_type;
		Empty_In : in std_logic_vector(CHAN_NUMBER-1 downto 0);
		Full_Out : in std_logic_vector(CHAN_NUMBER-1 downto 0);
		
		Shft_In   : out std_logic_vector(CHAN_NUMBER-1 downto 0);
		Wr_En_Out : out std_logic_vector(CHAN_NUMBER-1 downto 0);
		Cross_Sel : out crossbar_sel_type	
	);
end entity router_control_unit;

architecture RTL of router_control_unit is
		
	COMPONENT routing_logic_xy
		Generic(
			LOCAL_X    : natural := 1;
			LOCAL_Y    : natural := 1
		);
		Port(
			Data_In      : in std_logic_vector(DATA_WIDTH-1 downto 0);
			In_Channel   : in std_logic_vector(SEL_WIDTH-1 downto 0);
			Out_Channel  : out std_logic_vector(SEL_WIDTH-1 downto 0); 
			Crossbar_Sel : out crossbar_sel_type		
		);
	END COMPONENT routing_logic_xy;
	
	COMPONENT shifter_rol
		Generic(
			N : natural := 4
		);
		Port(
			vect_in   : in  std_logic_vector(N - 1 downto 0);
			num_shift : in  natural;
		    vect_out  : out std_logic_vector(N - 1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT shifter_ror
		Generic(
			N : natural := 4
		);
		Port(
			vect_in   : in  std_logic_vector(N - 1 downto 0);
			num_shift : in  natural;
			vect_out  : out std_logic_vector(N - 1 downto 0)
		);
	END COMPONENT;
	
	COMPONENT onehot_converter
		Port(
			vect_in  : in  std_logic_vector(CHAN_NUMBER - 1 downto 0);
			vect_out : out std_logic_vector(SEL_WIDTH - 1 downto 0)
		);
	END COMPONENT;
	
	constant ZERO_VECT : std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
	type state_type is (idle, out_wren, out_delay); 
	
	-- Control Unit Signals
	signal current_s : state_type := idle;
	signal rr_vector   : std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
	signal rr_winner   : std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0');
	signal rr_final    : std_logic_vector(CHAN_NUMBER - 1 downto 0) := (others => '0'); 
	signal rr_counter  : std_logic_vector(SEL_WIDTH - 1 downto 0) := (others => '0');
	signal rr_index    : std_logic_vector(SEL_WIDTH - 1 downto 0)  := (others => '0');
	signal xy_data_in  : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
	signal xy_chan_in  : std_logic_vector(SEL_WIDTH - 1 downto 0) := (others => '0');
	signal xy_chan_out : std_logic_vector(SEL_WIDTH - 1 downto 0) := (others => '0');
	
begin
	
	XY_logic : routing_logic_xy
		Generic Map(
			LOCAL_X    => LOCAL_X,
			LOCAL_Y    => LOCAL_Y
		)
		Port Map(
			Data_In      => xy_data_in,
			In_Channel   => xy_chan_in,
			Out_Channel  => xy_chan_out,
			Crossbar_Sel => Cross_Sel
		);
	
	Shifter_Rol_inst : shifter_rol
		Generic Map(
			N => CHAN_NUMBER
		)
		Port Map(
			vect_in   => Empty_In,
			num_shift => CONV_INTEGER(rr_counter),
			vect_out  => rr_vector
		);
	
	Shifter_Ror_inst : shifter_ror
		generic map(
			N => CHAN_NUMBER
		)
		port map(
			vect_in   => rr_winner,
			num_shift => CONV_INTEGER(rr_counter),
			vect_out  => rr_final
		);
	
	OneHot_Converter_inst : onehot_converter
		Port Map(
			vect_in  => rr_final,
			vect_out => rr_index
		);
	
	CU_process : process (clk, reset)
	begin
		if reset = '1' then
			current_s <= idle;
			Wr_En_Out <= (others => '0');
			Shft_In <= (others => '0');
			rr_counter <= (others => '0');
		
		elsif rising_edge(clk) then		
			
			Shft_In <= (others => '0');
			Wr_En_Out <= (others => '0');
			
			if rr_counter = CONV_STD_LOGIC_VECTOR(CHAN_NUMBER, SEL_WIDTH) then
				rr_counter <= (others => '0');
			else
				rr_counter <= rr_counter + '1';
			end if;
			
			rr_winner <= not(rr_vector) + '1';			
			
		    case current_s is
		     when idle =>
		     	
		     	if Empty_In = ZERO_VECT then
		     		xy_data_in <= Data_In(CONV_INTEGER(rr_index)); 
			    	xy_chan_in <= rr_index;
		     	end if;       
--			    if Empty_In(LOCAL_ID) = '0' then		-- Da sostituire con selettore Round Robin
--			    	current_s <= out_wren; 
--			    	xy_data_in <= Data_In(LOCAL_ID); 
--			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(LOCAL_ID, SEL_WIDTH);
--			    elsif Empty_In(NORTH_ID) = '0' then
--			    	current_s <= out_wren;
--			    	xy_data_in <= Data_In(NORTH_ID);
--			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(NORTH_ID, SEL_WIDTH);
--			    elsif Empty_In(EAST_ID) = '0' then
--			    	current_s <= out_wren;
--			    	xy_data_in <= Data_In(EAST_ID);
--			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(EAST_ID, SEL_WIDTH);
--			    elsif Empty_In(WEST_ID) = '0' then
--			    	current_s <= out_wren;
--			    	xy_data_in <= Data_In(WEST_ID);
--			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(WEST_ID, SEL_WIDTH);
--			    elsif Empty_In(SOUTH_ID) = '0' then	
--			    	current_s <= out_wren;
--			    	xy_data_in <= Data_In(SOUTH_ID);
--			    	xy_chan_in <= CONV_STD_LOGIC_VECTOR(SOUTH_ID, SEL_WIDTH);
--			    else 
--			    	current_s <= idle;
--			    end if;
			    			
			when out_wren =>	
				if Full_Out(CONV_INTEGER(xy_chan_out)) = '1' then  -- Fifo Out full, scarta il pacchetto e torna idle
					current_s <= idle;
				else
					current_s <= out_delay;
					Wr_En_Out(CONV_INTEGER(xy_chan_out)) <= '1';
					Shft_In(CONV_INTEGER(xy_chan_in)) <= '1';
				end if;
			
			when out_delay => 	-- Stato usato per generare impulsi di write ed evitare di scrivere nel buffer di uscita più volte lo stesso dato
				current_s <= idle;
						    
			end case;
		
		end if;
	end process;
	
end architecture RTL;
