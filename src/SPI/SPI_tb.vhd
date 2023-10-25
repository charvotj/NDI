LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.env.finish;
USE ieee.numeric_std.ALL;
 
ENTITY SPI_tb IS
Generic(
   g_DATA_SIZE : natural := 8 --<<<<<<<<<<<<<---------------------------------------------------------------------
   );
END SPI_tb;
 
ARCHITECTURE behavior OF SPI_tb IS 

 
    
   --Inputs
   signal clk : std_logic := '0';
   signal CS_b : std_logic := '0';
   signal SCLK : std_logic := '0';
   signal MOSI : std_logic := '0';
   signal load_data : std_logic := '0';
   signal data_in : std_logic_vector(g_DATA_SIZE-1 downto 0) := (others => '0');

 	--Outputs
   signal MISO : std_logic;
   signal fr_start : std_logic;
   signal fr_end : std_logic;
   signal data_out : std_logic_vector(g_DATA_SIZE-1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant SCLK_period : time := 100 ns;
 

   -- THX GPT
   procedure send_serial(signal clk : in std_logic;
                         signal serial_out : out std_logic;
                         data : in std_logic_vector(g_DATA_SIZE-1 downto 0);
                         r_edge : in std_logic) -- '1': rising edge, '0': falling edge
                         is
   begin
       for i in 0 to g_DATA_SIZE-1 loop
            if (r_edge = '1') then
               wait until rising_edge(clk);
            else
               wait until falling_edge(clk);
            end if;
           serial_out <= data(i);
       end loop;
   end procedure send_serial;


BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.SPI(Behavioral)
      generic map (
        g_DATA_SIZE => g_DATA_SIZE
        )	
      PORT MAP (
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
      wait for clk_period*10;
      send_serial(SCLK, MOSI, "01110001",'1');
      wait for clk_period*10;
      CS_b <= '1';
      send_serial(SCLK, MOSI, "01110001",'1'); -- nema se posilat

      wait for clk_period*10;

      
      load_data<='1';
      wait for clk_period*20;
      load_data<='0';
      CS_b <= '0';
      
      wait for clk_period*100;

      -- insert stimulus here 
      finish;
      wait;
   end process;
   data_in <= data_out;
END;
