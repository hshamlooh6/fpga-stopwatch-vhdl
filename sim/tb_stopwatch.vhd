library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_stopwatch is
end tb_stopwatch;

architecture sim of tb_stopwatch is
    constant CLK_PERIOD : time := 20 ns;
    constant TICK       : time := 10 ms;

    signal clk        : STD_LOGIC := '0';
    signal reset_btn  : STD_LOGIC := '0';
    signal start_stop : STD_LOGIC := '0';
    signal seg_dig0   : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_dig1   : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_dig2   : STD_LOGIC_VECTOR(6 downto 0);
    signal seg_dig3   : STD_LOGIC_VECTOR(6 downto 0);
    signal done       : boolean := false;

    function seg_to_digit(seg : STD_LOGIC_VECTOR(6 downto 0)) return integer is
    begin
        case seg is
            when "1000000" => return 0;
            when "1111001" => return 1;
            when "0100100" => return 2;
            when "0110000" => return 3;
            when "0011001" => return 4;
            when "0010010" => return 5;
            when "0000010" => return 6;
            when "1111000" => return 7;
            when "0000000" => return 8;
            when "0010000" => return 9;
            when others    => return -1;
        end case;
    end function;

    impure function shown return integer is
        variable d0, d1, d2, d3 : integer;
    begin
        d0 := seg_to_digit(seg_dig0);
        d1 := seg_to_digit(seg_dig1);
        d2 := seg_to_digit(seg_dig2);
        d3 := seg_to_digit(seg_dig3);
        if d0 < 0 or d1 < 0 or d2 < 0 or d3 < 0 then
            return -1;
        end if;
        return d3 * 1000 + d2 * 100 + d1 * 10 + d0;
    end function;

    impure function shown_str return string is
        constant v : integer := shown;
    begin
        if v < 0 then
            return "--.--";
        end if;
        return integer'image(v / 1000) & integer'image((v / 100) mod 10) & "." &
               integer'image((v / 10) mod 10) & integer'image(v mod 10);
    end function;

begin

    clk <= not clk after CLK_PERIOD / 2 when not done;

    dut: entity work.stopwatch
        port map (
            clk        => clk,
            reset_btn  => reset_btn,
            start_stop => start_stop,
            seg_dig0   => seg_dig0,
            seg_dig1   => seg_dig1,
            seg_dig2   => seg_dig2,
            seg_dig3   => seg_dig3
        );

    stim: process
        alias count is << signal dut.milliseconds : unsigned(15 downto 0) >>;
        variable v1, v2, prev : integer;
        variable wrapped      : boolean := false;

        -- held for 15 ms because the stopwatch only looks at the button
        -- every 10 ms, so a shorter press could be missed
        procedure press(signal btn : out STD_LOGIC) is
        begin
            btn <= '1';
            wait for 15 ms;
            btn <= '0';
        end procedure;

        procedure show(msg : string) is
        begin
            report msg & "  display = " & shown_str;
        end procedure;
    begin
        reset_btn <= '1';
        wait for 200 ns;
        reset_btn <= '0';
        wait for 1 us;
        show("After reset");
        assert shown = 0 report "Display is not 00.00 after reset" severity failure;

        wait for 50 ms;
        assert shown = 0 report "Watch started counting without a start press" severity failure;

        press(start_stop);
        wait for 200 ms;
        v1 := shown;
        show("Running");
        assert v1 >= 19 and v1 <= 21
            report "Expected about 00.20 after ~0.2 s, got " & shown_str severity failure;

        wait for 100 ms;
        v2 := shown;
        show("100 ms later");
        assert v2 = v1 + 10
            report "Count did not advance by exactly 10 in 100 ms" severity failure;

        press(start_stop);
        wait for 20 ms;
        v1 := shown;
        show("Stopped");
        wait for 100 ms;
        assert shown = v1 report "Display changed while stopped" severity failure;
        show("Still stopped 100 ms later");

        press(start_stop);
        wait for 50 ms;
        v2 := shown;
        show("Resumed");
        assert v2 > v1 and v2 <= v1 + 6
            report "Did not resume from the frozen value" severity failure;
        wait for 100 ms;
        assert shown = v2 + 10 report "Count rate wrong after resume" severity failure;

        reset_btn <= '1';
        wait for 200 ns;
        reset_btn <= '0';
        wait for 1 us;
        show("Reset while running");
        assert shown = 0 report "Reset while running did not clear the display" severity failure;
        wait for 50 ms;
        assert shown = 0 report "Watch kept running after reset" severity failure;

        -- actually counting up to 99.99 would take 100 s of simulated time,
        -- so I force the counter to 9993, let one tick happen, then release it.
        -- it carries on from 9994 and should roll over to 00.00 a few ticks later
        press(start_stop);
        count <= force to_unsigned(9993, 16);
        wait for TICK + 2 ms;
        count <= release;
        wait for 8 ms;
        prev := shown;
        show("Jumped near the end");
        for i in 1 to 10 loop
            wait for TICK;
            if shown = 0 and prev = 9999 then
                wrapped := true;
                show("Wrapped");
            end if;
            assert shown = (prev + 1) mod 10000
                report "Count did not step by 1 near the wrap point" severity failure;
            prev := shown;
        end loop;
        assert wrapped report "Count never wrapped from 99.99 to 00.00" severity failure;

        report "stopwatch: all checks PASSED" severity note;
        done <= true;
        std.env.finish;
    end process;

end sim;
