library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DDF is
    port (
        in_ddf  : in std_logic;
        clk : in std_logic;
        out_ddf : out std_logic
    );
end entity;


architecture Behavioral of DDF is
signal reg_q1, reg_d1, reg_q2, reg_d2 : std_logic;

begin

    process (clk)
    begin
        if rising_edge(clk) then
            reg_q1 <= reg_d1;
            reg_q2 <= reg_d2;
        end if;
    end process;

    reg_d1 <=  in_ddf;
    reg_d2 <=  reg_q1;
    out_ddf <= reg_q2;

end architecture;