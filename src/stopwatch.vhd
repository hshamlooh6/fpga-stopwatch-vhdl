library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stopwatch is
    Port (
        clk        : in  STD_LOGIC;
        reset_btn  : in  STD_LOGIC;
        start_stop : in  STD_LOGIC;
        seg_dig0   : out STD_LOGIC_VECTOR(6 downto 0);
        seg_dig1   : out STD_LOGIC_VECTOR(6 downto 0);
        seg_dig2   : out STD_LOGIC_VECTOR(6 downto 0);
        seg_dig3   : out STD_LOGIC_VECTOR(6 downto 0)
    );
end stopwatch;

architecture Behavioral of stopwatch is

    -- despite the name, this goes up once every 10 ms, so 1234 means 12.34 s
    signal milliseconds : unsigned(15 downto 0) := (others => '0');
    signal running      : STD_LOGIC := '0';

    constant CLK_FREQ  : integer := 50_000_000;
    constant SLOW_FREQ : integer := 100;
    constant DIVISOR   : integer := CLK_FREQ / SLOW_FREQ;

    signal clock_counter   : integer range 0 to DIVISOR - 1 := 0;
    signal prev_start_stop : STD_LOGIC := '0';

    signal digit0, digit1, digit2, digit3 : STD_LOGIC_VECTOR(3 downto 0);

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset_btn = '1' then
                milliseconds  <= (others => '0');
                running       <= '0';
                clock_counter <= 0;
            else
                if clock_counter < DIVISOR - 1 then
                    clock_counter <= clock_counter + 1;
                else
                    clock_counter <= 0;

                    -- the button is only checked once every 10 ms, which also
                    -- happens to filter out most of the switch bounce
                    if start_stop = '1' and prev_start_stop = '0' then
                        running <= not running;
                    end if;
                    prev_start_stop <= start_stop;

                    if running = '1' then
                        if milliseconds < 9999 then
                            milliseconds <= milliseconds + 1;
                        else
                            milliseconds <= (others => '0');
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    process(clk)
        variable temp_ms : integer range 0 to 65535;
    begin
        if rising_edge(clk) then
            temp_ms := to_integer(milliseconds);

            digit0 <= std_logic_vector(to_unsigned(temp_ms mod 10, 4));
            digit1 <= std_logic_vector(to_unsigned((temp_ms / 10) mod 10, 4));
            digit2 <= std_logic_vector(to_unsigned((temp_ms / 100) mod 10, 4));
            digit3 <= std_logic_vector(to_unsigned((temp_ms / 1000) mod 10, 4));
        end if;
    end process;

    digit0_decoder: entity work.seven_segment_decoder
        port map (
            digit   => digit0,
            seg_out => seg_dig0
        );

    digit1_decoder: entity work.seven_segment_decoder
        port map (
            digit   => digit1,
            seg_out => seg_dig1
        );

    digit2_decoder: entity work.seven_segment_decoder
        port map (
            digit   => digit2,
            seg_out => seg_dig2
        );

    digit3_decoder: entity work.seven_segment_decoder
        port map (
            digit   => digit3,
            seg_out => seg_dig3
        );

end Behavioral;
