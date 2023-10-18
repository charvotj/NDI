----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:50:41 10/04/2023 
-- Design Name: 
-- Module Name:    deser - Behavioral 
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

entity deser is
Generic(
	g_DATA_SIZE : natural := 8
	);
	
    Port ( data : out  STD_LOGIC_VECTOR (g_DATA_SIZE-1 downto 0);
           shift_en : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           stream : in  STD_LOGIC);
end deser;

architecture Behavioral of deser is

signal reg_d, reg_q : STD_LOGIC_VECTOR (g_DATA_SIZE-1 downto 0) ;
begin

process (clk)
begin
	if(rising_edge(clk)) then
		if(rst = '1') then
			reg_q <= (others => '0');
		else
			reg_q <= reg_d;
		end if;
	end if;
end process;

process (shift_en, reg_q, stream)
begin	
	if(shift_en = '1') then
		reg_d <= reg_q(g_DATA_SIZE-2 downto 0) & stream;
	else
		reg_d <= reg_q;
	end if;
end process;
	
gen: for i in 0 to (g_DATA_SIZE-1) generate
	data(i) <= reg_q(g_DATA_SIZE-1-i);
end generate;


end Behavioral;
