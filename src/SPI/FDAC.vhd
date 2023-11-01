library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity FDAC is
    Generic(
        g_DATA_SIZE : natural := 2
        );
    Port ( clk      :in STD_LOGIC;
           CS_b_re  : in  STD_LOGIC;
           CS_b_fe  : in  STD_LOGIC;
           SCLK_re  : in  STD_LOGIC;
           fr_end   : out  STD_LOGIC;
           fr_start : out  STD_LOGIC;
           fr_error : out  STD_LOGIC);
end FDAC;

architecture Behavioral of FDAC is
    signal cnt_d, cnt_q : unsigned(integer(ceil(log2(real(g_DATA_SIZE)))) downto 0) := (others => '0');
    signal fr_error_s : STD_LOGIC :='0';
begin

    fr_start <= CS_b_fe;  
    fr_end   <= CS_b_re;


    process (clk)
    begin
      if rising_edge(clk) then
        if (CS_b_fe = '1') then
            cnt_q <= (others => '0');
        elsif (SCLK_re = '1' and fr_error_s = '0') then
            cnt_q <= cnt_d;
        end if;
      end if;
    end process;
  
    cnt_d <= cnt_q + 1;
    
    fr_error_s <= '1' when cnt_q = g_DATA_SIZE else '0';
    fr_error <= fr_error_s;
    
end architecture;

--------------------------------------------------------------------------------------------
--entity counter is -- nazev entity
--    port (
--      clk, rst : in std_logic;
--      CE : in std_logic;
--      --max : out std_logic;
--      led : out std_logic_vector (7 downto 0)
--    );
--  end counter;
--  
--  architecture Behavioral of counter is
--    signal count_d, count_q : unsigned(7 downto 0) := (others => '0');
--    --constant max_val : unsigned(7 downto 0) := "11111111";
--  
--  begin
--  
--    process (clk)
--    begin
--      if rising_edge(clk) then
--        if (rst = '1') then
--          count_q <= (others => '0');
--        elsif (CE = '1') then
--          count_q <= count_d;
--        end if;
--      end if;
--    end process;
--  
--    count_d <= count_q + 1;
--    --max <= '1' when count_d = max_val else '0';
--    led <= std_logic_vector(count_q);