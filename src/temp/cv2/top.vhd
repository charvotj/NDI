----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:58:37 10/04/2023 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
use work.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
Generic(
	g_DATA_SIZE : natural := 8
	);
	
    Port ( data : in  STD_LOGIC_VECTOR (g_DATA_SIZE-1 downto 0);
			  data_out : out  STD_LOGIC_VECTOR (g_DATA_SIZE-1 downto 0);
           load_en : in  STD_LOGIC;
           shift_en : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           clk : in  STD_LOGIC);
end top;

architecture Behavioral of top is

signal stream : std_logic;
begin

 ser: entity work.ser(Behavioral)
		generic map (
			g_DATA_SIZE => g_DATA_SIZE
			)	
	port map (
          data => data,
          load_en => load_en,
          shift_en => shift_en,
          rst => rst,
          clk => clk,
          stream => stream
        );
deser: entity work.deser(Behavioral)
		generic map (
			g_DATA_SIZE => g_DATA_SIZE
			)	
	PORT MAP (
          data => data_out,
          shift_en => shift_en,
          rst => rst,
          clk => clk,
          stream => stream
        );

end Behavioral;

