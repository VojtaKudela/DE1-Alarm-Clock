library ieee;
use ieee.std_logic_1164.all;

entity tb_buzzer_driver is
end tb_buzzer_driver;

architecture tb of tb_buzzer_driver is

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal en_alarm : std_logic;
    signal buzzer   : std_logic;

    -- Hodiny nastaveny na 10 ns (100 MHz)
    constant TbPeriod : time := 10 ns; 
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    -- TADY JE TA HLAVNÍ ZMĚNA:
    -- Použijeme rovnou entitu a přidáme generic map se zmenšenými hodnotami
    dut : entity work.buzzer_driver
    generic map (
        C_TONE_LIMIT => 4,  -- Bude měnit stav každé 4 takty (pro rychlou simulaci)
        C_BEEP_LIMIT => 20  -- Pípne každých 20 taktů
    )
    port map (clk      => clk,
              rst      => rst,
              en_alarm => en_alarm,
              buzzer   => buzzer);

    -- Generování hodin
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';
    clk <= TbClock;

    stimuli : process
    begin
        -- Výchozí stav: budík nezvoní
        en_alarm <= '0';

        -- Reset
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 50 ns;

        -- TADY ZAPÍNÁME BUDÍK
        en_alarm <= '1';
        
        -- Necháme to chvíli běžet, abychom v grafu viděli střídání pípání a ticha
        wait for 1000 * TbPeriod;
        
        -- Vypneme budík
        en_alarm <= '0';
        wait for 100 * TbPeriod;

        -- Konec simulace
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Konfigurační blok (může zůstat)
configuration cfg_tb_buzzer_driver of tb_buzzer_driver is
    for tb
    end for;
end cfg_tb_buzzer_driver;