--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   14:28:34 09/27/2023
-- Design Name:
-- Module Name:   C:/Users/240844/Documents/NDI/CV_1_Uvod/tb.vhd
-- Project Name:  CV_1_Uvod
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: edge_and_explorer_detector
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

library ieee;
  use ieee.std_logic_1164.all;
  use std.env.finish;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
-- USE ieee.numeric_std.ALL;

entity tb is
end entity tb;

architecture behavior of tb is

  -- Component Declaration for the Unit Under Test (UUT)

  component edge_and_explorer_detector
    port (
      sig_in     : in    std_logic;
      clk        : in    std_logic;
      edge_r_out : out   std_logic;
      edge_f_out : out   std_logic
    );
  end component;

  -- Inputs
  signal sig_in : std_logic := '0';
  signal clk    : std_logic := '0';

  -- Outputs
  signal edge_r_out : std_logic;
  signal edge_f_out : std_logic;

  -- Clock period definitions
  constant clk_period : time := 10 ns;

begin

  -- Instantiate the Unit Under Test (UUT)
  uut : component edge_and_explorer_detector
    port map (
      sig_in     => sig_in,
      clk        => clk,
      edge_r_out => edge_r_out,
      edge_f_out => edge_f_out
    );

  -- Clock process definitions
  clk_process : process
  begin

    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;

  end process clk_process;

  -- Stimulus process
  stim_proc : process
  begin

    -- hold reset state for 100 ns.
    wait for clk_period * 7;
    wait until rising_edge(clk);
    -- wait for clk_period*2.5;

    sig_in <= '1';
    wait for clk_period * 2;
    wait until rising_edge(clk);
    sig_in <= '0';

    wait for clk_period * 10;
    sig_in <= '1';

    -- insert stimulus here
    finish;
    wait;

  end process stim_proc;

end architecture behavior;
