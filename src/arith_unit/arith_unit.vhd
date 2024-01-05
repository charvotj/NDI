library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity arith_unit is
    Generic(
	g_DATA_SIZE : natural := 4
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
    constant c_MAX_VAL : STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0) := '0' & (g_DATA_SIZE-2 downto 0 => '1');
    constant c_MIN_VAL : STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0) := '1' & (g_DATA_SIZE-2 downto 0 => '0');
    
    signal sig_fr1_reg_q, sig_fr2_reg_q               : STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
    signal sig_mul_res_reg_d, sig_add_res_reg_d       : STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
    signal sig_add_res                                : STD_LOGIC_VECTOR(g_DATA_SIZE+0 downto 0);
    signal sig_mul_res                                : STD_LOGIC_VECTOR(2*g_DATA_SIZE-1 downto 0);
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
    process (sig_add_res, sig_fr1_reg_q, sig_fr2_reg_q)
    begin
      sig_add_res_reg_d <= sig_add_res(g_DATA_SIZE-1 downto 0);
      
      
      -- underflow detection
      if sig_fr1_reg_q(g_DATA_SIZE-1)='1' and sig_fr2_reg_q(g_DATA_SIZE-1)='1' and sig_add_res(g_DATA_SIZE-1)='0' then
        sig_add_res_reg_d <= c_MIN_VAL;
      end if;
      -- overflow detection
      if sig_fr1_reg_q(g_DATA_SIZE-1)='0' and sig_fr2_reg_q(g_DATA_SIZE-1)='0' and sig_add_res(g_DATA_SIZE-1)='1' then
        sig_add_res_reg_d <= c_MAX_VAL;
      end if;

    end process;

    --multiplier
    process (sig_mul_res, sig_fr1_reg_q, sig_fr2_reg_q)
    begin
      sig_mul_res_reg_d <= sig_mul_res((15*g_DATA_SIZE/10)-1 downto 5*g_DATA_SIZE/10); 
      
      
      -- -- underflow detection
      -- if sig_fr1_reg_q(g_DATA_SIZE-1) /= sig_fr2_reg_q(g_DATA_SIZE-1) and sig_mul_res((15*g_DATA_SIZE/10)-1)='0' and unsigned(sig_mul_res) /= 0 then
      --   sig_mul_res_reg_d <= c_MIN_VAL;
      -- end if;
      -- -- overflow detection
      -- if sig_fr1_reg_q(g_DATA_SIZE-1) = sig_fr2_reg_q(g_DATA_SIZE-1) and (sig_mul_res((15*g_DATA_SIZE/10)-1)='1' or sig_mul_res((15*g_DATA_SIZE/10))='1') then
      --   sig_mul_res_reg_d <= c_MAX_VAL;
      -- end if;

       -- underflow detection
      if (sig_fr1_reg_q(g_DATA_SIZE-1) /= sig_fr2_reg_q(g_DATA_SIZE-1)) and (sig_mul_res(2*g_DATA_SIZE-1 downto (15*g_DATA_SIZE/10)-1) /= ((g_DATA_SIZE/2) downto 0 =>'1')) and (sig_mul_res(2*g_DATA_SIZE-1 downto (15*g_DATA_SIZE/10)-1) /= ((g_DATA_SIZE/2) downto 0 =>'0')) then --sheeesh💀
        sig_mul_res_reg_d <= c_MIN_VAL;
      end if;
      -- overflow detection
      if (sig_fr1_reg_q(g_DATA_SIZE-1) = sig_fr2_reg_q(g_DATA_SIZE-1)) and (unsigned(sig_mul_res(2*g_DATA_SIZE-1 downto (15*g_DATA_SIZE/10)-1)) > 0) then
        sig_mul_res_reg_d <= c_MAX_VAL;
      end if;

    end process;
    --ADDER
    sig_add_res <= std_logic_vector(resize(signed(sig_fr1_reg_q), g_DATA_SIZE+1) 
                                  + resize(signed(sig_fr2_reg_q), g_DATA_SIZE+1));
    --multiplier
    sig_mul_res <= std_logic_vector(signed(sig_fr1_reg_q) * signed(sig_fr2_reg_q));
    


    -- enable 
    sig_mul_res_reg_en <= we_data_fr1; 
    sig_add_res_reg_en <= '1'; 

    
                  
    -- Add more output logic as needed
  
    ------------------------------
    ---------- LOGIC -----------
    ------------------------------



end Behavioral;