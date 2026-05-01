----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vojtech Kudela
-- @copyright (c) 2026 Vojtech Kudela, MIT license
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
        -- Debounced button inputs
        btnL       : in  std_logic;                    -- Left button (navigation)
        btnR       : in  std_logic;                    -- Right button (navigation)
        btn_c      : in  std_logic;                    -- Center button (mode/set)
        btn_up     : in  std_logic;                    -- Up button (increment)
        btn_down   : in  std_logic;                    -- Down button (decrement)
        -- Core outputs
        HH         : out std_logic_vector(4 downto 0); -- Current hours
        MM         : out std_logic_vector(5 downto 0); -- Current minutes
        SS         : out std_logic_vector(5 downto 0); -- Current seconds
        ce_1s_out  : out std_logic;                    -- 1Hz pulse output for other modules
        view_mode  : out std_logic_vector(1 downto 0); -- Current display mode
        set_en_out : out std_logic;                    -- Setting mode active indicator
        set_hh_out : out std_logic;                    -- Hours setting active indicator
        set_mm_out : out std_logic                     -- Minutes setting active indicator
    );
end entity time_core;

architecture Behavioral of time_core is

    component clk_en
        generic (
            G_MAX : positive
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            ce  : out std_logic
        );
    end component;

    component main_loop
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            mode_up    : in  std_logic;
            mode_down  : in  std_logic;
            set_btn    : in  std_logic;
            up_btn     : in  std_logic;
            down_btn   : in  std_logic;
            ce_1s      : in  std_logic;
            view_sel   : out std_logic_vector(1 downto 0);
            run_time   : out std_logic;
            set_en     : out std_logic;
            set_hh     : out std_logic;
            set_mm     : out std_logic;
            dot_on     : out std_logic;
            view_dbg   : out std_logic_vector(1 downto 0);
            set_dbg    : out std_logic_vector(1 downto 0)
        );
    end component;

    component time_counter
        port (
            clk        : in  std_logic;
            rst        : in  std_logic;
            ce_1s      : in  std_logic;
            run_time   : in  std_logic;
            set_en     : in  std_logic;
            view_mode  : in  std_logic_vector(1 downto 0);
            set_hh     : in  std_logic;
            set_mm     : in  std_logic;
            btn_up     : in  std_logic;
            btn_down   : in  std_logic;
            HH         : out std_logic_vector(4 downto 0);
            MM         : out std_logic_vector(5 downto 0);
            SS         : out std_logic_vector(5 downto 0)
        );
    end component;

    signal ce_1s          : std_logic;                    -- Internal 1Hz pulse
    signal sig_set_en     : std_logic;                    -- Internal set enable flag
    signal sig_run_time   : std_logic;                    -- Internal run time flag
    signal sig_set_hh     : std_logic;                    -- Internal set hours flag
    signal sig_set_mm     : std_logic;                    -- Internal set minutes flag
    signal sig_view_sel   : std_logic_vector(1 downto 0); -- Internal view mode selection

begin
    
    -- Clock enable generator for 1Hz timebase
    CLKDIV : clk_en
        generic map (
            G_MAX => 100_000_000 -- Assuming 100MHz system clock
        )
        port map (
            clk => clk,
            rst => rst,
            ce  => ce_1s
        );

    -- Main state machine for controlling modes and settings
    MAIN_FSM : main_loop
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
            dot_on    => open -- Unused debug output
        );

    -- Actual time counter logic
    COUNTER : time_counter
        port map (
            clk        => clk,
            rst        => rst,
            ce_1s      => ce_1s,
            run_time   => sig_run_time,
            set_en     => sig_set_en,
            view_mode  => sig_view_sel,
            set_hh     => sig_set_hh,
            set_mm     => sig_set_mm,
            btn_up     => btn_up,
            btn_down   => btn_down,
            HH         => HH,
            MM         => MM,
            SS         => SS
        );

    -- ------------------------------------------
    -- Output Assignments
    -- ------------------------------------------
    -- Route internal signals to the module outputs
    ce_1s_out  <= ce_1s;
    view_mode  <= sig_view_sel;
    set_en_out <= sig_set_en;
    set_hh_out <= sig_set_hh;
    set_mm_out <= sig_set_mm;

end Behavioral;
