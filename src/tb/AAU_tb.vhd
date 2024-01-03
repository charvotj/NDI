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
   
   begin		
      -- init
      SPI_bus <= c_SPI_bus_Recessive; -- avoid conflict of multiple drivers (from two processes)
      SPI_bus.CS_b <= '1';
      wait for c_SCLK_PERIOD*4; -- wait to see falling edge of CS
      

      assert_numbers(SPI_bus,1.0,1.0,2.0,1.0);
      

      
      wait for c_CLK_PERIOD*10;
      finish;
      wait;
   end process;

END;



-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.NUMERIC_STD.ALL;

-- entity RealToFixedPoint is
-- end RealToFixedPoint;

-- architecture Behavioral of RealToFixedPoint is
--     -- Example: 16-bit fixed point, 8 bits for integer, 8 bits for fractional part
--     constant Integer_Bits: integer := 8;
--     constant Fractional_Bits: integer := 8;
--     constant Scale_Factor: real := 2.0 ** Fractional_Bits;
--     signal Real_Value: real := -123.456;  -- Example real value
--     signal Fixed_Point_Value: signed(Integer_Bits + Fractional_Bits - 1 downto 0);
-- begin
--     process(Real_Value)
--     begin
--         -- Scale and convert to integer
--         -- Note: Rounding can be added as required
--         if Real_Value < 0.0 then
--             -- Negative number: scale, convert, and take two's complement
--             Fixed_Point_Value <= to_signed(-1 * integer(round(Scale_Factor * Real_Value)), Integer_Bits + Fractional_Bits);
--         else
--             -- Positive number: scale and convert
--             Fixed_Point_Value <= to_signed(integer(round(Scale_Factor * Real_Value)), Integer_Bits + Fractional_Bits);
--         end if;
--     end process;
-- end Behavioral;


-- library IEEE;
-- use IEEE.STD_LOGIC_1164.ALL;
-- use IEEE.NUMERIC_STD.ALL;

-- -- Function to convert real to 8-bit fixed point
-- function real_to_fixed8(value: real) return std_logic_vector is
--     constant fractional_bits : integer := 4;
--     constant scale_factor : real := 2.0 ** fractional_bits;  -- 2^4 for 4 fractional bits
--     variable scaled_value : real;
--     variable integer_value : integer;
-- begin
--     -- Scale and round the real value
--     scaled_value := value * scale_factor;

--     -- Convert to integer (with rounding)
--     if scaled_value >= 0.0 then
--         integer_value := integer(scaled_value + 0.5);  -- Rounding
--     else
--         integer_value := integer(scaled_value - 0.5);  -- Rounding
--     end if;

--     -- Handle negative values for two's complement
--     if integer_value < 0 then
--         return std_logic_vector(to_unsigned(256 + integer_value, 8));  -- 256 is 2^8, to offset the negative value
--     else
--         return std_logic_vector(to_unsigned(integer_value, 8));
--     end if;
-- end function;

-- -- Example usage in an architecture or testbench
-- -- fixed_value <= real_to_fixed8(my_real_input);