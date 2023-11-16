library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AAU is
    Generic(
            g_DATA_SIZE : natural := 2
        );

    Port(  clk  :in STD_LOGIC;
           SCLK : in  STD_LOGIC;
           CS_b : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           MISO : out  STD_LOGIC
         );
end AAU;

architecture Behavioral of AAU is
    ------------------------------
    ---------- SIGNALS -----------
    ------------------------------
    signal sig_load_data, sig_fr_start, sig_fr_end, sig_fr_error : std_logic;
    signal sig_data_in, sig_data_out : STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
    
    signal fr_error_s : STD_LOGIC :='0';
begin
    SPI: entity work.SPI(Behavioral)
      generic map (
        g_DATA_SIZE => g_DATA_SIZE
        )	
      PORT MAP (
          clk => clk,
          CS_b => CS_b,
          SCLK => SCLK,
          MOSI => MOSI,
          load_data => sig_load_data,
          data_in => sig_data_in,
          MISO => MISO,
          fr_start => sig_fr_start,
          fr_end => sig_fr_end,
          fr_error => sig_fr_error,
          data_out => sig_data_in --sig_data_out - original, sig_data_in -loopback
        );

        -- for loopback:
          sig_load_data <= sig_fr_end;
   
end architecture;
