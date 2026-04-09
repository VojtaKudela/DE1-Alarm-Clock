library ieee;
use ieee.std_logic_1164.all;

entity bin2seg is
    port (
        bin : in  std_logic_vector(3 downto 0);
        ena : in  std_logic; -- '1' = sviti, '0' = zhasnuto (mezera)
        seg : out std_logic_vector(6 downto 0)
    );
end entity bin2seg;

architecture behavioral of bin2seg is
begin
    p_decoder : process(bin, ena)
    begin
        -- Kdyz neni enable aktivni, zhasni cely znak (mezera)
        if ena = '0' then
            seg <= "1111111"; 
        else
            -- Jinak dekoduj 4-bitovy vstup
            case bin is
                -- Cisla 0-9
                when x"0" => seg <= "1000000"; -- 0
                when x"1" => seg <= "1111001"; -- 1
                when x"2" => seg <= "0100100"; -- 2
                when x"3" => seg <= "0110000"; -- 3
                when x"4" => seg <= "0011001"; -- 4
                when x"5" => seg <= "0010010"; -- 5
                when x"6" => seg <= "0000010"; -- 6
                when x"7" => seg <= "1111000"; -- 7
                when x"8" => seg <= "0000000"; -- 8
                when x"9" => seg <= "0010000"; -- 9
                
                -- Pismena pro Alarm (AL)
                when x"A" => seg <= "0001000"; -- A
                when x"B" => seg <= "1000111"; -- L 
                
                -- Pismena pro Time (tInE)
                when x"C" => seg <= "0000111"; -- t
                when x"D" => seg <= "1111001"; -- I (stejne jako 1)
                when x"E" => seg <= "0101011"; -- n
                when x"F" => seg <= "0000110"; -- E
                
                when others => seg <= "1111111";
            end case;
        end if;
    end process p_decoder;
end architecture behavioral;
