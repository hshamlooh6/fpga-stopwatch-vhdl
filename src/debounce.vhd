library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Generic (
        DEBOUNCE_LIMIT : integer := 250000 -- 5 ms with a 50 MHz clock
    );
    Port (
        clk       : in  STD_LOGIC;
        input     : in  STD_LOGIC;
        debounced : out STD_LOGIC
    );
end debounce;

architecture Behavioral of debounce is
    signal counter      : integer range 0 to DEBOUNCE_LIMIT := 0;
    signal debounce_out : STD_LOGIC := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if input /= debounce_out then
                if counter < DEBOUNCE_LIMIT then
                    counter <= counter + 1;
                else
                    debounce_out <= input;
                    counter      <= 0;
                end if;
            else
                counter <= 0;
            end if;
        end if;
    end process;

    debounced <= debounce_out;

end Behavioral;
