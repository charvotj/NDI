----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:40:47 10/18/2023 
-- Design Name: 
-- Module Name:    SPI - Behavioral 
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

entity SPI is
    Generic(
	g_DATA_SIZE : natural := 8
	);
    Port ( clk  : in  STD_LOGIC; -- crystal clock
           CS_b : in  STD_LOGIC;
           SCLK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           load_data : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           MISO : out  STD_LOGIC;
           fr_start : out  STD_LOGIC;
           fr_end : out  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0)
           );
end SPI;

architecture Behavioral of SPI is

    signal CS_b_edge_r_out  : std_logic;
    signal CS_b_edge_f_out  : std_logic;
    signal SCLK_edge_r_out  : std_logic;
    signal SCLK_edge_f_out  : std_logic;
begin

    component edge_detector
    port (
      sig_in     : in    std_logic;
      clk        : in    std_logic;
      edge_r_out : out   std_logic;
      edge_f_out : out   std_logic
    );
  end component;



  CS_b : component edge_detector
    port map (
      sig_in     => CS_b,
      clk        => clk,
      edge_r_out => CS_b_edge_r_out,
      edge_f_out => CS_b_edge_f_out
    );

  SCLK : component edge_detector
  port map (
          sig_in     => SCLK,
          clk        => clk,
          edge_r_out => SCLK_edge_r_out,
          edge_f_out => SCLK_edge_f_out
      );



end Behavioral;

