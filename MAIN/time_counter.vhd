----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vojtech Kudela
-- @copyright (c) 2026 Vojtech Kudela, MIT license
-- 
-- Create Date: 23.04.2026 15:08:47
-- Design Name: time_counter
-- Module Name: time_counter - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- The `time_counter` module serves as the main timebase (clock) for the entire project.
-- It stores the current time (hours, minutes, seconds) in internal registers.
-- It ensures the automatic increment of time every second based on the input 
-- enable pulse `ce_1s` and the control signal `run_time`. 
-- It also provides logic for manual time adjustment by the user, where
-- it evaluates button presses (rising edge detection) and upon any
-- manual adjustment of hours or minutes, it synchronizes (resets) the seconds counter.
-- The outputs are converted from integer format to `std_logic_vector`
-- for further processing in subsequent modules (display, alarm comparison).
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

entity time_counter is
    port (
        clk        : in  std_logic;                    -- Main system clock
        rst        : in  std_logic;                    -- High-active synchronous reset
        ce_1s      : in  std_logic;                    -- 1Hz clock enable pulse
        run_time   : in  std_logic;                    -- Enable for automatic time increment
        set_en     : in  std_logic;                    -- Programming mode active
        view_mode  : in  std_logic_vector(1 downto 0); -- Current display mode
        set_hh     : in  std_logic;                    -- Target: Hours setting
        set_mm     : in  std_logic;                    -- Target: Minutes setting
        btn_up     : in  std_logic;                    -- Increment button
        btn_down   : in  std_logic;                    -- Decrement button
        HH         : out std_logic_vector(4 downto 0); -- Current hours
        MM         : out std_logic_vector(5 downto 0); -- Current minutes
        SS         : out std_logic_vector(5 downto 0)  -- Current seconds
    );
end entity time_counter;

architecture Behavioral of time_counter is

    -- Internal registers for time
    signal reg_hh         : integer range 0 to 23 := 0;
    signal reg_mm         : integer range 0 to 59 := 0;
    signal reg_ss         : integer range 0 to 59 := 0;
    
    -- Edge detection registers for setting mode
    signal btn_up_last    : std_logic := '0';
    signal btn_down_last  : std_logic := '0';

begin

    -------------------------------------------------
    -- Time Management Process
    -------------------------------------------------
    p_time_counter : process(clk)
    begin
        -- All operations are synchronized to the rising edge of the system clock
        if rising_edge(clk) then
            
            -- Synchronous reset: Pre-sets all time values and edge registers to zero
            if rst = '1' then
                reg_hh        <= 0;
                reg_mm        <= 0;
                reg_ss        <= 0;
                btn_up_last   <= '0';
                btn_down_last <= '0';
            else
                -- Store current button states to detect rising edge in the next clock cycle
                btn_up_last   <= btn_up;
                btn_down_last <= btn_down;

                --------------------------------------------------------
                -- [1] AUTOMATIC TIME INCREMENT (Clock Ticking)
                -- Triggered once per second by the ce_1s pulse.
                --------------------------------------------------------
                
                -- Time increments only when time running is enabled (run_time = '1')
                -- and simultaneously a 1 Hz enable pulse arrives (ce_1s = '1').
                if (run_time = '1' and ce_1s = '1') then
                    -- Second increment logic with overflow to minutes
                    if reg_ss = 59 then
                        reg_ss <= 0;
                        -- Minute increment logic with overflow to hours
                        if reg_mm = 59 then
                            reg_mm <= 0;
                            -- Hour increment logic with overflow to midnight
                            if reg_hh = 23 then 
                                reg_hh <= 0; 
                            else 
                                reg_hh <= reg_hh + 1; 
                            end if;
                        else
                            reg_mm <= reg_mm + 1;
                        end if;
                    else
                        reg_ss <= reg_ss + 1;
                    end if;
                end if;

                --------------------------------------------------------
                -- [2] MANUAL TIME SETTING (Programming Mode)
                -- Allows user to adjust hours/minutes using Up/Down buttons.
                --------------------------------------------------------
                
                -- Manual adjustment is active only if the setting mode is enabled
                -- and the user is in the main time view (view_mode = "00").
                if (set_en = '1' and view_mode = "00") then
                    
                    -- HOURS ADJUSTMENT
                    if set_hh = '1' then
                        -- Increment hours on button press (rising edge)
                        -- Rising edge detection: the button is currently pressed, but wasn't in the previous cycle.
                        if (btn_up = '1' and btn_up_last = '0') then
                            if reg_hh = 23 then 
                                reg_hh <= 0; 
                            else 
                                reg_hh <= reg_hh + 1; 
                            end if;
                            reg_ss <= 0; -- Sync seconds to 0
                            
                        -- Decrement hours on button press (rising edge)
                        elsif (btn_down = '1' and btn_down_last = '0') then
                            if reg_hh = 0 then 
                                reg_hh <= 23; 
                            else 
                                reg_hh <= reg_hh - 1; 
                            end if;
                            reg_ss <= 0; -- Sync seconds to 0
                        end if;
                    
                    -- MINUTES ADJUSTMENT
                    elsif set_mm = '1' then
                        -- Increment minutes on button press (rising edge)
                        if (btn_up = '1' and btn_up_last = '0') then
                            if reg_mm = 59 then 
                                reg_mm <= 0; 
                            else 
                                reg_mm <= reg_mm + 1; 
                            end if;
                            reg_ss <= 0; -- Sync seconds to 0
                            
                        -- Decrement minutes on button press (rising edge)
                        elsif (btn_down = '1' and btn_down_last = '0') then
                            if reg_mm = 0 then 
                                reg_mm <= 59; 
                            else 
                                reg_mm <= reg_mm - 1; 
                            end if;
                            reg_ss <= 0; -- Sync seconds to 0
                        end if;
                    end if;

                end if; -- End of manual setting
            end if; -- End of reset/logic
        end if; -- End of clock edge
    end process p_time_counter;

    -------------------------------------------------
    -- Type Conversion for Outputs
    -------------------------------------------------
    HH <= std_logic_vector(to_unsigned(reg_hh, 5));
    MM <= std_logic_vector(to_unsigned(reg_mm, 6));
    SS <= std_logic_vector(to_unsigned(reg_ss, 6));

end Behavioral;
