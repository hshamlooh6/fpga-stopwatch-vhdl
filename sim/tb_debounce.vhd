library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
end tb_debounce;

architecture sim of tb_debounce is
    constant CLK_PERIOD : time    := 20 ns;
    -- much smaller than the real 250000 so the test finishes instantly
    constant LIMIT      : integer := 20;

    signal clk       : STD_LOGIC := '0';
    signal input     : STD_LOGIC := '0';
    signal debounced : STD_LOGIC;
    signal done      : boolean := false;
begin

    clk <= not clk after CLK_PERIOD / 2 when not done;

    dut: entity work.debounce
        generic map (DEBOUNCE_LIMIT => LIMIT)
        port map (clk => clk, input => input, debounced => debounced);

    stim: process
        variable cycles : integer;
    begin
        wait for 5 * CLK_PERIOD;

        for i in 1 to 8 loop
            input <= '1';
            wait for 4 * CLK_PERIOD;
            input <= '0';
            wait for 3 * CLK_PERIOD;
            assert debounced = '0'
                report "Bounce leaked through to the output" severity failure;
        end loop;

        wait until rising_edge(clk);
        input  <= '1';
        cycles := 0;
        while debounced = '0' loop
            wait until rising_edge(clk);
            wait for 1 ns; -- give the output a moment to update after the edge
            cycles := cycles + 1;
            assert cycles < 10 * LIMIT
                report "Output never followed a stable input" severity failure;
        end loop;
        report "Stable press passed through after " & integer'image(cycles) & " clocks";
        assert cycles = LIMIT + 1
            report "Expected " & integer'image(LIMIT + 1) & " clocks" severity failure;

        for i in 1 to 8 loop
            input <= '0';
            wait for 4 * CLK_PERIOD;
            input <= '1';
            wait for 3 * CLK_PERIOD;
            assert debounced = '1'
                report "Release bounce leaked through to the output" severity failure;
        end loop;

        input <= '0';
        wait for (LIMIT + 3) * CLK_PERIOD;
        assert debounced = '0'
            report "Output did not follow a stable release" severity failure;

        report "debounce: all checks PASSED" severity note;
        done <= true;
        std.env.finish;
    end process;

end sim;
