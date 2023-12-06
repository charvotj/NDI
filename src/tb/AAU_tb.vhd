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
   


BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: entity work.AAU(Behavioral)
      generic map (
        g_DATA_SIZE => g_DATA_SIZE,
        g_CLK_PERIOD_NS => c_CLK_PERIOD_NS
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
		wait for c_CLK_PERIOD/2;
		clk <= '1';
		wait for c_CLK_PERIOD/2;
   end process;

   
   --VELKY SPATNY :_C sad
   SCLK_process :process
   begin
      SPI_bus <= c_SPI_bus_Recessive; -- avoid conflict of multiple drivers (from two processes)
      
      while true loop
         SPI_bus.SCLK <= '0';
         wait for c_SCLK_PERIOD/2;
         SPI_bus.SCLK <= '1';
         wait for c_SCLK_PERIOD/2;
      end loop;
   end process;


   -- Stimulus process
   stim_proc: process
   variable pckt_in, pckt_out : packet;
   begin		
      -- init
      SPI_bus <= c_SPI_bus_Recessive; -- avoid conflict of multiple drivers (from two processes)
      SPI_bus.CS_b <= '1';
      wait for c_SCLK_PERIOD*4; -- wait to see falling edge of CS
      

      -- send first packet
      pckt_in.firstFrame := 8; -- 0xAAAA
      pckt_in.secondFrame := 9;
      send_packet(SPI_bus,pckt_in,pckt_out, 0.75*c_SCLK_PERIOD);

      wait for 2* c_SCLK_PERIOD;

      -- send first packet
      pckt_in.firstFrame := 6; -- 0xAAAA
      pckt_in.secondFrame := 8;
      send_packet(SPI_bus,pckt_in,pckt_out, 1* c_SCLK_PERIOD);
      
      wait for 20* c_SCLK_PERIOD;
      -- pckt_in.firstFrame := 21;
      -- pckt_in.secondFrame := 51;
      -- send_packet(SPI_bus,pckt_in,pckt_out, 80 ns);

      report "pckt_in.firstFrame:";
      report to_string((pckt_in.firstFrame));
      report "pckt_out.secondFrame:";
      report to_string((pckt_out.secondFrame));
      assert pckt_in.firstFrame = pckt_out.secondFrame
         report "Loopback is like VHDL... Broken" severity failure;
      
      -- delay
      wait for c_CLK_PERIOD*20;
      
      -- -- send second frame
      -- pckt_in.firstFrame := 21;
      -- pckt_in.secondFrame := 51;
      send_packet(SPI_bus,pckt_in,pckt_out, 80 ns);


      assert pckt_in.firstFrame = pckt_out.secondFrame
         report "Loopback is like VHDL... Broken" severity failure;
      
      wait for c_CLK_PERIOD*10;
      finish;
      wait;
   end process;

END;
