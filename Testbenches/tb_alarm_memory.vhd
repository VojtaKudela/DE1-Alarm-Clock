library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_alarm_memory is
end entity tb_alarm_memory;

architecture testbench of tb_alarm_memory is
    -- Signály pro propojení
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal en_inc_hour : std_logic := '0';
    signal en_inc_min  : std_logic := '0';
    signal alarm_hh    : integer range 0 to 23;
    signal alarm_mm    : integer range 0 to 59;

    constant C_CLK_PERIOD : time := 10 ns; -- 100 MHz
begin
    -- Připojení testovaného modulu (UUT)
    uut_memory : entity work.alarm_memory
        port map (
            clk         => clk,
            rst         => rst,
            en_inc_hour => en_inc_hour,
            en_inc_min  => en_inc_min,
            alarm_hh    => alarm_hh,
            alarm_mm    => alarm_mm
        );

    -- Generování hodin
    clk <= not clk after C_CLK_PERIOD / 2;

    -- Hlavní testovací proces
    p_stimulus : process
    begin
        -- 1. Reset systému
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        -- Výchozí stav by měl být 06:00
        
        -- 2. Přidáme 2 hodiny (simulace stisku tlačítka s délkou 1 taktu)
        en_inc_hour <= '1'; wait for C_CLK_PERIOD; en_inc_hour <= '0';
        wait for 40 ns;
        en_inc_hour <= '1'; wait for C_CLK_PERIOD; en_inc_hour <= '0';
        wait for 40 ns;
        -- Čas by teď měl být 08:00

        -- 3. Přidáme 3 minuty
        en_inc_min <= '1'; wait for C_CLK_PERIOD; en_inc_min <= '0';
        wait for 20 ns;
        en_inc_min <= '1'; wait for C_CLK_PERIOD; en_inc_min <= '0';
        wait for 20 ns;
        en_inc_min <= '1'; wait for C_CLK_PERIOD; en_inc_min <= '0';
        
        -- Čas by teď měl být 08:03
        wait for 100 ns;
        
        -- Konec simulace
        std.env.stop;
    end process;
end architecture testbench;
