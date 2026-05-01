----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jan Jaroslav Kolacek
-- @copyright (c) 2026 Jan Jaroslav Kolacek, MIT license
-- 
-- Create Date: 23.04.2026 15:11:36
-- Design Name: alarm_memory 
-- Module Name: alarm_memory - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module acts as the storage unit for three independent alarms.
-- It maintains internal registers for the hours and minutes of each alarm.
-- The module handles the modification of these values via user inputs (up/down buttons)
-- when the setting mode is active, including proper wrap-around logic (e.g., 23->0, 59->0).
-- It routes the currently selected alarm's time to the display and simultaneously
-- provides all stored alarm times to the external comparator logic.
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
use IEEE.NUMERIC_STD.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alarm_memory is
    port (
        clk        : in  std_logic;                    -- Main system clock
        rst        : in  std_logic;                    -- High-active synchronous reset
        -- User interface
        btn_up     : in  std_logic;                    -- Increment selected value
        btn_down   : in  std_logic;                    -- Decrement selected value
        view_mode  : in  std_logic_vector(1 downto 0); -- Selection of active alarm
        -- Control signals
        set_en     : in  std_logic;                    -- Enable setting mode
        set_hh     : in  std_logic;                    -- Target hours for modification
        set_mm     : in  std_logic;                    -- Target minutes for modification
        -- Outputs for display
        disp_hh    : out unsigned(4 downto 0);         -- Hours of selected alarm
        disp_mm    : out unsigned(5 downto 0);         -- Minutes of selected alarm
        -- Outputs for alarm comparator
        al1_h      : out unsigned(4 downto 0);         -- Alarm 1 hours
        al1_m      : out unsigned(5 downto 0);         -- Alarm 1 minutes
        al2_h      : out unsigned(4 downto 0);         -- Alarm 2 hours
        al2_m      : out unsigned(5 downto 0);         -- Alarm 2 minutes
        al3_h      : out unsigned(4 downto 0);         -- Alarm 3 hours
        al3_m      : out unsigned(5 downto 0)          -- Alarm 3 minutes
    );
end entity alarm_memory;

architecture Behavioral of alarm_memory is

    -- Internal registers for alarm times with default values
    signal a1_h : integer range 0 to 23 := 6;  
    signal a1_m : integer range 0 to 59 := 0;
    signal a2_h : integer range 0 to 23 := 7;  
    signal a2_m : integer range 0 to 59 := 0;
    signal a3_h : integer range 0 to 23 := 8;  
    signal a3_m : integer range 0 to 59 := 0;

    -- Signals for button edge detection
    signal btn_up_d   : std_logic := '0';
    signal btn_down_d : std_logic := '0';

begin

    -- Process handling the modification of stored alarm values
    p_alarm_storage : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- Reset all alarm times to midnight
                a1_h <= 0; 
                a1_m <= 0; 
                a2_h <= 0; 
                a2_m <= 0; 
                a3_h <= 0; 
                a3_m <= 0;
                btn_up_d   <= '0'; 
                btn_down_d <= '0';
            else
                -- Update delayed signals for edge detection
                btn_up_d   <= btn_up; 
                btn_down_d <= btn_down;

                -- Modify values only if setting is enabled
                if set_en = '1' then
                    
                    ---------------------------------------------
                    -- Hours modification logic
                    ---------------------------------------------
                    if set_hh = '1' then
                        -- Increment Hours (Edge detected)
                        if btn_up = '1' and btn_up_d = '0' then
                            if view_mode = "01" then
                                if a1_h = 23 then 
                                    a1_h <= 0; 
                                else 
                                    a1_h <= a1_h + 1; 
                                end if;
                            elsif view_mode = "10" then
                                if a2_h = 23 then 
                                    a2_h <= 0; 
                                else 
                                    a2_h <= a2_h + 1; 
                                end if;
                            elsif view_mode = "11" then
                                if a3_h = 23 then 
                                    a3_h <= 0; 
                                else 
                                    a3_h <= a3_h + 1; 
                                end if;
                            end if;
                        
                        -- Decrement Hours (Edge detected)
                        elsif btn_down = '1' and btn_down_d = '0' then
                            if view_mode = "01" then
                                if a1_h = 0 then 
                                    a1_h <= 23; 
                                else 
                                    a1_h <= a1_h - 1; 
                                end if;
                            elsif view_mode = "10" then
                                if a2_h = 0 then 
                                    a2_h <= 23; 
                                else 
                                    a2_h <= a2_h - 1; 
                                end if;
                            elsif view_mode = "11" then
                                if a3_h = 0 then 
                                    a3_h <= 23; 
                                else 
                                    a3_h <= a3_h - 1; 
                                end if;
                            end if;
                        end if;

                    ---------------------------------------------
                    -- Minutes modification logic
                    ---------------------------------------------
                    elsif set_mm = '1' then
                        -- Increment Minutes (Edge detected)
                        if btn_up = '1' and btn_up_d = '0' then
                            if view_mode = "01" then
                                if a1_m = 59 then 
                                    a1_m <= 0; 
                                else 
                                    a1_m <= a1_m + 1; 
                                end if;
                            elsif view_mode = "10" then
                                if a2_m = 59 then 
                                    a2_m <= 0; 
                                else 
                                    a2_m <= a2_m + 1; 
                                end if;
                            elsif view_mode = "11" then
                                if a3_m = 59 then 
                                    a3_m <= 0; 
                                else 
                                    a3_m <= a3_m + 1; 
                                end if;
                            end if;
                        
                        -- Decrement Minutes (Edge detected)
                        elsif btn_down = '1' and btn_down_d = '0' then
                            if view_mode = "01" then
                                if a1_m = 0 then 
                                    a1_m <= 59; 
                                else 
                                    a1_m <= a1_m - 1; 
                                end if;
                            elsif view_mode = "10" then
                                if a2_m = 0 then 
                                    a2_m <= 59; 
                                else 
                                    a2_m <= a2_m - 1; 
                                end if;
                            elsif view_mode = "11" then
                                if a3_m = 0 then 
                                    a3_m <= 59; 
                                else 
                                    a3_m <= a3_m - 1; 
                                end if;
                            end if;
                        end if;
                    end if; -- set_hh / set_mm
                end if; -- set_en
            end if; -- rst
        end if; -- clk
    end process p_alarm_storage;

    -------------------------------------------------
    -- Output Multiplexing and Conversion
    -------------------------------------------------
    
    -- Select which alarm is currently being viewed or modified
    disp_hh <= to_unsigned(a1_h, 5) when view_mode = "01" else
               to_unsigned(a2_h, 5) when view_mode = "10" else
               to_unsigned(a3_h, 5) when view_mode = "11" else
               to_unsigned(0, 5);

    disp_mm <= to_unsigned(a1_m, 6) when view_mode = "01" else
               to_unsigned(a2_m, 6) when view_mode = "10" else
               to_unsigned(a3_m, 6) when view_mode = "11" else
               to_unsigned(0, 6);

    -- Continuous assignment for real-time alarm comparison
    al1_h <= to_unsigned(a1_h, 5);
    al1_m <= to_unsigned(a1_m, 6);
    al2_h <= to_unsigned(a2_h, 5);
    al2_m <= to_unsigned(a2_m, 6);
    al3_h <= to_unsigned(a3_h, 5);
    al3_m <= to_unsigned(a3_m, 6);

end Behavioral;
