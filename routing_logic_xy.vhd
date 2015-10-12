----------------------------------------------------------------------------------
-- Company: 
-- Author: 	Mirko Gagliardi
-- 
-- Create Date:    02/10/2015
-- Design Name: 
-- Module Name:    Routing Logic XY - rtl 
-- Project Name:   Router_Mesh	
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 	 
--
-- Revision: v 0.1
-- Additional Comments:
--		Estrae dal messaggio in ingresso l'indirizzo del destinatario ed effettua un semplice routing XY.
--		Eseguito il routing comanda la Crossbar in modo da mettere in comunicazione la Input Fifo in ingresso
--		con il buffer in uscita opportuno.
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library work;
use work.logpack.all;
use work.routerpack.all;

entity routing_logic_xy is
	Generic (
		LOCAL_X : natural := 1;
		LOCAL_Y : natural := 1
	);
	Port (
		Data_In      : in std_logic_vector(DATA_WIDTH-1 downto 0);
		In_Channel   : in std_logic_vector(SEL_WIDTH-1 downto 0);
		Out_Channel  : out std_logic_vector(SEL_WIDTH-1 downto 0); 
		Crossbar_Sel : out crossbar_sel_type		
	);
end entity routing_logic_xy;

architecture RTL of routing_logic_xy is
	
	constant X_source : std_logic_vector(ADDRESS_LENGTH-1 downto 0) := conv_std_logic_vector(LOCAL_X, ADDRESS_LENGTH);
	constant Y_source : std_logic_vector(ADDRESS_LENGTH-1 downto 0) := conv_std_logic_vector(LOCAL_Y, ADDRESS_LENGTH);
	
	alias X_dest : std_logic_vector(ADDRESS_LENGTH-1 downto 0) is Data_In(DATA_WIDTH-1 downto DATA_WIDTH-ADDRESS_LENGTH);
	alias Y_dest : std_logic_vector(ADDRESS_LENGTH-1 downto 0) is Data_In(DATA_WIDTH-ADDRESS_LENGTH-1 downto DATA_WIDTH-2*ADDRESS_LENGTH);
	
	signal sel_temp : crossbar_sel_type := (others => (others => '0'));

begin
		
	Crossbar_Sel <= sel_temp;
	
	routing_mesh : process(Data_In, In_Channel) 
		begin
			if X_dest > X_source then
				sel_temp(SOUTH_ID) <= In_Channel;  -- South
				Out_Channel <= CONV_STD_LOGIC_VECTOR(SOUTH_ID, SEL_WIDTH);
			elsif X_dest < X_source then
				sel_temp(NORTH_ID) <= In_Channel;  -- North
				Out_Channel <= CONV_STD_LOGIC_VECTOR(NORTH_ID, SEL_WIDTH);
			else
				if Y_dest > Y_source then
					sel_temp(EAST_ID) <= In_Channel; -- East
					Out_Channel <= CONV_STD_LOGIC_VECTOR(EAST_ID, SEL_WIDTH);
				elsif Y_dest < Y_source then
					sel_temp(WEST_ID) <= In_Channel; -- West
					Out_Channel <= CONV_STD_LOGIC_VECTOR(WEST_ID, SEL_WIDTH);
				else
					sel_temp(LOCAL_ID) <= In_Channel; -- Local
					Out_Channel <= CONV_STD_LOGIC_VECTOR(LOCAL_ID, SEL_WIDTH);
				end if;
			end if;
		end process;

end architecture RTL;