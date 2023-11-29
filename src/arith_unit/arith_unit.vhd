library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity arith_unit is
    Generic(
	g_DATA_SIZE : natural := 2
	);
    Port ( clk      : in  STD_LOGIC; -- crystal clock
           we_data_fr1 : in  STD_LOGIC;
           we_data_fr2 : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);

           add_res : out  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           mul_res : out  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0)
           );
end arith_unit;

architecture Behavioral of arith_unit is
    ------------------------------
    ---------- SIGNALS -----------
    ------------------------------
    signal sig_fr1_reg_q, sig_fr2_reg_q               : STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
    signal sig_mul_res_reg_d, sig_add_res_reg_d       : STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
    signal sig_mul_res, sig_add_res                   : STD_LOGIC_VECTOR(2*g_DATA_SIZE-1 downto 0);
    signal sig_mul_res_reg_en, sig_add_res_reg_en     : std_logic;

begin

    Data_fr1_reg : entity work.n_bit_register(Behavioral)
    generic map (
        g_DATA_SIZE => g_DATA_SIZE
     )	
    port map (
      clk            => clk,
      enable_reg     => we_data_fr1,
      in_reg_d       => data_in,
      out_reg_q      => sig_fr1_reg_q
    );

    Data_fr2_reg : entity work.n_bit_register(Behavioral)
    generic map (
        g_DATA_SIZE => g_DATA_SIZE
     )	
    port map (
      clk            => clk,
      enable_reg     => we_data_fr2,
      in_reg_d       => data_in,
      out_reg_q      => sig_fr2_reg_q
    );

    Data_add_res_reg : entity work.n_bit_register(Behavioral)
    generic map (
        g_DATA_SIZE => g_DATA_SIZE
     )	
    port map (
      clk            => clk,
      enable_reg     => sig_add_res_reg_en,
      in_reg_d       => sig_add_res_reg_d,
      out_reg_q      => add_res
    );

    Data_mul_res_reg : entity work.n_bit_register(Behavioral)
    generic map (
        g_DATA_SIZE => g_DATA_SIZE
     )	
    port map (
      clk            => clk,
      enable_reg     => sig_mul_res_reg_en,
      in_reg_d       => sig_mul_res_reg_d,
      out_reg_q      => mul_res
    );
      --adder
    sig_add_res <= std_logic_vector(unsigned(sig_fr1_reg_q) + unsigned(sig_fr2_reg_q));
    sig_add_res_reg_d <= sig_add_res(g_DATA_SIZE-1 downto 0);
      --multiplier
    sig_mul_res <= std_logic_vector(signed(sig_fr1_reg_q) * signed(sig_fr2_reg_q));
    sig_mul_res_reg_d <= sig_mul_res(g_DATA_SIZE-1 downto 0);

    
                  
    -- Add more output logic as needed
  
    ------------------------------
    ---------- LOGIC -----------
    ------------------------------



end Behavioral;