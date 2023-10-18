----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:21:23 09/27/2023 
-- Design Name: 
-- Module Name:    edge_and_explorer_detector - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity edge_and_explorer_detector is
    Port ( sig_in : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sig_out : out  STD_LOGIC);
end edge_and_explorer_detector;

architecture Behavioral of edge_and_explorer_detector is

	signal Q_out, XOR_out : STD_LOGIC;
	
begin

-- sekvencni cast
process(clk) 
begin
	if(rising_edge(clk)) then
		Q_out <= sig_in;
	end if;
end process;

-- kombinacni cast
XOR_out <= Q_out xor sig_in;
sig_out <= XOR_out and not sig_in;



end Behavioral;

