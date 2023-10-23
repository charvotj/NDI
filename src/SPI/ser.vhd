----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:22:42 10/04/2023 
-- Design Name: 
-- Module Name:    ser - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ser is
	Generic(
	g_DATA_SIZE : natural := 8
	);
	
    Port ( data : in  STD_LOGIC_VECTOR (g_DATA_SIZE-1 downto 0);
           load_en : in  STD_LOGIC;
           shift_en : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           stream : out  STD_LOGIC);
end ser;

architecture Behavioral of ser is

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

process (load_en, shift_en, reg_q, data)
begin	
	if(load_en = '1') then
		reg_d <= data;
	elsif(shift_en = '1') then
		reg_d <= reg_q(g_DATA_SIZE-2 downto 0) & '0';
	else
		reg_d <= reg_q;
	end if;
end process;

stream <= reg_q(g_DATA_SIZE-1); -- LSB/MSB invert - reg_q(0);
--LSB should be first - so test this out
end Behavioral;

