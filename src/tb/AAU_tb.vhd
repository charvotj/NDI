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
   variable pckt_in, pckt_out, pckt_zero : packet;
   begin		
      -- init
      SPI_bus <= c_SPI_bus_Recessive; -- avoid conflict of multiple drivers (from two processes)
      SPI_bus.CS_b <= '1';
      wait for c_SCLK_PERIOD*4; -- wait to see falling edge of CS
      
      pckt_zero.firstFrame := 0;
      pckt_zero.secondFrame := 0;
      
      ------------------------------------
      -------- TEST SEQUENCE BEGIN -------
      ------------------------------------
      -- send first packet
      pckt_in.firstFrame := 3;
      pckt_in.secondFrame := 3;
      send_packet(SPI_bus,pckt_in,pckt_out, 0.75*c_SCLK_PERIOD);
      -- get result
      wait for 2* c_SCLK_PERIOD;
      send_packet(SPI_bus,pckt_zero,pckt_out, 0.75*c_SCLK_PERIOD);
      -- report
      report "pckt_in.firstFrame:";
      report to_string((pckt_in.firstFrame));
      report "pckt_in.secondFrame:";
      report to_string((pckt_in.secondFrame));
      
      report "pckt_out.firstFrame:";
      report to_string((pckt_out.firstFrame));
      report "pckt_out.secondFrame:";
      report to_string((pckt_out.secondFrame));

      -- assert sumation
      assert pckt_out.firstFrame = pckt_in.firstFrame + pckt_in.secondFrame -- nerovna se assert
         report "Results was: " & to_string(pckt_out.firstFrame) & ", Should be: " & to_string(pckt_in.firstFrame + pckt_in.secondFrame) severity failure;
      -- assert multiplication
      assert pckt_out.firstFrame = pckt_in.firstFrame * pckt_in.secondFrame -- nerovna se assert
         report "Results was: " & to_string(pckt_out.firstFrame) & ", Should be: " & to_string(pckt_in.firstFrame * pckt_in.secondFrame) severity failure;

      
      wait for c_CLK_PERIOD*10;
      finish;
      wait;
   end process;

END;
