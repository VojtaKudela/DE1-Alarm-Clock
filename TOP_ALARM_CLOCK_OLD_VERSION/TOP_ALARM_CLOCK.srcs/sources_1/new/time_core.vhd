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

architecture Behavioral of time_core is

    -- Internal signals for routing between submodules
    signal ce_1s          : std_logic;
    signal sig_set_en     : std_logic;
    signal sig_run_time   : std_logic;
    signal sig_set_hh     : std_logic;
    signal sig_set_mm     : std_logic;
    signal sig_view_sel   : std_logic_vector(1 downto 0);

begin

    -------------------------------------------------
    -- Instance: Clock Enable Generator (1 Hz)
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
    -- Instance: Main Control FSM (Mode Selection)
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
    -- Instance: Time Counter Logic
    -------------------------------------------------
    COUNTER : entity work.time_counter
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

    -------------------------------------------------
    -- Output Assignments (Routing internal signals to ports)
    -------------------------------------------------
    ce_1s_out  <= ce_1s;
    view_mode  <= sig_view_sel;
    set_en_out <= sig_set_en;
    set_hh_out <= sig_set_hh;
    set_mm_out <= sig_set_mm;

end Behavioral;
