----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vojtìch Kudela
-- @copyright (c) 2026 Vojtìch Kudela, MIT license
-- 
-- Create Date: 23.04.2026 15:05:29
-- Design Name: time_core
-- Module Name: time_core - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module maintains the current time (HH:MM:SS), handles
-- the clock incrementing logic, and provides manual time
-- adjustment functionality through button inputs.
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

entity time_core is
    port (
        clk        : in  std_logic;                    -- Main system clock
        rst        : in  std_logic;                    -- High-active synchronous reset
        -- Control buttons
        btnL       : in  std_logic;                    -- Left button (Mode down)
        btnR       : in  std_logic;                    -- Right button (Mode up)
        btn_c      : in  std_logic;                    -- Center button (Set/OK)
        btn_up     : in  std_logic;                    -- Up button (Increment)
        btn_down   : in  std_logic;                    -- Down button (Decrement)
        -- Time outputs
        HH         : out std_logic_vector(4 downto 0); -- Current hours
        MM         : out std_logic_vector(5 downto 0); -- Current minutes
        SS         : out std_logic_vector(5 downto 0); -- Current seconds
        -- Status outputs
        ce_1s_out  : out std_logic;                    -- 1Hz clock enable signal
        view_mode  : out std_logic_vector(1 downto 0); -- Current display mode
        set_en_out : out std_logic;                    -- Programming mode active
        set_hh_out : out std_logic;                    -- Setting hours flag
        set_mm_out : out std_logic                     -- Setting minutes flag
    );
end entity time_core;

-------------------------------------------------
-- Time Core Architecture
architecture Behavioral of time_core is

    -- Internal signals for time-keeping
    signal ce_1s          : std_logic;
    signal sig_set_en     : std_logic;
    signal sig_run_time   : std_logic;
    signal sig_set_hh     : std_logic;
    signal sig_set_mm     : std_logic;
    signal sig_view_sel   : std_logic_vector(1 downto 0);
    
    -- Time registers
    signal reg_hh         : integer range 0 to 23 := 0;
    signal reg_mm         : integer range 0 to 59 := 0;
    signal reg_ss         : integer range 0 to 59 := 0;
    
    -- Edge detection registers for setting mode
    signal btn_up_last    : std_logic := '0';
    signal btn_down_last  : std_logic := '0';

begin

    -------------------------------------------------
    -- Clock Enable Generator (1 Hz)
    -------------------------------------------------
    CLKDIV : entity work.clk_en
        generic map (
            G_MAX => 100_000_000
        )
        port map (
            clk => clk,
            rst => rst,
            ce  => ce_1s
        );

    -------------------------------------------------
    -- Main Control FSM (Mode Selection)
    -------------------------------------------------
    MAIN_FSM : entity work.main_loop
        port map (
            clk       => clk,
            rst       => rst,
            mode_up   => btnR,
            mode_down => btnL,
            set_btn   => btn_c,
            up_btn    => btn_up,
            down_btn  => btn_down,
            ce_1s     => ce_1s,
            view_sel  => sig_view_sel,
            run_time  => sig_run_time,
            set_en    => sig_set_en,
            set_hh    => sig_set_hh,
            set_mm    => sig_set_mm,
            dot_on    => open
        );

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
                if (sig_run_time = '1' and ce_1s = '1') then
                    -- Second increment logic with overflow to minutes
                    if reg_ss = 59 then
                        reg_ss <= 0;
                        -- Minute increment logic with overflow to hours
                        if reg_mm = 59 then
                            reg_mm <= 0;
                            -- Hour increment logic with overflow to midnight (24h format)
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
                if (sig_set_en = '1' and sig_view_sel = "00") then
                    
                    -- HOURS ADJUSTMENT
                    if sig_set_hh = '1' then
                        -- Increment hours on button press (rising edge)
                        if (btn_up = '1' and btn_up_last = '0') then
                            if reg_hh = 23 then 
                                reg_hh <= 0; 
                            else 
                                reg_hh <= reg_hh + 1; 
                            end if;
                        -- Decrement hours on button press (rising edge)
                        elsif (btn_down = '1' and btn_down_last = '0') then
                            if reg_hh = 0 then 
                                reg_hh <= 23; 
                            else 
                                reg_hh <= reg_hh - 1; 
                            end if;
                        end if;
                    
                    -- MINUTES ADJUSTMENT
                    elsif sig_set_mm = '1' then
                        -- Increment minutes on button press (rising edge)
                        if (btn_up = '1' and btn_up_last = '0') then
                            if reg_mm = 59 then 
                                reg_mm <= 0; 
                            else 
                                reg_mm <= reg_mm + 1; 
                            end if;
                        -- Decrement minutes on button press (rising edge)
                        elsif (btn_down = '1' and btn_down_last = '0') then
                            if reg_mm = 0 then 
                                reg_mm <= 59; 
                            else 
                                reg_mm <= reg_mm - 1; 
                            end if;
                        end if;
                    end if;

                end if; -- End of manual setting
            end if; -- End of reset/logic
        end if; -- End of clock edge
    end process p_time_counter;

    -------------------------------------------------
    -- Output Assignments
    -------------------------------------------------
    ce_1s_out  <= ce_1s;
    view_mode  <= sig_view_sel;
    set_en_out <= sig_set_en;
    set_hh_out <= sig_set_hh;
    set_mm_out <= sig_set_mm;

    -- Type conversion from integer to std_logic_vector
    HH <= std_logic_vector(to_unsigned(reg_hh, 5));
    MM <= std_logic_vector(to_unsigned(reg_mm, 6));
    SS <= std_logic_vector(to_unsigned(reg_ss, 6));

end Behavioral;
