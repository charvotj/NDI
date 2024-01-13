LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use std.env.finish;
USE ieee.numeric_std.ALL;
use work.tb_verification.all;
use std.textio.all; -- Import text I/O library

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
      variable input_line                    : line;
      variable output_line                   : line; 
      variable firstInput                    : real;
      variable secondInput                   : real;
      variable correctAdition                : real;
      variable correctMultiplication         : real;
      variable correctMultiplicationNoFloor  : real;
      variable temp_char                     : character;
      variable my_real                       : real;
      variable req_name                      : string(1 to 13) := "NOT_REQ_TEST_";
      file input_file                        : text;
      file output_file                       : text;
      -- Simulation settings -- need to calculate length of the path ... 
      -- retarded definition ... "type STRING is array (POSITIVE range <>) of CHARACTER;"
      -- variable abs_path        : string(1 to 23) := "/home/radek/NDI/src/tb/";
      variable abs_path        : string(1 to 38) := "/home/jakub/Plocha/NDI/Projekt/src/tb/";
   begin	
      -- init
      SPI_bus <= c_SPI_bus_Recessive; -- avoid conflict of multiple drivers (from two processes)
      SPI_bus.CS_b <= '1';
      wait for c_SCLK_PERIOD*4; -- wait to see falling edge of CS

      -------------------------------------------------
      ---------- NUMBER FORMAT TEST -------------------
      -------------------------------------------------
      file_open(input_file, abs_path & "number_format_test.txt", READ_MODE);
      file_open(output_file, abs_path & "logs/number_format_test.log", WRITE_MODE);
      while not endfile(input_file) loop
         -- Read a line from the input file
         readline(input_file, input_line );
         req_name := input_line.all;
         readline(input_file, input_line );
         firstInput := real'value(input_line.all);
         readline(input_file, input_line );
         secondInput := real'value(input_line.all);
         readline(input_file, input_line );
         correctAdition := real'value(input_line.all);
         readline(input_file, input_line );
         correctMultiplication := real'value(input_line.all);
         readline(input_file, input_line );
         correctMultiplicationNoFloor := real'value(input_line.all);

         assert_numbers(SPI_bus,firstInput, secondInput, correctAdition, correctMultiplication, correctMultiplicationNoFloor, req_name, abs_path & "logs/number_format_test.log");

      end loop;
      file_close(input_file);
      file_close(output_file);

      wait for c_CLK_PERIOD*10;
      finish;
   end process;

END;

