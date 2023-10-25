library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI is
    Generic(
	g_DATA_SIZE : natural := 8
	);
    Port ( clk  : in  STD_LOGIC; -- crystal clock
           CS_b : in  STD_LOGIC;
           SCLK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           load_data : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           MISO : out  STD_LOGIC;
           fr_start : out  STD_LOGIC;
           fr_end : out  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0)
           );
end SPI;

architecture Behavioral of SPI is

    ------------------------------
    ---------- SIGNALS -----------
    ------------------------------
    signal CS_b_DDF_signal  : std_logic;    
    signal SCLK_DDF_signal  : std_logic;
    signal MOSI_DDF_signal  : std_logic;
    signal CS_b_edge_r_out  : std_logic;
    signal CS_b_edge_f_out  : std_logic;
    signal SCLK_edge_r_out  : std_logic;
    signal SCLK_edge_f_out  : std_logic;
    signal ser_shift_en     : std_logic;
    signal deser_shift_en   : std_logic;
        
begin

  CS_b_ed : entity work.edge_detector(Behavioral)
    port map (
      sig_in     => CS_b_DDF_signal,
      clk        => clk,
      edge_r_out => CS_b_edge_r_out,
      edge_f_out => CS_b_edge_f_out
    );

  SCLK_ed : entity work.edge_detector(Behavioral)
  port map (
          sig_in     => SCLK_DDF_signal,
          clk        => clk,
          edge_r_out => SCLK_edge_r_out,
          edge_f_out => SCLK_edge_f_out
      );

  Serializer : entity work.ser (Behavioral)
    generic map (
       g_DATA_SIZE => g_DATA_SIZE
    )	
    port map (
        data => data_in,
        load_en => load_data,
        shift_en => ser_shift_en ,
        rst => '0',
        clk => clk,
        stream => MISO
    );
    

    Deserializer : entity work.deser (Behavioral)
    generic map (
       g_DATA_SIZE => g_DATA_SIZE
    )	
    port map (
        data => data_out,
        shift_en => deser_shift_en,
        rst => '0',
        clk => clk,
        stream => MOSI_DDF_signal
    );

    CS_b_DDF : entity work.DDF (Behavioral)
        port map (
            in_ddf => CS_b,
            clk => clk,
            out_ddf => CS_b_DDF_signal
        );

    SCLK_DDF : entity work.DDF(Behavioral)
        port map (
            in_ddf => SCLK,
            clk => clk,
            out_ddf => SCLK_DDF_signal
        );

    MOSI_DDF : entity work.DDF(Behavioral)
        port map (
            in_ddf => MOSI,
            clk => clk,
            out_ddf => MOSI_DDF_signal
        );


        
    ------------------------------
    ---------- LOGIC -----------
    ------------------------------
ser_shift_en <= SCLK_edge_f_out and not CS_b;
deser_shift_en <= SCLK_edge_r_out and not CS_b;


end Behavioral;

