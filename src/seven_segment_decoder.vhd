library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seven_segment_decoder is
    Port (
        digit   : in  STD_LOGIC_VECTOR(3 downto 0);
        seg_out : out STD_LOGIC_VECTOR(6 downto 0)
    );
end seven_segment_decoder;

architecture Behavioral of seven_segment_decoder is
begin

    -- bit order is g f e d c b a, and a 0 turns the segment ON (active-low)
    process(digit)
    begin
        case digit is
            when "0000" => seg_out <= "1000000";
            when "0001" => seg_out <= "1111001";
            when "0010" => seg_out <= "0100100";
            when "0011" => seg_out <= "0110000";
            when "0100" => seg_out <= "0011001";
            when "0101" => seg_out <= "0010010";
            when "0110" => seg_out <= "0000010";
            when "0111" => seg_out <= "1111000";
            when "1000" => seg_out <= "0000000";
            when "1001" => seg_out <= "0010000";
            when others => seg_out <= "1111111";
        end case;
    end process;

end Behavioral;
