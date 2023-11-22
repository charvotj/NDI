LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.math_real.all;
-- Define the entity
entity Timer is
    Generic(
        g_CLK_PERIOD_NS : natural := 20;
        g_COUNT_TO_MS : natural := 100
        );
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           flag : out STD_LOGIC);
end Timer;

-- Define the architecture
architecture Behavioral of Timer is
    
    constant COUNT_TO_NUMBER : natural := (g_COUNT_TO_MS*1000000 / g_CLK_PERIOD_NS); -- 100ms count
    --  constant COUNT_TO_NUMBER : natural := 8; -- for testing schematic
    
    -- Define a signals for the counter
    signal cnt_d, cnt_q : unsigned(integer(ceil(log2(real(COUNT_TO_NUMBER)))) downto 0) := (others => '0');

begin
        --TODO Pridat enable
    process(clk, reset)
    begin
        if reset = '1' then
            cnt_q <= (others => '0');  -- Reset the counter
            flag <= '0';               -- Lower the flag on reset
        elsif rising_edge(clk) then
            if cnt_q < COUNT_TO_NUMBER then
                cnt_q <= cnt_d; -- Increment the counter
            else
                cnt_q <= (others => '0');          -- Reset the counter
                flag <= '1';           -- Raise the flag
            end if;
        end if;
    end process;

    cnt_d <= cnt_q + 1;

end Behavioral;