LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.env.finish;
USE ieee.numeric_std.ALL;
use work.tb_verification.all;
 
ENTITY AAU_tb IS
Generic(
   g_DATA_SIZE : natural := c_DATA_SIZE --<<<<<<<<<<<<<---------------------------------------------------------------------
   );
END AAU_tb;
 
ARCHITECTURE behavior OF AAU_tb IS 

    
   --Signals
   signal clk : std_logic := '0';
   signal SPI_bus : SPI_bus_t;
   
   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant SCLK_period : time := 100 ns;


BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.AAU(Behavioral)
      generic map (
        g_DATA_SIZE => g_DATA_SIZE
        )	
      PORT MAP (
         clk  => clk,
         SCLK => SPI_bus.SCLK,
         CS_b => SPI_bus.CS_b,
         MOSI => SPI_bus.MOSI,
         MISO => SPI_bus.MISO
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;

   
   --VELKY SPATNY :_C sad
   SCLK_process :process
   begin
      SPI_bus <= c_SPI_bus_Recessive; -- avoid conflict of multiple drivers (from two processes)
      
      while true loop
         SPI_bus.SCLK <= '0';
         wait for SCLK_period/2;
         SPI_bus.SCLK <= '1';
         wait for SCLK_period/2;
      end loop;
   end process;


   -- Stimulus process
   stim_proc: process
   variable pckt_in, pckt_out : packet;
   begin		
      -- init
      SPI_bus <= c_SPI_bus_Recessive; -- avoid conflict of multiple drivers (from two processes)
      SPI_bus.CS_b <= '1';
      wait for clk_period*10; -- wait to see falling edge of CS
      

      -- send first packet
      pckt_in.firstFrame := 4;
      pckt_in.secondFrame := 5;
      send_packet(SPI_bus,pckt_in,pckt_out, 100 ns);
      
      assert pckt_in = pckt_out
         report "Loopback is like VHDL... Broken" severity failure;
      
      -- delay
      wait for clk_period*10;
      
      -- send second frame
      pckt_in.firstFrame := 20;
      pckt_in.secondFrame := 50;
      send_packet(SPI_bus,pckt_in,pckt_out, 100 ns);

      assert pckt_in = pckt_out
         report "Loopback is like VHDL... Broken" severity failure;
      
      wait for clk_period*10;
      finish;
      wait;
   end process;

END;