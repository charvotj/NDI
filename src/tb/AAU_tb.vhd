LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.env.finish;
USE ieee.numeric_std.ALL;
 
ENTITY AAU_tb IS
Generic(
   g_DATA_SIZE : natural := 16 --<<<<<<<<<<<<<---------------------------------------------------------------------
   );
END AAU_tb;
 
ARCHITECTURE behavior OF AAU_tb IS 

 
    
   --Inputs
   signal clk : std_logic := '0';
   signal CS_b : std_logic := '0';
   signal SCLK : std_logic := '0';
   signal MOSI : std_logic := '0';
   
 	--Outputs
   signal MISO : std_logic;
   
   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant SCLK_period : time := 100 ns;
 

  
   procedure send_serial(signal clk : in std_logic;
                         signal serial_out : out std_logic;
                         data_len : in natural;
                         data : in  natural;
                         r_edge : in std_logic) -- '1': rising edge, '0': falling edge
                         is
   variable data_vector : std_logic_vector(data_len-1 downto 0) := std_logic_vector(to_unsigned(data,data_len));
   begin
       for i in 0 to data_len-1 loop
            if (r_edge = '1') then
               wait until rising_edge(clk);
            else
               wait until falling_edge(clk);
            end if;
           serial_out <= data_vector(i);
       end loop;
   end procedure send_serial;


BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.AAU(Behavioral)
      generic map (
        g_DATA_SIZE => g_DATA_SIZE
        )	
      PORT MAP (
         clk  => clk,
         SCLK => SCLK,
         CS_b => CS_b,
         MOSI => MOSI,
         MISO => MISO
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
      CS_b <= '1';
      wait for clk_period*10;

      -- send first frame
      CS_b <= '0';
      send_serial(SCLK, MOSI ,5, 15 ,'0');
      wait for SCLK_period*1;
      CS_b <= '1';
      -- delay
      wait for clk_period*10;

      -- send second frame
      CS_b <= '0';
      send_serial(SCLK, MOSI ,16, 9595 ,'0');
      wait for SCLK_period*1;
      CS_b <= '1';


      wait for clk_period*10;

      
      wait for clk_period*100;

      -- insert stimulus here 
      finish;
      wait;
   end process;

END;
