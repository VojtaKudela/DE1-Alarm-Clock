----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vojtech Kudela
-- @copyright (c) 2026 Vojtech Kudela, MIT license
-- 
-- Create Date: 23.04.2026 17:30:24
-- Design Name: top_alarm_clock
-- Module Name: top_alarm_clock - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description:   
-- This module integrates the clock core, alarm system, 
-- button synchronization, and display drivers. It supports 
-- three independent alarms and manual time setting via 
-- an onboard button interface
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

entity top_alarm_clock is
    port (
        clk      : in  std_logic;                      -- Main system clock (typically 100 MHz)
        rst      : in  std_logic;                      -- High-active synchronous reset
        -- User Inputs (Buttons)
        btnU     : in  std_logic;                      -- Up button (increment value)
        btnD     : in  std_logic;                      -- Down button (decrement value)
        btnL     : in  std_logic;                      -- Left button (navigation)
        btnR     : in  std_logic;                      -- Right button (navigation)
        btnC     : in  std_logic;                      -- Center button (OK / Mode / Stop alarm)
        -- User Inputs (Switches)
        sw0      : in  std_logic;                      -- Enable/Disable Alarm 1
        sw1      : in  std_logic;                      -- Enable/Disable Alarm 2
        sw2      : in  std_logic;                      -- Enable/Disable Alarm 3
        -- Display Outputs
        seg      : out std_logic_vector(6 downto 0);   -- 7-segment cathodes (active low)
        an       : out std_logic_vector(7 downto 0);   -- Common anodes for 8 digits
        dp       : out std_logic;                      -- Decimal point output
        -- Peripheral Outputs
        led      : out std_logic_vector(2 downto 0);   -- ZMÌNÌNO: Pouze 3 LED pro indikaci alarmù
        buzzer   : out std_logic                       -- Output for piezo buzzer
    );
end entity top_alarm_clock;

-------------------------------------------------
-- Top Alarm Clock Architecture
architecture Behavioral of top_alarm_clock is

    -- Internal signals for debounced and synchronized buttons
    signal clean_btnU   : std_logic;
    signal clean_btnD   : std_logic;
    signal clean_btnL   : std_logic;
    signal clean_btnR   : std_logic;
    signal clean_btnC   : std_logic;

    -- Time data (Current clock time)
    signal hh_core      : std_logic_vector(4 downto 0); -- Hours (0-23)
    signal mm_core      : std_logic_vector(5 downto 0); -- Minutes (0-59)
    signal ss_core      : std_logic_vector(5 downto 0); -- Seconds (0-59)
    
    -- Alarm data (Time of the selected alarm for display)
    signal hh_alarm     : std_logic_vector(4 downto 0);
    signal mm_alarm     : std_logic_vector(5 downto 0);    
    
    -- Control and Status signals
    signal ringing      : std_logic;                   -- Active alarm indicator
    signal ce_1s_sig    : std_logic;                   -- 1 Hz clock enable signal
    signal led_a1       : std_logic;                   -- Status of Alarm 1
    signal led_a2       : std_logic;                   -- Status of Alarm 2
    signal led_a3       : std_logic;                   -- Status of Alarm 3
    
    -- Mode control signals
    signal view_sel_sig : std_logic_vector(1 downto 0); -- "00"=Time, "01-11"=Alarms 1-3
    signal set_en_sig   : std_logic;                   -- Programming mode active
    signal set_hh_sig   : std_logic;                   -- Hour modification enable
    signal set_mm_sig   : std_logic;                   -- Minute modification enable

begin

    -------------------------------------------------
    -- Button synchronization and debouncing
    -- Ensures stable signals from mechanical buttons
    -------------------------------------------------
    BTN_SYNC_INST : entity work.button_sync
        port map (
            clk    => clk,
            rst    => rst,
            btnU   => btnU,
            btnD   => btnD,
            btnL   => btnL,
            btnR   => btnR,
            btnC   => btnC,
            cleanU => clean_btnU,
            cleanD => clean_btnD,
            cleanL => clean_btnL,
            cleanR => clean_btnR,
            cleanC => clean_btnC
        );

    -------------------------------------------------
    -- Main Time Management (Clock Core)
    -- Keeps track of the current time and handles UI modes
    -------------------------------------------------
    CORE : entity work.time_core
        port map (
            clk        => clk,
            rst        => rst,
            btnL       => clean_btnL,
            btnR       => clean_btnR,
            btn_c      => clean_btnC, 
            btn_up     => clean_btnU, 
            btn_down   => clean_btnD, 
            HH         => hh_core,
            MM         => mm_core,
            SS         => ss_core,
            ce_1s_out  => ce_1s_sig,
            view_mode  => view_sel_sig,
            set_en_out => set_en_sig,
            set_hh_out => set_hh_sig,
            set_mm_out => set_mm_sig
        );

    -------------------------------------------------
    -- Alarm Storage and Monitoring System
    -- Stores alarm times and compares them with current time
    -------------------------------------------------
    ALARM_SYS : entity work.alarm_system
        port map (
            clk        => clk,
            rst        => rst,
            ce_1s      => ce_1s_sig,
            btn_up     => clean_btnU,
            btn_down   => clean_btnD,
            btn_stop   => clean_btnC,
            view_mode  => view_sel_sig,
            set_en     => set_en_sig,
            set_hh     => set_hh_sig,
            set_mm     => set_mm_sig,
            en_al1     => sw0,
            en_al2     => sw1,
            en_al3     => sw2,
            curr_hh    => hh_core,
            curr_mm    => mm_core,
            curr_ss    => ss_core,
            alarm_hh   => hh_alarm,
            alarm_mm   => mm_alarm,
            ringing    => ringing,
            led_al1    => led_a1,
            led_al2    => led_a2,
            led_al3    => led_a3
        );

    -------------------------------------------------
    -- 7-segment Display Driver
    -- Multiplexes data for the 8-digit 7-segment display
    -------------------------------------------------
    DISP_DRV : entity work.display_driver
        port map (
            clk        => clk,
            rst        => rst,
            curr_hh    => hh_core,
            curr_mm    => mm_core,
            alarm_hh   => hh_alarm,
            alarm_mm   => mm_alarm,
            view_mode  => view_sel_sig,
            set_en     => set_en_sig,
            set_hh     => set_hh_sig,  
            set_mm     => set_mm_sig,  
            seg_o      => seg,
            dig_o      => an,
            dp_o       => dp
        );

    -------------------------------------------------
    -- Final Output Assignments
    -------------------------------------------------
    
    -- Drive buzzer based on ringing status
    buzzer <= ringing; 
    
    -- Map alarm status to first three LEDs
    led(0)           <= led_a1; 
    led(1)           <= led_a2;
    led(2)           <= led_a3;

end Behavioral;
