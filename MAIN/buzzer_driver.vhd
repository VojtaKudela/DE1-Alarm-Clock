library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity buzzer_driver is
    generic (
        -- Pro 100 MHz hodiny:
        -- 100 000 000 / (2 * 2000 Hz) = 25 000
        C_TONE_LIMIT : integer := 25000; -- Tón cca 2 kHz
        -- 100 000 000 / (2 * 2 Hz) = 25 000 000
        C_BEEP_LIMIT : integer := 25000000 -- Pípání 2x za sekundu
    );
    port (
        clk      : in  std_logic; -- Hodiny desky (100 MHz)
        rst      : in  std_logic; -- Reset
        en_alarm : in  std_logic; -- Signál "Budík zvoní" z hlavního FSM
        buzzer   : out std_logic  -- Fyzický výstup na pin (Pmod/header)
    );
end entity buzzer_driver;

architecture behavioral of buzzer_driver is
    signal s_tone_cnt : integer range 0 to C_TONE_LIMIT := 0;
    signal s_tone_sig : std_logic := '0';
    
    signal s_beep_cnt : integer range 0 to C_BEEP_LIMIT := 0;
    signal s_beep_sig : std_logic := '0';
begin

    -- Proces pro generování pískavého tónu (vysoká frekvence)
    p_tone_gen : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_tone_cnt <= 0;
                s_tone_sig <= '0';
            else
                if s_tone_cnt >= (C_TONE_LIMIT - 1) then
                    s_tone_cnt <= 0;
                    s_tone_sig <= not s_tone_sig;
                else
                    s_tone_cnt <= s_tone_cnt + 1;
                end if;
            end if;
        end if;
    end process p_tone_gen;

    -- Proces pro přerušování (pípání - nízká frekvence)
    p_beep_gen : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_beep_cnt <= 0;
                s_beep_sig <= '0';
            else
                if s_beep_cnt >= (C_BEEP_LIMIT - 1) then
                    s_beep_cnt <= 0;
                    s_beep_sig <= not s_beep_sig;
                else
                    s_beep_cnt <= s_beep_cnt + 1;
                end if;
            end if;
        end if;
    end process p_beep_gen;

    -- Finální výstup: hraj jen když je alarm aktivní A když je pípací cyklus v '1'
    buzzer <= s_tone_sig and s_beep_sig and en_alarm;

end architecture behavioral;

