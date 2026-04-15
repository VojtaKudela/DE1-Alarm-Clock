library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_control is
    port (
        clk            : in  std_logic;
        rst            : in  std_logic;
        -- Přepínač na desce pro zapnutí/vypnutí funkce budíku
        sw_alarm_on    : in  std_logic; 
        -- Tlačítko pro típnutí zvonícího budíku
        btn_stop_alarm : in  std_logic; 
        
        -- Aktuální čas (od kolegy z modulu Hodiny)
        curr_hh        : in  integer range 0 to 23;
        curr_mm        : in  integer range 0 to 59;
        curr_ss        : in  integer range 0 to 59;
        
        -- Nastavený čas budíku (z tvého modulu alarm_memory)
        alarm_hh       : in  integer range 0 to 23;
        alarm_mm       : in  integer range 0 to 59;
        
        -- Výstupy
        led_armed      : out std_logic; -- LED nad switchem (svítí = budík je natažený)
        led_ringing    : out std_logic; -- Světelná signalizace zvonění
        en_buzzer      : out std_logic  -- Posílá se do generátoru bzučáku
    );
end entity alarm_control;

architecture behavioral of alarm_control is
    -- Paměťový bit, který drží informaci "Teď zvoním"
    signal s_is_ringing : std_logic := '0';
begin
    
    -- LED nad switchem ukazuje, jestli je budík zapnutý
    led_armed <= sw_alarm_on;

    p_alarm_logic : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' or sw_alarm_on = '0' then
                -- Reset nebo úplné vypnutí budíku switchem poplach zruší
                s_is_ringing <= '0';
            else
                -- 1. KDY SE BUDÍK SPUSTÍ:
                -- Shodují se hodiny, minuty a jsme v první sekundě (aby se nespustil vícekrát)
                if (curr_hh = alarm_hh and curr_mm = alarm_mm and curr_ss = 0) then
                    s_is_ringing <= '1';
                end if;
                
                -- 2. KDY SE BUDÍK VYPNE TLAČÍTKEM:
                if (btn_stop_alarm = '1') then
                    s_is_ringing <= '0';
                end if;
            end if;
        end if;
    end process p_alarm_logic;

    -- Propojení vnitřního signálu na výstupy
    en_buzzer   <= s_is_ringing;
    led_ringing <= s_is_ringing; -- Může blikat pomocí jiného modulu, tady zatím trvale svítí při zvonění

end architecture behavioral;