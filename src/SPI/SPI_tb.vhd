--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:27:12 10/25/2023
-- Design Name:   
-- Module Name:   Z:/home/jakub/Plocha/NDI/Projekt/src/SPI/SPI_tb.vhd
-- Project Name:  AAU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SPI
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY SPI_tb IS
END SPI_tb;
 
ARCHITECTURE behavior OF SPI_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPI
    PORT(
         clk : IN  std_logic;
         CS_b : IN  std_logic;
         SCLK : IN  std_logic;
         MOSI : IN  std_logic;
         load_data : IN  std_logic;
         data_in : IN  std_logic_vector(7 downto 0);
         MISO : OUT  std_logic;
         fr_start : OUT  std_logic;
         fr_end : OUT  std_logic;
         data_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal CS_b : std_logic := '0';
   signal SCLK : std_logic := '0';
   signal MOSI : std_logic := '0';
   signal load_data : std_logic := '0';
   signal data_in : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal MISO : std_logic;
   signal fr_start : std_logic;
   signal fr_end : std_logic;
   signal data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant SCLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPI PORT MAP (
          clk => clk,
          CS_b => CS_b,
          SCLK => SCLK,
          MOSI => MOSI,
          load_data => load_data,
          data_in => data_in,
          MISO => MISO,
          fr_start => fr_start,
          fr_end => fr_end,
          data_out => data_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   SCLK_process :process
   begin
		SCLK <= '0';
		wait for SCLK_period/2;
		SCLK <= '1';
		wait for SCLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
