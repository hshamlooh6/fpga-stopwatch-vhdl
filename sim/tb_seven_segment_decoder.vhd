library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_seven_segment_decoder is
end tb_seven_segment_decoder;

architecture sim of tb_seven_segment_decoder is
    signal digit   : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal seg_out : STD_LOGIC_VECTOR(6 downto 0);

    -- which segments should light up for each digit, written out by hand
    -- so the test doesn't just copy the decoder's own table
    type lit_table_t is array (0 to 9) of string(1 to 7);
    constant LIT : lit_table_t := (
        0 => "abcdef ",
        1 => " bc    ",
        2 => "ab de g",
        3 => "abcd  g",
        4 => " bc  fg",
        5 => "a cd fg",
        6 => "a cdefg",
        7 => "abc    ",
        8 => "abcdefg",
        9 => "abcd fg"
    );

    function expected(d : integer) return STD_LOGIC_VECTOR is
        variable v : STD_LOGIC_VECTOR(6 downto 0) := (others => '1');
    begin
        if d <= 9 then
            for i in 0 to 6 loop
                if LIT(d)(i + 1) /= ' ' then
                    v(i) := '0';
                end if;
            end loop;
        end if;
        return v;
    end function;
begin

    dut: entity work.seven_segment_decoder
        port map (digit => digit, seg_out => seg_out);

    stim: process
        variable errors : integer := 0;
    begin
        for d in 0 to 15 loop
            digit <= std_logic_vector(to_unsigned(d, 4));
            wait for 10 ns;
            if seg_out /= expected(d) then
                report "Digit " & integer'image(d) & ": got " & to_string(seg_out) &
                       ", expected " & to_string(expected(d)) severity error;
                errors := errors + 1;
            end if;
        end loop;

        assert errors = 0 report "seven_segment_decoder: FAILED" severity failure;
        report "seven_segment_decoder: all 16 input codes PASSED" severity note;
        std.env.finish;
    end process;

end sim;
