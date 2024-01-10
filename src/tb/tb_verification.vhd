-- packet je ze dvou frame

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use std.textio.all; -- Import text I/O library

package tb_verification is
    -- CONSTANTS
    constant c_DATA_SIZE : natural := 16;
    constant c_CLK_PERIOD_NS : natural := 20;
    constant c_CLK_PERIOD : time := time(c_CLK_PERIOD_NS * 1 ns);
    constant c_SCLK_PERIOD : time := 20 us;

    -- TYPES

    type packet is record
        firstFrame : real;
        secondFrame : real;
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
    procedure assert_numbers(signal SPI_bus : inout SPI_bus_t;
                             firstInput             : in real;
                             secondInput            : in real;
                             correctAdition         : in real;
                             correctMultiplication  : in real;
                             correctMultiplicationNoFloor : in real;
                             REQ_name               : in string;
                             outFileName            : in string);


    procedure send_frame(signal SPI_bus : inout SPI_bus_t;
                         data_in        : in std_logic_vector;
                         data_out       : out std_logic_vector);

   

    procedure send_packet(signal SPI_bus   : inout SPI_bus_t;
                          data_in          : in packet;
                          variable data_out: out packet;
                          delay            : in time;
                          bit_size         : in natural := c_DATA_SIZE);

    
    -- FUNCTIONS
    function real_to_vec (number : in real;
                         length : in natural
    ) return std_logic_vector;

    function vec_to_real (vector : in std_logic_vector
    ) return real;
    

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

    procedure assert_numbers(signal SPI_bus              : inout SPI_bus_t;
                            firstInput                   : in real;
                            secondInput                  : in real;
                            correctAdition               : in real;
                            correctMultiplication        : in real;
                            correctMultiplicationNoFloor : in real;
                            REQ_name                     : in string;
                            outFileName                  : in string)
        is
            variable pckt_in, pckt_out, pckt_zero : packet; 
            variable line_var : line;
            file output_file : text open APPEND_MODE is outFileName;
        begin
            pckt_zero.firstFrame := 0.0;
            pckt_zero.secondFrame := 0.0;
            
            ------------------------------------
            -------- TEST SEQUENCE BEGIN -------
            ------------------------------------
            -- send first packet
            pckt_in.firstFrame := firstInput;
            pckt_in.secondFrame := secondInput;
            send_packet(SPI_bus,pckt_in,pckt_out, 1*c_SCLK_PERIOD);
            -- get result
            wait for 2* c_SCLK_PERIOD;
            send_packet(SPI_bus,pckt_zero,pckt_out, 1*c_SCLK_PERIOD);
            -- report
            -- report "pckt_in.firstFrame:";
            -- report to_string((pckt_in.firstFrame));
            -- report "pckt_in.secondFrame:";
            case REQ_name is
                when "REQ_AAU_F_011" =>
                    report "------------------";
                    report REQ_name & ":";
                
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & ":");
                    writeline(output_file, line_var);
                    write(line_var, "For numbers:" & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8));
                    writeline(output_file, line_var);
                    write(line_var, "Add res. was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8));
                    writeline(output_file, line_var);
                    write(line_var, "Mul res. was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) & ",No floor: " & to_string(correctMultiplicationNoFloor,8));
                    writeline(output_file, line_var);
                when "REQ_AAU_F_012" =>
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & ":");
                    writeline(output_file, line_var);
                    write(line_var, "For numbers:" & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8));
                    writeline(output_file, line_var);
                    write(line_var, "Add res. was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8));
                    writeline(output_file, line_var);
                    write(line_var, "Mul res. was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) & ",No floor: " & to_string(correctMultiplicationNoFloor,8));
                    writeline(output_file, line_var);
                when others =>
                    -- Handle undefined action
            end case;

            -- report "pckt_out.firstFrame:";
            -- report to_string((pckt_out.firstFrame));
            -- report "pckt_out.secondFrame:";
            -- report to_string((pckt_out.secondFrame));

            -- assert sumation
            assert to_string(pckt_out.firstFrame,4) = to_string(correctAdition,4) -- nerovna se assert
                report "For numbers:" & to_string(pckt_in.firstFrame,4) & " and " & to_string(pckt_in.secondFrame,4) & " addition result was: " & to_string(pckt_out.firstFrame,4) & ", Should be: " & to_string(correctAdition,4) severity warning;
            -- assert multiplication
            assert to_string(pckt_out.secondFrame,4) = to_string(correctMultiplication,4) -- nerovna se assert
                report "For numbers " & to_string(pckt_in.firstFrame,4) & " and " & to_string(pckt_in.secondFrame,4) & " multiplication result was: " & to_string(pckt_out.secondFrame,4) & ", Should be: " & to_string(correctMultiplication,4) severity warning;
        end procedure;

    procedure send_frame(signal SPI_bus : inout SPI_bus_t;
                         data_in : in std_logic_vector;
                         data_out : out std_logic_vector) 
        is
        begin
            -- report to log
            -- report "sending report";
            -- report "data_in:";
            -- report to_string(unsigned(data_in));
            -- report "data_out:";
            -- report to_string(unsigned(data_out));
            -- -- code
            SPI_bus.CS_b <= '0';
            for i in 0 to (data_in'length-1) loop
                --posilani  
                wait until falling_edge(SPI_bus.SCLK);
                SPI_bus.MOSI <= data_in(i);
                --cteni
                wait until rising_edge(SPI_bus.SCLK);
                data_out(i) := SPI_bus.MISO;
                -- report "MISO:" & to_string(SPI_bus.MISO);

            end loop;

            -- wait until falling_edge(SPI_bus.SCLK);
            wait for c_SCLK_PERIOD * 0.25;
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
                send_frame(SPI_bus,real_to_vec(data_in.firstFrame, bit_size),fr1_vec);
                wait for delay;
                send_frame(SPI_bus,real_to_vec(data_in.secondFrame, bit_size), fr2_vec);

                data_out.firstFrame := vec_to_real(fr1_vec);
                data_out.secondFrame := vec_to_real(fr2_vec);

            end procedure;


    

    --Trosku useless, ale nevadí c-: uz se napsala...
    function real_to_vec (number : in real;
                        length  : in natural
    ) return std_logic_vector is
    begin
        return std_logic_vector(to_signed(integer(number * 2.0 ** (length/2)),length));
    end function;

    --Trosku useless, ale nevadí c-: uz se napsala...
    function vec_to_real (vector : in std_logic_vector
    ) return real is
    begin
        -- report "DEBUG: vec_to_real func:" & to_string(unsigned(vector));
        return real(to_integer(signed(vector)))/ 2.0 ** (vector'length/2);
    end function;

end tb_verification;