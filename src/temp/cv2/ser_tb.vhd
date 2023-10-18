--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:59:51 10/04/2023
-- Design Name:   
-- Module Name:   C:/Users/240844/Documents/NDI/CV_2_Serializer/ser_tb.vhd
-- Project Name:  CV_2_Serializer
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ser
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
 
ENTITY ser_tb IS
END ser_tb;
 
ARCHITECTURE behavior OF ser_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
--    COMPONENT ser
--    PORT(
--         data : IN  std_logic_vector(7 downto 0);
--         load_en : IN  std_logic;
--         shift_en : IN  std_logic;
--         rst : IN  std_logic;
--         clk : IN  std_logic;
--         stream : OUT  std_logic
--        );
--    END COMPONENT;
    

	constant c_BIT_SIZE : natural := 13;
	
   --Inputs
   signal data : std_logic_vector(c_BIT_SIZE-1 downto 0) := (others => '0');
	signal data_out : std_logic_vector(c_BIT_SIZE-1 downto 0) := (others => '0');
   signal load_en : std_logic := '0';
   signal shift_en : std_logic := '0';
   signal rst : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal stream : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
 uut_ser: entity work.ser 
		generic map (
			g_DATA_SIZE => c_BIT_SIZE
			)	
	PORT MAP (
          data => data,
          load_en => load_en,
          shift_en => shift_en,
          rst => rst,
          clk => clk,
          stream => stream
        );
uut_deser: entity work.deser 
		generic map (
			g_DATA_SIZE => c_BIT_SIZE
			)	
	PORT MAP (
          data_out => data,
          shift_en => shift_en,
          rst => rst,
          clk => clk,
          stream => stream
        );
		  
		  

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
		data <= "0010101010101";
      wait for clk_period*10;
		load_en <= '1';
		wait for clk_period*9.5;
		load_en <= '0';
		shift_en <='1';
		wait for clk_period*(c_BIT_SIZE/2);
		--rst <= '1';
		wait for clk_period*(c_BIT_SIZE/2+2);
		shift_en <='0';
		rst <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
