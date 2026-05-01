----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jan Jaroslav Kolacek
-- Copyright (c) 2026 Jan Jaroslav Kolacek, MIT license
-- 
-- Create Date: 23.04.2026 19:56:29
-- Design Name: buzzer_driver
-- Module Name: buzzer_driver - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module implements a buzzer driver for an alarm clock system.
-- It generates a modulated square wave signal to drive a piezo buzzer.
-- The driver uses two internal counters: one to generate a continuous 
-- high-frequency tone (approx. 2 kHz) and another to generate a low-frequency 
-- envelope (approx. 2 Hz). By combining these two signals with an enable 
-- signal, it produces a distinct, intermittent beeping sound when the 
-- alarm is active.
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

entity buzzer_driver is
    generic (
        C_TONE_LIMIT : integer := 25000;   -- Tone frequency (approx. 2 kHz at 100 MHz clk)
        C_BEEP_LIMIT : integer := 25000000 -- Interruption speed (beeping approx. 2 Hz)
    );
    port (
        clk      : in  std_logic; -- Main system clock input
        rst      : in  std_logic; -- Synchronous active-high reset to initialize internal state
        en_alarm : in  std_logic; -- Activation signal (from alarm_control)
        buzzer   : out std_logic  -- Modulated output for piezo buzzer
    );
end entity buzzer_driver;

architecture Behavioral of buzzer_driver is
    
    -- Counters and signals for generating the basic tone
    signal s_tone_cnt : integer range 0 to C_TONE_LIMIT := 0;
    signal s_tone_sig : std_logic := '0';
    
    -- Counters and signals for tone interruption (beeping envelope)
    signal s_beep_cnt : integer range 0 to C_BEEP_LIMIT := 0;
    signal s_beep_sig : std_logic := '0';

begin

    -------------------------------------------------
    -- High-frequency tone generator
    -- Responsible for creating the 2 kHz acoustic wave.
    -------------------------------------------------
    p_tone_gen : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
            
                -- Reset the counter to zero and force the tone signal low
                s_tone_cnt <= 0;
                s_tone_sig <= '0';
            else
                -- Check if the counter has reached the threshold (C_TONE_LIMIT - 1)
                -- We subtract 1 because counting starts from 0 (e.g., 0 to 24,999 is 25,000 cycles)
                if s_tone_cnt >= (C_TONE_LIMIT - 1) then
                    s_tone_cnt <= 0;
                    
                    -- Flip the logical state (0 becomes 1, 1 becomes 0) to form the square wave
                    s_tone_sig <= not s_tone_sig;
                else
                
                    -- If threshold is not reached, simply increment the counte
                    s_tone_cnt <= s_tone_cnt + 1;
                end if;
            end if;
        end if;
    end process p_tone_gen;

    -------------------------------------------------
    -- Low-frequency beeping envelope generator
    -- Responsible for chopping the continuous tone into discrete beeps.
    -------------------------------------------------
    p_beep_gen : process(clk)
    begin
        if rising_edge(clk) then
            
            -- Check for synchronous reset priority
            if rst = '1' then
            
                -- Reset the counter to zero and force the envelope signal low
                s_beep_cnt <= 0;
                s_beep_sig <= '0';
            else
            
                -- Check if the counter has reached the envelope threshold
                -- Subtract 1 because counting starts at 0 (0 to 24,999,999 is 25M cycles)
                if s_beep_cnt >= (C_BEEP_LIMIT - 1) then
                    s_beep_cnt <= 0;
                    
                    -- Toggle the envelope state (ON phase becomes OFF phase, and vice versa)
                    s_beep_sig <= not s_beep_sig;
                else
                
                    -- Increment the counter to track elapsed time
                    s_beep_cnt <= s_beep_cnt + 1;
                end if;
            end if;
        end if;
    end process p_beep_gen;

    -------------------------------------------------
    -- Final output: tone is passed only during beep phase and active alarm
    -------------------------------------------------
    buzzer <= s_tone_sig and s_beep_sig and en_alarm;

end Behavioral;
