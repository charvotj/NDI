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
    constant c_SCLK_PERIOD : time := 1 us;

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
                             correctAditionNoFloor  : in real;
                             correctMultiplication  : in real;
                             correctMultiplicationNoFloor : in real;
                             REQ_name               : in string;
                             outFileName            : in string;
                             SCLK_period            : in time := c_SCLK_PERIOD;
                             delay                        : in time := c_SCLK_PERIOD;
                             bit_size                     : in natural := c_DATA_SIZE;
                             bit_size_2                   : in natural := c_DATA_SIZE
                             );


    procedure send_frame(signal SPI_bus : inout SPI_bus_t;
                         data_in        : in std_logic_vector;
                         data_out       : out std_logic_vector;
                         SCLK_period            : in time);

   

    procedure send_packet(signal SPI_bus   : inout SPI_bus_t;
                          data_in          : in packet;
                          variable data_out: out packet;
                          delay            : in time;
                          bit_size         : in natural := c_DATA_SIZE;
                          bit_size_2 : in natural := c_DATA_SIZE;
                          SCLK_period            : in time);

    
    -- FUNCTIONS
    function real_to_vec (number : in real;
                         length : in natural
    ) return std_logic_vector;

    function vec_to_real (vector : in std_logic_vector
    ) return real;
    
    -- function to_string(r : real; decimal_places : natural) return string;

end tb_verification;

package body tb_verification is
    
    procedure assert_numbers(signal SPI_bus              : inout SPI_bus_t;
                            firstInput                   : in real;
                            secondInput                  : in real;
                            correctAdition               : in real;
                            correctAditionNoFloor        : in real;
                            correctMultiplication        : in real;
                            correctMultiplicationNoFloor : in real;
                            REQ_name                     : in string;
                            outFileName                  : in string;
                            SCLK_period                  : in time := c_SCLK_PERIOD;
                            delay                        : in time := c_SCLK_PERIOD;
                            bit_size                     : in natural := c_DATA_SIZE;
                            bit_size_2                   : in natural := c_DATA_SIZE
                            )
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
            send_packet(SPI_bus,pckt_in,pckt_out, delay, bit_size, bit_size_2, SCLK_period);
            -- get result
            wait for 2*SCLK_period;
            send_packet(SPI_bus,pckt_zero,pckt_out, c_SCLK_PERIOD, c_DATA_SIZE, c_DATA_SIZE, SCLK_period);
            -- report
            -- report "pckt_in.firstFrame:";
            -- report to_string((pckt_in.firstFrame));
            -- report "pckt_in.secondFrame:";
            case REQ_name is
                -- FUNCTIONAL REQUIREMENTS
                when "REQ_AAU_F_011" =>
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & ":");
                    writeline(output_file, line_var);
                    write(line_var, "For numbers:  " & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8));
                    writeline(output_file, line_var);
                    write(line_var, "In binary:  " & to_string(unsigned(real_to_vec(pckt_in.firstFrame, bit_size))) & " and " & to_string(unsigned(real_to_vec(pckt_in.secondFrame, bit_size))));
                    writeline(output_file, line_var);
                    write(line_var, "Add res. was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8) & ", raw: " & to_string(correctAditionNoFloor,8));
                    writeline(output_file, line_var);
                    write(line_var, "In binary:  " & to_string(unsigned(real_to_vec(pckt_out.firstFrame, bit_size))));
                    writeline(output_file, line_var);
                    write(line_var, "Mul res. was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) & ", raw: " & to_string(correctMultiplicationNoFloor,8));
                    writeline(output_file, line_var);
                    write(line_var, "In binary:  " & to_string(unsigned(real_to_vec(pckt_out.secondFrame, bit_size))));
                    writeline(output_file, line_var);
                    if to_string(pckt_out.firstFrame,8) = to_string(correctAdition,8) and to_string(pckt_out.secondFrame,8) = to_string(correctMultiplication,8) then
                        write(line_var, string'("PASSED"));
                    else
                        write(line_var, string'("FAILED")); --HATE THIS SO MUCH sTrING' 
                    end if;
                    writeline(output_file, line_var);
                    write(line_var, string'("For requirements verificaton please see output waveform file.")); --HATE THIS SO MUCH sTrING' 
                    writeline(output_file, line_var);

                when "REQ_AAU_F_012" =>
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & ":");
                    writeline(output_file, line_var);
                    write(line_var, "For numbers:  " & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8));
                    writeline(output_file, line_var);
                    write(line_var, "Add res. was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8) & ", raw: " & to_string(correctAditionNoFloor,8));
                    writeline(output_file, line_var);
                    write(line_var, "Mul res. was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) & ", raw: " & to_string(correctMultiplicationNoFloor,8));
                    writeline(output_file, line_var);
                    if to_string(pckt_out.firstFrame,8) = to_string(correctAdition,8) and to_string(pckt_out.secondFrame,8) = to_string(correctMultiplication,8) then
                        write(line_var, string'("PASSED"));
                    else
                        write(line_var, string'("FAILED")); --HATE THIS SO MUCH sTrING' 
                    end if;
                    
                    writeline(output_file, line_var);
                when "REQ_AAU_F_013" =>
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & ":");
                    writeline(output_file, line_var);
                    write(line_var, "For numbers:  " & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8));
                    writeline(output_file, line_var);
                    write(line_var, "Add res. was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8) & ", raw: " & to_string(correctAditionNoFloor,8));
                    writeline(output_file, line_var);
                    write(line_var, "Mul res. was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) & ", raw: " & to_string(correctMultiplicationNoFloor,8));
                    writeline(output_file, line_var);
                    if to_string(pckt_out.firstFrame,8) = to_string(correctAdition,8) and to_string(pckt_out.secondFrame,8) = to_string(correctMultiplication,8) then
                        write(line_var, string'("PASSED"));
                    else
                        write(line_var, string'("FAILED")); --HATE THIS SO MUCH sTrING'  
                    end if;
                    writeline(output_file, line_var);
                -- SCLK times REQUIREMENTS
                when "REQ_AAU_I_020" =>
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & " " & "for SCLK period: " & to_string(SCLK_period) & ":" );
                    writeline(output_file, line_var);
                    write(line_var, "For numbers:  " & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8));
                    writeline(output_file, line_var);
                    write(line_var, "Add res. was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8) & ", raw: " & to_string(correctAditionNoFloor,8));
                    writeline(output_file, line_var);
                    write(line_var, "Mul res. was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) & ", raw: " & to_string(correctMultiplicationNoFloor,8));
                    writeline(output_file, line_var);
                    if to_string(pckt_out.firstFrame,8) = to_string(correctAdition,8) and to_string(pckt_out.secondFrame,8) = to_string(correctMultiplication,8) then
                        write(line_var, string'("PASSED"));
                    else
                        write(line_var, string'("FAILED")); --HATE THIS SO MUCH sTrING' 
                    end if;
                    writeline(output_file, line_var);

                -- INTERFACE REQUIREMENTS
                when "REQ_AAU_I_021" =>
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & ":");
                    writeline(output_file, line_var);
                    write(line_var, "For numbers:  " & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8));
                    writeline(output_file, line_var);
                    write(line_var, "Add res. was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8) & ", raw: " & to_string(correctAditionNoFloor,8));
                    writeline(output_file, line_var);
                    write(line_var, "Mul res. was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) & ", raw: " & to_string(correctMultiplicationNoFloor,8));
                    writeline(output_file, line_var);
                    if to_string(pckt_out.firstFrame,8) = to_string(correctAdition,8) and to_string(pckt_out.secondFrame,8) = to_string(correctMultiplication,8) then
                        write(line_var, string'("PASSED"));
                    else
                        write(line_var, string'("FAILED")); --HATE THIS SO MUCH sTrING' 
                    end if;
                    writeline(output_file, line_var);
                    write(line_var, string'("For requirements verificaton please see output waveform file.")); --HATE THIS SO MUCH sTrING' 
                    writeline(output_file, line_var);

                when "REQ_AAU_I_022" =>
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & " for bit size 1=" & to_string(bit_size) & " and bit size 2=" & to_string(bit_size_2) & ":");
                    writeline(output_file, line_var);
                    write(line_var, "For numbers:  " & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8));
                    writeline(output_file, line_var);
                    write(line_var, "Add res. was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8) & ", raw: " & to_string(correctAditionNoFloor,8));
                    writeline(output_file, line_var);
                    write(line_var, "Mul res. was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) & ", raw: " & to_string(correctMultiplicationNoFloor,8));
                    writeline(output_file, line_var);
                    if to_string(pckt_out.firstFrame,8) = to_string(correctAdition,8) and to_string(pckt_out.secondFrame,8) = to_string(correctMultiplication,8) then
                        write(line_var, string'("PASSED"));
                    else
                        write(line_var, string'("FAILED")); --HATE THIS SO MUCH sTrING' 
                    end if;
                    
                    writeline(output_file, line_var);

                when "REQ_AAU_I_023" =>
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & " delay between frames=" & to_string(delay)& ":");
                    writeline(output_file, line_var);
                    write(line_var, "For numbers:  " & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8));
                    writeline(output_file, line_var);
                    write(line_var, "Add res. was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8) & ", raw: " & to_string(correctAditionNoFloor,8));
                    writeline(output_file, line_var);
                    write(line_var, "Mul res. was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) & ", raw: " & to_string(correctMultiplicationNoFloor,8));
                    writeline(output_file, line_var);
                    if to_string(pckt_out.firstFrame,8) = to_string(correctAdition,8) and to_string(pckt_out.secondFrame,8) = to_string(correctMultiplication,8) then
                        write(line_var, string'("PASSED"));
                    else
                        write(line_var, string'("FAILED")); --HATE THIS SO MUCH sTrING' 
                    end if;
                    
                    writeline(output_file, line_var);
                when others =>
                    write(line_var, string'("---------------"));
                    writeline(output_file, line_var);
                    write(line_var, REQ_name & ": Undefined requirement");
                    writeline(output_file, line_var);
            end case;

            -- report "pckt_out.firstFrame:";
            -- report to_string((pckt_out.firstFrame));
            -- report "pckt_out.secondFrame:";
            -- report to_string((pckt_out.secondFrame));

            -- assert sumation
            assert to_string(pckt_out.firstFrame,8) = to_string(correctAdition,8) -- nerovna se assert
                report "For numbers:" & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8) & " addition result was: " & to_string(pckt_out.firstFrame,8) & ", Should be: " & to_string(correctAdition,8) severity warning;
            -- assert multiplication
            assert to_string(pckt_out.secondFrame,8) = to_string(correctMultiplication,8) -- nerovna se assert
                report "For numbers " & to_string(pckt_in.firstFrame,8) & " and " & to_string(pckt_in.secondFrame,8) & " multiplication result was: " & to_string(pckt_out.secondFrame,8) & ", Should be: " & to_string(correctMultiplication,8) severity warning;
        end procedure;

    procedure send_frame(signal SPI_bus : inout SPI_bus_t;
                         data_in : in std_logic_vector;
                         data_out : out std_logic_vector;
                         SCLK_period : in time) 
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
            wait for SCLK_period * 0.25;
            SPI_bus.CS_b <= '1';
            SPI_bus.MOSI <= '0';
        end procedure;


    procedure send_packet(signal SPI_bus : inout SPI_bus_t;
                          data_in : in packet;
                          variable data_out : out packet;
                          delay: in time;
                          bit_size : in natural := c_DATA_SIZE;
                          bit_size_2 : in natural := c_DATA_SIZE;
                          SCLK_period : in time)
            is
                variable fr1_vec : std_logic_vector(bit_size-1 downto 0) := (others => '0');
                variable fr2_vec : std_logic_vector(bit_size_2-1 downto 0) := (others => '0');
            begin
                wait until rising_edge(SPI_bus.SCLK);
                wait for 0.25 * SCLK_period;
                send_frame(SPI_bus,real_to_vec(data_in.firstFrame, bit_size),fr1_vec,SCLK_period);
                wait for delay;
                send_frame(SPI_bus,real_to_vec(data_in.secondFrame, bit_size_2), fr2_vec,SCLK_period);

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


    -- -- TO STRING for VHDL 93
    -- function to_string(r : real; decimal_places : natural) return string is
    --     variable integer_part : integer;
    --     variable fractional_part : real;
    --     variable result_str : string(1 to 1024) := (others => ' ');
    --     variable fraction_str : string(1 to 1024) := (others => '0');
    --     variable i : integer := 1;
    -- begin
    --     -- Split the real number into integer and fractional parts
    --     integer_part := integer(r);
    --     fractional_part := abs(r - real(integer_part));

    --     -- Convert the integer part to string
    --     result_str := integer'image(integer(integer_part));

    --     -- Process fractional part
    --     if decimal_places > 0 then
    --         result_str := result_str & ".";  -- Add decimal point
    --         while i <= decimal_places loop
    --             fractional_part := fractional_part * 10.0;
    --             fraction_str(i) := integer'image(integer(fractional_part))(1);
    --             fractional_part := fractional_part - real(integer(fractional_part));
    --             i := i + 1;
    --         end loop;
    --         result_str := result_str & fraction_str(1 to decimal_places);
    --     end if;

    --     return result_str;
    -- end to_string;

end tb_verification;