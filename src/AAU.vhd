library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AAU is
    Generic(
            g_DATA_SIZE : natural := 16;
            g_CLK_PERIOD_NS : natural := 20
        );

    Port(  clk  :in STD_LOGIC;
           rst  : in STD_LOGIC;
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
    signal sig_load_data, sig_fr_start, sig_fr_end, sig_fr_error, sig_load_fr1, sig_load_fr2 : std_logic;
    signal sig_spi_data_in, sig_spi_data_out, sig_add_res, sig_mul_res : STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
    signal sig_pktctrl_rst_arith, sig_arith_rst : std_logic;
begin
    SPI: entity work.SPI(Behavioral)
      generic map (
        g_DATA_SIZE => g_DATA_SIZE
        )	
      PORT MAP (
          clk => clk,
          rst => rst,
          CS_b => CS_b,
          SCLK => SCLK,
          MOSI => MOSI,
          load_data => sig_load_data,
          data_in => sig_spi_data_in,
          MISO => MISO,
          fr_start => sig_fr_start,
          fr_end => sig_fr_end,
          fr_error => sig_fr_error,
          data_out => sig_spi_data_out
        );

    Packet_control: entity work.packet_control(Behavioral)
        generic map(
            g_DATA_SIZE => g_DATA_SIZE,
            g_CLK_PERIOD_NS => g_CLK_PERIOD_NS
          )
        Port map ( 
               clk      => clk,
               rst      => rst,
               fr_start => sig_fr_start,
               fr_end   => sig_fr_end,
               fr_error => sig_fr_error,
    
               add_res => sig_add_res,
               mul_res => sig_mul_res,
               
               load_data => sig_load_data,
               we_data_fr1 => sig_load_fr1,
               we_data_fr2 => sig_load_fr2,
               data_out => sig_spi_data_in,
               arith_rst => sig_pktctrl_rst_arith
               );

    Arith_unit: entity work.arith_unit(Behavioral)
        generic map(
              g_DATA_SIZE => g_DATA_SIZE
              )
        Port map ( 
               clk      => clk,
               rst      => sig_arith_rst,
               we_data_fr1 => sig_load_fr1,
               we_data_fr2 => sig_load_fr2,
               data_in  => sig_spi_data_out,
    
               add_res => sig_add_res,
               mul_res => sig_mul_res
               );

              sig_arith_rst <= rst or sig_pktctrl_rst_arith;
end architecture;
