library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alarm_memory is
    port (
        clk          : in  std_logic;
        rst          : in  std_logic;
        -- Tyto signály ti pošle kolega z modulu "Tlačítka" (měly by to být už ošetřené pulzy na 1 takt)
        en_inc_hour  : in  std_logic; 
        en_inc_min   : in  std_logic;
        -- Výstup uloženého času budíku
        alarm_hh     : out integer range 0 to 23;
        alarm_mm     : out integer range 0 to 59
    );
end entity alarm_memory;

architecture behavioral of alarm_memory is
    -- Vnitřní registry pro uložení času (výchozí budík je v 06:00)
    signal s_hh : integer range 0 to 23 := 6;
    signal s_mm : integer range 0 to 59 := 0;
begin
    p_alarm_mem : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_hh <= 6;
                s_mm <= 0;
            else
                -- Zvýšení hodin s přetečením z 23 na 0
                if en_inc_hour = '1' then
                    if s_hh = 23 then
                        s_hh <= 0;
                    else
                        s_hh <= s_hh + 1;
                    end if;
                end if;
                
                -- Zvýšení minut s přetečením z 59 na 0
                if en_inc_min = '1' then
                    if s_mm = 59 then
                        s_mm <= 0;
                    else
                        s_mm <= s_mm + 1;
                    end if;
                end if;
            end if;
        end if;
    end process p_alarm_mem;

    -- Poslání vnitřních stavů na výstupní porty
    alarm_hh <= s_hh;
    alarm_mm <= s_mm;

end architecture behavioral;