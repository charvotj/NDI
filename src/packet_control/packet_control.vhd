library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity packet_control is
    Generic(
	g_DATA_SIZE : natural := 8;
    g_CLK_PERIOD_NS : natural := 20 
	);
    Port ( clk      : in  STD_LOGIC; -- crystal clock
           rst      : in  STD_LOGIC;
           fr_start : in  STD_LOGIC;
           fr_end   : in  STD_LOGIC;
           fr_error : in  STD_LOGIC;

           add_res : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           mul_res : in  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           
           load_data : out  STD_LOGIC;
           we_data_fr1 : out  STD_LOGIC;
           we_data_fr2 : out  STD_LOGIC;
           data_out : out  STD_LOGIC_VECTOR(g_DATA_SIZE-1 downto 0);
           arith_rst : out STD_LOGIC
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
            if rst = '1' then
                current_state <= await_fr1;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;

    -- Next State Logic
    process(fr_start,fr_end,timer_flag,fr_error,current_state, add_res, mul_res)
    begin
        next_state <= current_state; -- default
        
        -- initial values
        we_data_fr1 <= '0';
        we_data_fr2 <= '0';
        load_data   <= '0';
        timer_reset <= '1';
        data_out    <= add_res; --ad_res on output of a multiplex
        arith_rst <= '0';

        case current_state is
            -- STATE CHANGE
            when await_fr1 =>
                if(fr_start = '1') then
                    next_state <= receiving_fr1;
                    data_out <= add_res; 
                    load_data <= '1';    
                end if;
            when receiving_fr1 =>
                -- Define transition logic from recieve_fr1
                --timer_reset <= '1';
                if(fr_end = '1') then
                    if(fr_error = '0') then
                        next_state <= await_fr2;
                        we_data_fr1 <= '1'; -- propagujeme data dale
                    else  --error
                        next_state <= await_fr1;
                    end if;
                end if;
            -- STATE CHANGE
            when await_fr2 =>
                timer_reset <= '0';
                --we_data_fr1 <= '0';
                if(timer_flag = '1') then
                    arith_rst <= '1';
                    next_state <= await_fr1; -- REQ_AAU_I_023, Rev. 1
                elsif(fr_start = '1') then
                    next_state <= receiving_fr2;
                    data_out <= mul_res; 
                    load_data <= '1';    
                end if;
            -- STATE CHANGE
            when receiving_fr2 =>
                load_data <= '0'; 
                if(fr_end = '1') then
                    if(fr_error = '0') then
                        we_data_fr2 <= '1'; -- propagujeme data dale
                    else
                        arith_rst <= '1';
                    end if;
                        next_state <= await_fr1;
                end if;
            -- STATE CHANGE
            when others =>
                next_state <= await_fr1;
        end case;
    end process;
    
                  
    -- Add more output logic as needed
  
    ------------------------------
    ---------- LOGIC -----------
    ------------------------------



end Behavioral;

