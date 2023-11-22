library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity packet_control is
    Generic(
	g_DATA_SIZE : natural := 8;
    g_CLK_PERIOD_NS : natural := 20 
	);
    Port ( clk      : in  STD_LOGIC; -- crystal clock
           fr_start : in  STD_LOGIC;
           fr_end   : in  STD_LOGIC;
           fr_error : in  STD_LOGIC;
           data_in : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);

           add_res : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           mul_res : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           
           load_data : out  STD_LOGIC;
           we_data_fr1 : out  STD_LOGIC;
           we_data_fr2 : out  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0)
           );
end packet_control;

architecture Behavioral of packet_control is

    type State_Type is (await_fr1, receiving_fr1, await_fr2, receiving_fr2);
    signal current_state, next_state : State_Type;

    signal timer_reset, timer_flag : std_logic  := '0';
    ------------------------------
    ---------- SIGNALS -----------
    ------------------------------
    
        
begin

    Timer_100ms : entity work.timer(Behavioral)
    generic map (
        g_CLK_PERIOD_NS => g_CLK_PERIOD_NS,
        g_COUNT_TO_MS => 1 -- not 100 :]
     )	
    port map (
      clk       => clk,
      reset     => timer_reset,
      flag      => timer_flag
    );

    -- State Register
    process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    -- Next State Logic
    process(current_state)
    begin
        next_state <= current_state; -- default
        
        case current_state is
            when await_fr1 =>
                if(fr_start = '1') then
                    next_state <= receiving_fr1;
                end if;
            when receiving_fr1 =>
                -- Define transition logic from recieve_fr1
                timer_reset <= '1';
                if(fr_end = '1' and fr_error = '0') then
                    next_state <= await_fr2;
                    we_data_fr1 <= '1';
                elsif(fr_end = '1' and fr_error = '1') then --error
                    next_state <= await_fr1; --TODO IDK ALE AIS error state? :-c
                end if;
            when await_fr2 =>
                timer_reset <= '0';
                next_state <= receiving_fr2;
            when receiving_fr2 =>
                next_state <= await_fr1;
            when others =>
                next_state <= await_fr1;
        end case;
    end process;

    -- Output Logic
    
    -- Add more output logic as needed
  
    ------------------------------
    ---------- LOGIC -----------
    ------------------------------



end Behavioral;

