----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 23.04.2026 15:13:35
-- Design Name: 
-- Module Name: alarm_control - Behavioral
-- Project Name: Jan Jaroslav Koláèek
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
        -- Global signals
        clk       : in  std_logic;                     --! Main system clock
        rst       : in  std_logic;                     --! High-active synchronous reset
        ce_1s     : in  std_logic;                     --! 1 Hz clock enable for timers
        -- Alarm Enables (Switches)
        en_al1    : in  std_logic;                     --! Enable Alarm 1
        en_al2    : in  std_logic;                     --! Enable Alarm 2
        en_al3    : in  std_logic;                     --! Enable Alarm 3
        -- Control
        btn_stop  : in  std_logic;                     --! Snooze / Stop button
        -- Current Time Data
        curr_hh   : in  unsigned(4 downto 0);          --! Current core hours
        curr_mm   : in  unsigned(5 downto 0);          --! Current core minutes
        curr_ss   : in  unsigned(5 downto 0);          --! Current core seconds
        -- Alarm 1 Settings
        al1_h     : in  unsigned(4 downto 0);          --! Alarm 1 hours
        al1_m     : in  unsigned(5 downto 0);          --! Alarm 1 minutes
        -- Alarm 2 Settings
        al2_h     : in  unsigned(4 downto 0);          --! Alarm 2 hours
        al2_m     : in  unsigned(5 downto 0);          --! Alarm 2 minutes
        -- Alarm 3 Settings
        al3_h     : in  unsigned(4 downto 0);          --! Alarm 3 hours
        al3_m     : in  unsigned(5 downto 0);          --! Alarm 3 minutes
        -- Outputs
        ringing   : out std_logic;                     --! Buzzer activation signal
        led_al1   : out std_logic;                     --! Status LED Alarm 1 active
        led_al2   : out std_logic;                     --! Status LED Alarm 2 active
        led_al3   : out std_logic                      --! Status LED Alarm 3 active
    );
end entity alarm_control;

-------------------------------------------------
-- Alarm Control Architecture
architecture Behavioral of alarm_control is

    -- Internal signals
    signal s_ringing  : std_logic := '0';
    signal snooze_cnt : unsigned(15 downto 0) := (others => '0');
    
    -- Tracks which alarm is currently triggered (0=None, 1=AL1, 2=AL2, 3=AL3)
    signal active_al  : integer range 0 to 3 := 0; 
    
    -- Constants
    constant SNOOZE_LIMIT : integer := 300; -- 5 minutes (in seconds)

begin
    
    -- LED indicators mirror the switch states
    led_al1 <= en_al1;
    led_al2 <= en_al2;
    led_al3 <= en_al3;

    -------------------------------------------------
    -- Main Alarm Logic Process
    -------------------------------------------------
    p_alarm_fsm : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                s_ringing  <= '0'; 
                snooze_cnt <= (others => '0');
                active_al  <= 0;
            else
                
                ---------------------------------------------
                -- 1. Alarm Trigger Detection
                ---------------------------------------------
                -- Only check if not already ringing or in snooze mode
                if s_ringing = '0' and snooze_cnt = 0 then
                    -- Check Alarm 1
                    if curr_hh = al1_h and curr_mm = al1_m and curr_ss = 0 and en_al1 = '1' then
                        s_ringing <= '1'; 
                        active_al <= 1;
                    
                    -- Check Alarm 2
                    elsif curr_hh = al2_h and curr_mm = al2_m and curr_ss = 0 and en_al2 = '1' then
                        s_ringing <= '1'; 
                        active_al <= 2;
                    
                    -- Check Alarm 3
                    elsif curr_hh = al3_h and curr_mm = al3_m and curr_ss = 0 and en_al3 = '1' then
                        s_ringing <= '1'; 
                        active_al <= 3;
                    end if;
                end if;

                ---------------------------------------------
                -- 2. Complete Cancellation (Switch Off)
                ---------------------------------------------
                -- If the switch for the active alarm is turned off, kill all alarm activity
                if (active_al = 1 and en_al1 = '0') or
                   (active_al = 2 and en_al2 = '0') or
                   (active_al = 3 and en_al3 = '0') then
                    
                    s_ringing  <= '0';
                    snooze_cnt <= (others => '0');
                    active_al  <= 0;
                end if;

                ---------------------------------------------
                -- 3. Snooze Logic (Button Press)
                ---------------------------------------------
                -- If ringing and stop button pressed, stop buzzer and start snooze timer
                if btn_stop = '1' and s_ringing = '1' then
                    s_ringing  <= '0'; 
                    snooze_cnt <= to_unsigned(1, 16);
                end if;

                ---------------------------------------------
                -- 4. Snooze Timer Implementation
                ---------------------------------------------
                if snooze_cnt > 0 then
                    if ce_1s = '1' then
                        if snooze_cnt >= SNOOZE_LIMIT then
                            -- Time is up, start ringing again
                            s_ringing  <= '1'; 
                            snooze_cnt <= (others => '0');
                        else 
                            -- Count elapsed seconds
                            snooze_cnt <= snooze_cnt + 1;
                        end if;
                    end if;
                end if;

            end if; -- rst
        end if; -- clk
    end process p_alarm_fsm;

    -- Output assignment
    ringing <= s_ringing;
    
end architecture Behavioral;
