----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Vojtech Kudela
-- @copyright (c) 2026 Vojtech Kudela, MIT license
-- 
-- Create Date: 23.04.2026 15:03:56
-- Design Name: main_loop
-- Module Name: main_loop - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description:
-- This module implements the central control logic for a 
-- digital clock with multiple alarms. It handles state 
-- transitions for viewing different modes and manages 
-- the time-setting sequence (HH/MM) using a long-press 
-- mechanism and FSM. 
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

entity main_loop is
    port (
        clk        : in  std_logic;                    -- Main system clock
        rst        : in  std_logic;                    -- High-active synchronous reset
        mode_up    : in  std_logic;                    -- Switch view mode forward
        mode_down  : in  std_logic;                    -- Switch view mode backward
        set_btn    : in  std_logic;                    -- Button for entering/exiting setup
        up_btn     : in  std_logic;                    -- Manual increment button
        down_btn   : in  std_logic;                    -- Manual decrement button
        ce_1s      : in  std_logic;                    -- Clock enable pulse (1 second)
        
        view_sel   : out std_logic_vector(1 downto 0); -- Selection of display source
        run_time   : out std_logic;                    -- Enable for real-time counter
        set_en     : out std_logic;                    -- Master setting enable
        set_hh     : out std_logic;                    -- Target: Hours setting
        set_mm     : out std_logic;                    -- Target: Minutes setting
        dot_on     : out std_logic;                    -- Colon/Dot display control
        view_dbg   : out std_logic_vector(1 downto 0); -- Debug: Current view state
        set_dbg    : out std_logic_vector(1 downto 0)  -- Debug: Current setup state
    );
end entity main_loop;

-------------------------------------------------
-- Main Loop Architecture
architecture Behavioral of main_loop is

    -- FSM State definitions
    type view_type is (TIME_VIEW, AL1_VIEW, AL2_VIEW, AL3_VIEW);
    signal view_state : view_type := TIME_VIEW;

    type set_type is (S_OFF, S_HH, S_MM);
    signal set_state : set_type := S_OFF;

    -- Edge detection and synchronization
    signal set_btn_d      : std_logic := '0';
    signal mode_up_d      : std_logic := '0';
    signal mode_down_d    : std_logic := '0';
    signal set_btn_rise   : std_logic;
    signal mode_up_rise   : std_logic;
    signal mode_down_rise : std_logic;
    
    -- Internal timing and counters
    signal ms_cnt     : integer range 0 to 100_000 := 0;
    signal tick_1ms   : std_logic := '0';
    signal hold_cnt   : integer range 0 to 2000 := 0;
    
    constant LONG_PRESS : integer := 2000; -- Threshold for 2-second hold

begin

    -------------------------------------------------
    -- 1ms Tick Generator
    -- Divides system clock to create a millisecond timebase for hold detection.
    -------------------------------------------------
    p_1ms_gen : process(clk)
    begin
        if rising_edge(clk) then
            if ms_cnt = 99_999 then
                ms_cnt   <= 0;
                tick_1ms <= '1';
            else
                ms_cnt   <= ms_cnt + 1;
                tick_1ms <= '0';
            end if;
        end if;
    end process p_1ms_gen;


    -------------------------------------------------
    -- Edge Detector
    -- Identifies the rising edges of input buttons to trigger single-action events.
    -------------------------------------------------
    p_edge_detect : process(clk)
    begin
        if rising_edge(clk) then
            -- Detection of rising edges
            set_btn_rise   <= set_btn and not set_btn_d;
            mode_up_rise   <= mode_up and not mode_up_d;
            mode_down_rise <= mode_down and not mode_down_d;

            -- Delay registers for edge detection
            set_btn_d   <= set_btn;
            mode_up_d   <= mode_up;
            mode_down_d <= mode_down;
        end if;
    end process p_edge_detect;


    -------------------------------------------------
    -- Button Hold Counter (2 Seconds)
    -- Increments while set_btn is held; used to enter programming mode.
    -------------------------------------------------
    p_hold_counter : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hold_cnt <= 0;
            else
                if set_btn = '1' then
                    -- Increment only on 1ms tick to measure real time
                    if (tick_1ms = '1' and hold_cnt < LONG_PRESS) then
                        hold_cnt <= hold_cnt + 1;
                    end if;
                else
                    hold_cnt <= 0;
                end if;
            end if;
        end if;
    end process p_hold_counter;


    -------------------------------------------------
    -- View Selection FSM
    -- Cycles through different display modes (Time, Alarm 1-3).
    -------------------------------------------------
    p_view_fsm : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                view_state <= TIME_VIEW;
            elsif set_state = S_OFF then
                -- Navigation through modes
                if mode_up_rise = '1' then
                    case view_state is
                        when TIME_VIEW => view_state <= AL1_VIEW;
                        when AL1_VIEW  => view_state <= AL2_VIEW;
                        when AL2_VIEW  => view_state <= AL3_VIEW;
                        when AL3_VIEW  => view_state <= TIME_VIEW;
                    end case;
                elsif mode_down_rise = '1' then
                    case view_state is
                        when TIME_VIEW => view_state <= AL3_VIEW;
                        when AL1_VIEW  => view_state <= TIME_VIEW;
                        when AL2_VIEW  => view_state <= AL1_VIEW;
                        when AL3_VIEW  => view_state <= AL2_VIEW;
                    end case;
                end if;
            end if;
        end if;
    end process p_view_fsm;


    -------------------------------------------------
    -- Setting State FSM
    -- Manages the logic of programming the time/alarm values.
    -------------------------------------------------
    p_set_fsm : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                set_state <= S_OFF;
            else
                case set_state is
                    -- Wait for long press to start setting
                    when S_OFF =>
                        if hold_cnt = LONG_PRESS then
                            set_state <= S_HH;
                        end if;
                        
                    -- Hours setting mode
                    when S_HH =>
                        if mode_up_rise = '1' then
                            set_state <= S_MM;
                        elsif set_btn_rise = '1' then
                            set_state <= S_OFF;
                        end if;
                        
                    -- Minutes setting mode
                    when S_MM =>
                        if mode_down_rise = '1' then
                            set_state <= S_HH;
                        elsif set_btn_rise = '1' then
                            set_state <= S_OFF;
                        end if;                        
                end case;
            end if;
        end if;
    end process p_set_fsm;


    -------------------------------------------------
    -- Output Logic Process
    -- Combinational logic for mapping FSM states to output control signals.
    -------------------------------------------------
    p_output_logic : process(view_state, set_state, ce_1s, up_btn, down_btn)
    begin
        -- Default assignments to prevent latches
        run_time <= '1';
        set_en   <= '0';
        set_hh   <= '0'; 
        set_mm   <= '0'; 
        dot_on   <= '1';
        
        -- Source selection mapping
        case view_state is
            when TIME_VIEW => 
                view_sel <= "00"; 
                view_dbg <= "00";
            when AL1_VIEW  => 
                view_sel <= "01"; 
                view_dbg <= "01";
            when AL2_VIEW  => 
                view_sel <= "10"; 
                view_dbg <= "10";
            when AL3_VIEW  => 
                view_sel <= "11"; 
                view_dbg <= "11";
        end case;

        -- Debug status mapping
        case set_state is
            when S_OFF => set_dbg <= "00";
            when S_HH  => set_dbg <= "01";
            when S_MM  => set_dbg <= "10";
        end case;

        -- Operational mode overrides
        case set_state is
            when S_OFF => 
                run_time <= '1'; 
                dot_on   <= ce_1s; -- Blink dot with 1s period
                 
            when S_HH => 
                -- Halt time counting ONLY if modifying the main time
                if view_state = TIME_VIEW then
                    run_time <= '0'; 
                else
                    run_time <= '1';
                end if;
                
                set_en   <= '1'; 
                set_hh   <= up_btn or down_btn;
                 
            when S_MM => 
                -- Halt time counting ONLY if modifying the main time
                if view_state = TIME_VIEW then
                    run_time <= '0'; 
                else
                    run_time <= '1';
                end if;
                
                set_en   <= '1'; 
                set_mm   <= up_btn or down_btn;
        end case;
    end process p_output_logic;

end Behavioral;
