----------------------------------------------------------------------------------
-- Company: 
-- Author: 	Mirko Gagliardi
-- 
-- Create Date:    01/10/2015
-- Design Name: 
-- Module Name:    Network Input Interface - rtl 
-- Project Name:   Router_Mesh	
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 	 
--
-- Revision: v 0.3
-- Additional Comments:
--		Network Input Interface gestisce i dati in ingresso al Router su un dato canale. Ogni dato è bufferizzato in una Fifo circolare. 
--		I dati in ingresso provengono dalla network Output Interface di un altro Router. Quando valid è alto, il componente salva il 
--		dato in ingresso in coda alla Fifo ed alza il bit di ack ad indicare che la trasmissione è avvenuta con successo. Se la Fifo è 
--		piena il dato non viene salvato e l'ack resta basso.
--
--			Output Interface				Input Interface
--			________________				__________________
--				       valid|-------------->|valid
--					Data_Out|-------------->|Data_In
--						ack	|<--------------|ack
--							|				|
--											
--		Se la Fifo possiede almeno un dato, il bit empty è basso e la Control Unit analizza l'indirizzo del dato in testa per capire su quale
--		interfaccia di uscita smistarlo. Quando il dato in testa è stato processato correttamente, la Control Unit asserisce il bit shft, ad 
--		indicare che tale dato è stato processato correttamente e che quindi può essere estratto dalla Fifo. 
--
--
--		     Input Interface				Control Unit
--			________________				_________________	
--					    shft|<--------------|shft
--					   sdone|-------------->|sdone
--					   empty|-------------->|empty
--							|				|							
--							|	            |
--
--		Quando la Fifo ha scartato il dato in testa alza il bit sdone ad indicare alla Control Unit che l'operazione è avvenuta con successo.
--		I dati in uscita dalla Network Input Interface sono collegati all'ingresso della crossbar.
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;

entity net_input_interface is
	Generic (
		FIFO_LENGTH : natural := 16;
		DATA_WIDTH : natural := 16
	);
	Port (
		clk : in std_logic;
		reset : in std_logic;
		
		Data_In  : in std_logic_vector(DATA_WIDTH-1 downto 0);	-- Data Input
		Valid_In : in std_logic;								-- Data Input valid
		Shft_In  : in std_logic;								-- Shift enable		
		
		Empty_Out  : out std_logic;
		Full_Out   : out std_logic;								-- Fifo Full
		Ready_Out  : out std_logic;
		Data_Out : out std_logic_vector(DATA_WIDTH-1 downto 0)  -- Data Output, to the Crossbar Data Input
	);
end entity net_input_interface;

architecture RTL of net_input_interface is
	
	constant max_vect : std_logic_vector(f_log2(FIFO_LENGTH) downto 0) := conv_std_logic_vector(FIFO_LENGTH, f_log2(FIFO_LENGTH)+1);
	constant min_vect : std_logic_vector(f_log2(FIFO_LENGTH) downto 0) := (others => '0');
	
	type fifo_type is array (0 to FIFO_LENGTH-1) of std_logic_vector(DATA_WIDTH-1 downto 0);	
	
	signal fifo_memory : fifo_type := (others => (others => '0'));
	signal head_pt, tail_pt : std_logic_vector(f_log2(FIFO_LENGTH)-1 downto 0) := (others => '0');	
	signal fifo_full, fifo_empty : std_logic := '0';
	
begin
	
	fifo_full <= '1' when head_pt = (tail_pt + '1')
						else '0';
	
	fifo_empty <= '1' when head_pt = tail_pt		
						else '0'; 
	
	Empty_Out <= fifo_empty;
	Full_Out  <= fifo_full;
	Data_Out  <= fifo_memory(conv_integer(head_pt));
	Ready_Out <= not reset;
	

	process (clk, reset)
	begin
		if reset = '1' then
		  head_pt <= (others => '0');
		  tail_pt <= (others => '0');
		  fifo_memory <= (others => (others => '0'));
		
		elsif rising_edge(clk) then		
					      
		  if Valid_In ='1' then		    -- Data input valid
			  if fifo_full = '0' then	-- Data input can be stored
				 fifo_memory(conv_integer(tail_pt)) <= Data_In; 	-- Data input stored correctly
				 tail_pt <= tail_pt + '1';
			  end if;
		  end if;
		  	
		  if Shft_In = '1' then			-- Top Fifo data eliminated
			  if fifo_empty = '0' then
				 head_pt <= head_pt + '1';
			  end if;
		  end if;  
		
		end if;     
	end process;

end architecture RTL;
