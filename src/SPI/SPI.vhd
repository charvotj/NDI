library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity SPI is
    Generic(
	g_DATA_SIZE : natural := 8
	);
    Port ( clk  : in  STD_LOGIC; -- crystal clock
           rst  : in STD_LOGIC;
           CS_b : in  STD_LOGIC;
           SCLK : in  STD_LOGIC;
           MOSI : in  STD_LOGIC;
           load_data : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           MISO : out  STD_LOGIC;
           fr_start : out  STD_LOGIC;
           fr_end : out  STD_LOGIC;
           fr_error : out  STD_LOGIC;
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
        shift_en => ser_shift_en,
        rst => rst,
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
        rst => rst,
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

    Frame_check : entity work.FDAC(Behavioral)
    generic map (
        g_DATA_SIZE => g_DATA_SIZE
     )
     Port map ( 
            clk      =>  clk,
            CS_b     => CS_b_DDF_signal,
            CS_b_re  =>  CS_b_edge_r_out,
            CS_b_fe  =>  CS_b_edge_f_out,
            SCLK_re  =>  SCLK_edge_r_out,
            fr_end   =>  fr_end,
            fr_start =>  fr_start,
            fr_error =>  fr_error
     );       
        
    ------------------------------
    ---------- LOGIC -----------
    ------------------------------
ser_shift_en <= SCLK_edge_f_out and not CS_b_DDF_signal;
deser_shift_en <= SCLK_edge_r_out and not CS_b_DDF_signal;


end Behavioral;

