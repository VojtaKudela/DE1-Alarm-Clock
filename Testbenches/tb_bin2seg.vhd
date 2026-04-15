library ieee;
use ieee.std_logic_1164.all;

-- Testbench entita je vzdy prazdna
entity tb_bin2seg is
end entity tb_bin2seg;

architecture testbench of tb_bin2seg is

    -- Vnitrni signaly pro pripojeni k testovanemu modulu (UUT)
    signal sig_clear : std_logic;
    signal sig_bin   : std_logic_vector(4 downto 0);
    signal sig_seg   : std_logic_vector(6 downto 0);

begin

    -- Instanciace testovaného modulu (Unit Under Test)
    uut_bin2seg : entity work.bin2seg
        port map (
            clear => sig_clear,
            bin   => sig_bin,
            seg   => sig_seg
        );

    --------------------------------------------------------------------
    -- Hlavni stimulacni proces
    --------------------------------------------------------------------
    p_stimulus : process
    begin
        report "Zacatek simulace modulu bin2seg..." severity note;

        -- 1. Test funkce Clear (reset)
        report "Test: Clear = 1 (Ocekavano 1111111 / Zhasnuto)";
        sig_clear <= '1';
        sig_bin   <= "00000"; -- Binarne 0
        wait for 10 ns;

        -- Vypnuti funkce Clear pro zbytek testu
        sig_clear <= '0';
        wait for 10 ns;

        -- 2. Test cislic 0 az 9
        report "Test: Cislice 0-9";
        sig_bin <= "00000"; wait for 10 ns; -- 0
        sig_bin <= "00001"; wait for 10 ns; -- 1
        sig_bin <= "00010"; wait for 10 ns; -- 2
        sig_bin <= "00011"; wait for 10 ns; -- 3
        sig_bin <= "00100"; wait for 10 ns; -- 4
        sig_bin <= "00101"; wait for 10 ns; -- 5
        sig_bin <= "00110"; wait for 10 ns; -- 6
        sig_bin <= "00111"; wait for 10 ns; -- 7
        sig_bin <= "01000"; wait for 10 ns; -- 8
        sig_bin <= "01001"; wait for 10 ns; -- 9

        -- 3. Test specialnich znaku
        report "Test: Specialni znaky A, L, _, H, o, d";
        sig_bin <= "01010"; wait for 10 ns; -- A
        sig_bin <= "01011"; wait for 10 ns; -- L
        sig_bin <= "01100"; wait for 10 ns; -- _
        sig_bin <= "01101"; wait for 10 ns; -- H
        sig_bin <= "01110"; wait for 10 ns; -- o
        sig_bin <= "01111"; wait for 10 ns; -- d

        -- 4. Test nedefinovaneho vstupu (mel by zhasnout displej)
        report "Test: Hodnota mimo rozsah (Ocekavano 1111111 / Zhasnuto)";
        sig_bin <= "10000"; wait for 10 ns; -- 16

        report "Simulace uspesne dokoncena." severity note;
        wait; -- Zastaveni simulace
    end process p_stimulus;

end architecture testbench;