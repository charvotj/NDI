library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity n_bit_register is
    Generic(
        g_DATA_SIZE : natural := 2
        );
    Port ( clk        : in STD_LOGIC;
           rst : in STD_LOGIC;
           enable_reg : in STD_LOGIC;
           in_reg_d   : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           out_reg_q  : out  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0) 
    );

end n_bit_register;

architecture Behavioral of n_bit_register is 
    signal reg_d, reg_q : STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0) := (others => '0');
begin

    process (clk)
    begin
        if rising_edge(clk) then 
            if rst = '1' then
                reg_q <= (others => '0');
            else
                if (enable_reg = '1') then
                    reg_q <= reg_d; 
                end if;
            end if;
        end if;
    end process;
    reg_d <= in_reg_d;
    out_reg_q <= reg_q;

end architecture;
