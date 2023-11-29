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
    signal current_state, next_state : State_Type := await_fr1;
    
    signal timer_reset, timer_flag : std_logic  := '0';
    ------------------------------
    ---------- SIGNALS -----------
    ------------------------------
    
        
begin

    Timer_1ms : entity work.timer(Behavioral)
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
    process(fr_start,fr_end,timer_flag,fr_error,current_state)
    begin
        next_state <= current_state; -- default
        
        -- initial values
        we_data_fr1 <= '0';
        we_data_fr2 <= '0';
        load_data   <= '0';
        timer_reset <= '1';
        data_out    <= (others => '0');

        case current_state is
            when await_fr1 =>
                if(fr_start = '1') then
                    next_state <= receiving_fr1;
                    data_out <= add_res; -- TODO asi takto
                    load_data <= '1';    -- TODO asi takto
                end if;
            when receiving_fr1 =>
                -- Define transition logic from recieve_fr1
                --timer_reset <= '1';
                load_data <= '0'; -- TODO asi takto
                if(fr_end = '1') then
                    if(fr_error = '0') then
                        next_state <= await_fr2;
                        we_data_fr1 <= '1'; -- propagujeme data dale
                    else  --error
                        next_state <= await_fr1;
                    end if;
                end if;
            when await_fr2 =>
                timer_reset <= '0';
                we_data_fr1 <= '0';
                if(timer_flag = '1') then
                    next_state <= await_fr1; -- REQ_AAU_I_023, Rev. 1
                elsif(fr_start = '1') then
                    next_state <= receiving_fr2;
                    data_out <= mul_res; -- TODO asi takto
                    load_data <= '1';    -- TODO asi takto
                end if;
            when receiving_fr2 =>
                load_data <= '0'; -- TODO asi takto
                if(fr_end = '1') then
                    if(fr_error = '0') then
                        we_data_fr2 <= '1'; -- propagujeme data dale
                    end if;
                        next_state <= await_fr1;
                end if;
            when others =>
                next_state <= await_fr1;
        end case;
    end process;
    
                  
    -- Add more output logic as needed
  
    ------------------------------
    ---------- LOGIC -----------
    ------------------------------



end Behavioral;

