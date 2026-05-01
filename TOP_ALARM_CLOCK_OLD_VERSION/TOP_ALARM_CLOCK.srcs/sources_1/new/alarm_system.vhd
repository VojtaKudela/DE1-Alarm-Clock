----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jan Jaroslav Kolacek, Vojtech Kudela
-- Copyright (c) 2026 Jan Jarolav Kolacek, Vojtech Kudela, MIT license
-- 
-- Create Date: 23.04.2026 15:16:40
-- Design Name: alarm_syste
-- Module Name: alarm_system - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module interconnects the alarm storage (memory) 
-- and the comparison logic (control). It acts as a top-level 
-- component for all alarm-related operations.
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

entity alarm_system is
    port (
        clk        : in  std_logic;                    -- Main system clock
        rst        : in  std_logic;                    -- High-active synchronous reset
        ce_1s      : in  std_logic;                    -- 1 Hz clock enable
        
        -- User interface (Buttons)
        btn_up     : in  std_logic;                    -- Increment button
        btn_down   : in  std_logic;                    -- Decrement button
        btn_stop   : in  std_logic;                    -- Button to stop the ringing
        
        -- Control and selection
        view_mode  : in  std_logic_vector(1 downto 0); -- Selection of active alarm
        set_en     : in  std_logic;                    -- Programming mode enable
        set_hh     : in  std_logic;                    -- Hour modification flag
        set_mm     : in  std_logic;                    -- Minute modification flag
        
        -- Alarm enables (from switches)
        en_al1     : in  std_logic;                    -- Alarm 1 enabled
        en_al2     : in  std_logic;                    -- Alarm 2 enabled
        en_al3     : in  std_logic;                    -- Alarm 3 enabled
        
        -- Current time inputs from core
        curr_hh    : in  std_logic_vector(4 downto 0); 
        curr_mm    : in  std_logic_vector(5 downto 0); 
        curr_ss    : in  std_logic_vector(5 downto 0); 
        
        -- Outputs for display and indicators
        alarm_hh   : out std_logic_vector(4 downto 0); -- Selected alarm hours
        alarm_mm   : out std_logic_vector(5 downto 0); -- Selected alarm minutes
        ringing    : out std_logic;                    -- Nyní pøenáší pøímo modulovaný signál pro bzuèák
        led_al1    : out std_logic;                    -- Status LED for Alarm 1
        led_al2    : out std_logic;                    -- Status LED for Alarm 2
        led_al3    : out std_logic                     -- Status LED for Alarm 3
    );
end entity alarm_system;

-------------------------------------------------
-- Alarm System Architecture
architecture Behavioral of alarm_system is

    -- Internal signals for hour registers
    signal sig_al1_h   : unsigned(4 downto 0);
    signal sig_al2_h   : unsigned(4 downto 0);
    signal sig_al3_h   : unsigned(4 downto 0);
    
    -- Internal signals for minute registers
    signal sig_al1_m   : unsigned(5 downto 0);
    signal sig_al2_m   : unsigned(5 downto 0);
    signal sig_al3_m   : unsigned(5 downto 0);
    
    -- Signals for currently selected alarm (for display)
    signal sig_disp_hh : unsigned(4 downto 0);
    signal sig_disp_mm : unsigned(5 downto 0);

    -- NOVÝ SIGNÁL: Propojuje alarm_control (povolení) a buzzer_driver (generátor zvuku)
    signal sig_ringing_ctrl : std_logic;

begin

    -------------------------------------------------
    -- Instance: Alarm Storage Memory
    -- Handles saving and loading of alarm time values.
    -------------------------------------------------
    MEM : entity work.alarm_memory
        port map (
            clk       => clk,
            rst       => rst,
            btn_up    => btn_up,
            btn_down  => btn_down,
            view_mode => view_mode,
            set_en    => set_en,
            set_hh    => set_hh,
            set_mm    => set_mm,
            disp_hh   => sig_disp_hh,
            disp_mm   => sig_disp_mm,
            al1_h     => sig_al1_h,
            al2_h     => sig_al2_h,
            al3_h     => sig_al3_h,
            al1_m     => sig_al1_m,
            al2_m     => sig_al2_m,
            al3_m     => sig_al3_m
        );

    -------------------------------------------------
    -- Instance: Alarm Comparison and Control
    -- Compares current time with memory and handles ringing logic.
    -------------------------------------------------
    CTRL : entity work.alarm_control
        port map (
            clk      => clk,
            rst      => rst,
            ce_1s    => ce_1s,
            en_al1   => en_al1,
            en_al2   => en_al2,
            en_al3   => en_al3,
            btn_stop => btn_stop,
            curr_hh  => unsigned(curr_hh),
            curr_mm  => unsigned(curr_mm),
            curr_ss  => unsigned(curr_ss),
            al1_h    => sig_al1_h,
            al2_h    => sig_al2_h,
            al3_h    => sig_al3_h,
            al1_m    => sig_al1_m,
            al2_m    => sig_al2_m,
            al3_m    => sig_al3_m,
            ringing  => sig_ringing_ctrl, -- Pøesmìrováno do nového interního signálu
            led_al1  => led_al1,
            led_al2  => led_al2,
            led_al3  => led_al3
        );

    -------------------------------------------------
    -- Instance: Buzzer Audio Generator
    -- Modulates a tone when an alarm is triggered.
    -------------------------------------------------
    BUZZER_GEN : entity work.buzzer_driver
        port map (
            clk      => clk,
            rst      => rst,
            en_alarm => sig_ringing_ctrl, -- Vstup z control logic
            buzzer   => ringing           -- Zvuk posíláme ven z alarm_system
        );

    -------------------------------------------------
    -- Signal Conversion for Outputs
    -- Mapping internal unsigned signals to port outputs.
    -------------------------------------------------
    alarm_hh <= std_logic_vector(sig_disp_hh);
    alarm_mm <= std_logic_vector(sig_disp_mm);

end architecture Behavioral;
