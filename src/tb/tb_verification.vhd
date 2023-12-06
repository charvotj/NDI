-- packet je ze dvou frame

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

package tb_verification is
    -- CONSTANTS
    constant c_DATA_SIZE : natural := 4;
    constant c_CLK_PERIOD_NS : natural := 20;
    constant c_CLK_PERIOD : time := time(c_CLK_PERIOD_NS * 1 ns);
    constant c_SCLK_PERIOD : time := 20 us;

    -- TYPES

    type packet is record
        firstFrame : natural;
        secondFrame : natural;
    end record;

    type SPI_bus_t is record
        SCLK : std_logic   ;
        MOSI : std_logic   ;
        MISO : std_logic   ;
        CS_b   : std_logic ;
    end record;
    -- Recessive values for resolution function
    constant c_SPI_bus_Recessive : SPI_bus_t := (
        SCLK    => 'Z',
        MOSI    => 'Z',
        MISO    => 'Z',        
        CS_b    => 'Z'
    );
    
    -- PROCEDURES
    -- procedure send_serial(signal clk : in std_logic;
    --                       signal serial_out : out std_logic;
    --                       data_len : in natural;
    --                       data : in natural;
    --                       r_edge : in std_logic);

    procedure send_frame(signal SPI_bus : inout SPI_bus_t;
                         data_in        : in std_logic_vector;
                         data_out       : out std_logic_vector);

   

    procedure send_packet(signal SPI_bus   : inout SPI_bus_t;
                          data_in          : in packet;
                          variable data_out: out packet;
                          delay            : in time;
                          bit_size         : in natural := c_DATA_SIZE);

    
    -- FUNCTIONS
    function nat_to_vec (number : in natural;
                         length : in natural
    ) return std_logic_vector;

    function vec_to_nat (vector : in std_logic_vector
    ) return natural;
    

end tb_verification;

package body tb_verification is
    
    -- procedure send_serial(signal clk : in std_logic;
    --                       signal serial_out : out std_logic;
    --                       data_len : in natural;
    --                       data : in  natural;
    --                       r_edge : in std_logic) -- '1': rising edge, '0': falling edge
    --     is
    --         variable data_vector : std_logic_vector(data_len-1 downto 0) := std_logic_vector(to_unsigned(data,data_len));
    --     begin
    --         for i in 0 to data_len-1 loop
    --         if (r_edge = '1') then
    --         wait until rising_edge(clk);
    --         else
    --         wait until falling_edge(clk);
    --         end if;
    --         serial_out <= data_vector(i);
    --         end loop;
    -- end procedure send_serial;

    procedure send_frame(signal SPI_bus : inout SPI_bus_t;
                         data_in : in std_logic_vector;
                         data_out : out std_logic_vector) 
        is
        begin
            -- report to log
            report "sending report";
            report "data_in:";
            report to_string(unsigned(data_in));
            report "data_out:";
            report to_string(unsigned(data_out));
            -- code
            SPI_bus.CS_b <= '0';
            for i in 0 to (data_in'length-1) loop
                --posilani  
                wait until falling_edge(SPI_bus.SCLK);
                SPI_bus.MOSI <= data_in(i);
                --cteni
                wait until rising_edge(SPI_bus.SCLK);
                data_out(i) := SPI_bus.MISO;

            end loop;

            wait until falling_edge(SPI_bus.SCLK);
            SPI_bus.CS_b <= '1';
        end procedure;


    procedure send_packet(signal SPI_bus : inout SPI_bus_t;
                          data_in : in packet;
                          variable data_out : out packet;
                          delay: in time;
                          bit_size : in natural := c_DATA_SIZE)
            is
                variable fr1_vec, fr2_vec : std_logic_vector(bit_size-1 downto 0) := (others => '0');
            begin
                wait until rising_edge(SPI_bus.SCLK);
                wait for 0.25 * c_SCLK_PERIOD;
                send_frame(SPI_bus,nat_to_vec(data_in.firstFrame, bit_size),fr1_vec);
                wait for delay;
                send_frame(SPI_bus,nat_to_vec(data_in.secondFrame, bit_size), fr2_vec);

                data_out.secondFrame := vec_to_nat(fr1_vec);
                data_out.secondFrame := vec_to_nat(fr2_vec);

            end procedure;


    

    --Trosku useless, ale nevadí c-: uz se napsala...
    function nat_to_vec (number : in natural;
                        length  : in natural
    ) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(number,length));
    end function;

    --Trosku useless, ale nevadí c-: uz se napsala...
    function vec_to_nat (vector : in std_logic_vector
    ) return natural is
    begin
        return to_integer(unsigned(vector));
    end function;

end tb_verification;