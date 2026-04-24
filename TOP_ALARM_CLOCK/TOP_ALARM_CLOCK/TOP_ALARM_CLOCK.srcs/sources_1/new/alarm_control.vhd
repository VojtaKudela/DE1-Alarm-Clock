----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:13:35
-- Design Name: 
-- Module Name: alarm_control - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alarm_control is
    port (
        clk, rst, ce_1s : in std_logic;
        
        -- Samostatné switche pro každý budík
        en_al1, en_al2, en_al3 : in std_logic;
        btn_stop : in std_logic;
        
        curr_hh : in unsigned(4 downto 0); curr_mm : in unsigned(5 downto 0); curr_ss : in unsigned(5 downto 0);
        al1_h, al2_h, al3_h : in unsigned(4 downto 0);
        al1_m, al2_m, al3_m : in unsigned(5 downto 0);
        
        ringing : out std_logic;
        
        -- Samostatné LED pro každý budík
        led_al1, led_al2, led_al3 : out std_logic
    );
end entity;

architecture behavioral of alarm_control is
    signal s_ringing  : std_logic := '0';
    signal snooze_cnt : unsigned(15 downto 0) := (others => '0');
    
    -- Pamatuje si, který budík zrovna zvoní (0 = nic, 1 = AL1, 2 = AL2, 3 = AL3)
    signal active_al  : integer range 0 to 3 := 0; 
    
    constant SNOOZE_LIMIT : integer := 300; -- 5 minut
begin
    
    -- LEDky svítí podle zapnutých switchù
    led_al1 <= en_al1;
    led_al2 <= en_al2;
    led_al3 <= en_al3;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_ringing <= '0'; 
                snooze_cnt <= (others => '0');
                active_al <= 0;
            else
                -- 1. Detekce èasu pro spuštìní alarmu (pokud je jeho switch nahoøe)
                if s_ringing = '0' and snooze_cnt = 0 then
                    if curr_hh = al1_h and curr_mm = al1_m and curr_ss = 0 and en_al1 = '1' then
                        s_ringing <= '1'; active_al <= 1;
                    elsif curr_hh = al2_h and curr_mm = al2_m and curr_ss = 0 and en_al2 = '1' then
                        s_ringing <= '1'; active_al <= 2;
                    elsif curr_hh = al3_h and curr_mm = al3_m and curr_ss = 0 and en_al3 = '1' then
                        s_ringing <= '1'; active_al <= 3;
                    end if;
                end if;

                -- 2. Zrušení alarmu: Pokud vypneme switch budíku, který zrovna zvoní (nebo je ve Snooze)
                if (active_al = 1 and en_al1 = '0') or
                   (active_al = 2 and en_al2 = '0') or
                   (active_al = 3 and en_al3 = '0') then
                    s_ringing <= '0';
                    snooze_cnt <= (others => '0');
                    active_al <= 0;
                end if;

                -- 3. Odložení alarmu (Snooze prostøedním tlaèítkem)
                if btn_stop = '1' and s_ringing = '1' then
                    s_ringing <= '0'; 
                    snooze_cnt <= to_unsigned(1, 16);
                end if;

                -- 4. Èasovaè pro opìtovné spuštìní po 5 minutách
                if snooze_cnt > 0 then
                    if ce_1s = '1' then
                        if snooze_cnt >= SNOOZE_LIMIT then
                            s_ringing <= '1'; 
                            snooze_cnt <= (others => '0');
                        else 
                            snooze_cnt <= snooze_cnt + 1;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    ringing <= s_ringing;
    
end architecture;
