library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_bin2seg is
    -- Testbench nema zadne porty
end entity tb_bin2seg;

architecture testbench of tb_bin2seg is

    signal sig_bin : std_logic_vector(3 downto 0);
    signal sig_ena : std_logic := '1';
    signal sig_seg : std_logic_vector(6 downto 0);

begin

    uut_bin2seg : entity work.bin2seg
        port map (
            bin => sig_bin,
            ena => sig_ena,
            seg => sig_seg
        );

    p_stimulus : process
    begin
        -- 1. Test cisel 0-9
        report "Testovani cislic 0-9";
        sig_ena <= '1';
        
        sig_bin <= x"0"; wait for 10 ns;
        sig_bin <= x"1"; wait for 10 ns;
        sig_bin <= x"2"; wait for 10 ns;
        sig_bin <= x"3"; wait for 10 ns;
        sig_bin <= x"4"; wait for 10 ns;
        sig_bin <= x"5"; wait for 10 ns;
        sig_bin <= x"6"; wait for 10 ns;
        sig_bin <= x"7"; wait for 10 ns;
        sig_bin <= x"8"; wait for 10 ns;
        sig_bin <= x"9"; wait for 10 ns;

        -- 2. Test pismen
        report "Testovani pismen A, L, t, I, n, E";
        sig_bin <= x"A"; wait for 10 ns; -- "A"
        sig_bin <= x"B"; wait for 10 ns; -- "L"
        sig_bin <= x"C"; wait for 10 ns; -- "t"
        sig_bin <= x"D"; wait for 10 ns; -- "I"
        sig_bin <= x"E"; wait for 10 ns; -- "n"
        sig_bin <= x"F"; wait for 10 ns; -- "E"

        -- 3. Test zhasnuti (Mezera)
        report "Testovani funkce Enable (Mezera)";
        sig_ena <= '0';
        sig_bin <= x"0"; wait for 10 ns; -- Melo by zustat zhasnuto
        sig_bin <= x"8"; wait for 10 ns; -- Melo by zustat zhasnuto

        -- Konec simulace
        wait;
    end process p_stimulus;

end architecture testbench;
