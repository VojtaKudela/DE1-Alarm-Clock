----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Lukáš Katròák, Vojtìch Kudela
-- Copyright (c) 2026 Lukáš Katròák, Vojtìch Kudela, MIT license
-- 
-- Create Date: 23.04.2026 15:22:16
-- Design Name: display_driver
-- Module Name: display_driver - Behavioral
-- Project Name: Alarm_clock
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- This module implements a multiplexed 7-segment display driver.
-- It switches between displaying current time and alarm settings
-- based on the selected view mode. It also handles a blinking
-- decimal point for time indication.
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


entity display_driver is
    port (
        clk       : in  std_logic;                     -- Main system clock
        rst       : in  std_logic;                     -- High-active synchronous reset

        -- Binary time inputs
        curr_hh   : in  std_logic_vector(4 downto 0);  -- Current hours (0-23)
        curr_mm   : in  std_logic_vector(5 downto 0);  -- Current minutes (0-59)

        -- Binary alarm inputs
        alarm_hh  : in  std_logic_vector(4 downto 0);  -- Alarm hours
        alarm_mm  : in  std_logic_vector(5 downto 0);  -- Alarm minutes

        -- Display control
        view_mode : in  std_logic_vector(1 downto 0);  -- Selects time / alarm views
        set_en    : in  std_logic;                     -- Indicates setting mode

        -- Physical display outputs
        seg_o     : out std_logic_vector(6 downto 0);  -- Segment lines (a-g)
        dig_o     : out std_logic_vector(7 downto 0);  -- Digit enable lines
        dp_o      : out std_logic                      -- Decimal point
    );
end entity display_driver;

-------------------------------------------------
-- Display Driver Architecture
-------------------------------------------------
architecture Behavioral of display_driver is

    -------------------------------------------------
    -- Component Declarations
    -- External reusable modules instantiated below
    -------------------------------------------------
    component clk_en is
        generic (
            G_MAX : positive                          -- Clock division factor
        );
        port (
            clk : in  std_logic;
            rst : in  std_logic;
            ce  : out std_logic                       -- Enable pulse output
        );
    end component;

    component cnt_up_down is
        generic (
            g_CNT_WIDTH : natural
        );
        port (
            clk    : in  std_logic;
            rst    : in  std_logic;
            en     : in  std_logic;
            cnt_up : in  std_logic;
            cnt    : out std_logic_vector(g_CNT_WIDTH-1 downto 0)
        );
    end component;

    component bin2seg is
        port (
            clear : in  std_logic;                    -- Reset input
            bin   : in  std_logic_vector(4 downto 0); -- Numeric symbol
            seg   : out std_logic_vector(6 downto 0)  -- Segment control
        );
    end component;

    -------------------------------------------------
    -- Internal Signals
    -------------------------------------------------

    -- Clock enable pulses used as time bases
    signal sig_en_2ms       : std_logic;                -- Digit switching
    signal sig_en_500ms     : std_logic;                -- Blink timing

    -- Multiplexing support
    signal sig_cnt_3b       : std_logic_vector(2 downto 0); -- Digit index
    signal sig_hex          : std_logic_vector(4 downto 0); -- Active digit value

    -- Individual digit storage
    -- Convention: d0 = rightmost digit, d7 = leftmost digit
    signal d0, d1, d2, d3   : std_logic_vector(4 downto 0);
    signal d4, d5, d6, d7   : std_logic_vector(4 downto 0);

    -- Decimal point logic
    signal blink_toggle     : std_logic := '0';         -- Internal blink state
    signal internal_dp_ctrl : std_logic;                -- Final DP control

begin

    -------------------------------------------------
    -- 1. Clock Enable Generators
    -- Produce slower timing pulses derived from clk
    -------------------------------------------------

    -- ~2 ms pulse: ensures fast but flicker-free multiplexing
    CLK_EN_MUX : clk_en
        generic map (
            G_MAX => 200_000
        )
        port map (
            clk => clk,
            rst => rst,
            ce  => sig_en_2ms
        );

    -- ~500 ms pulse: human-visible blinking interval
    CLK_EN_BLINK : clk_en
        generic map (
            G_MAX => 50_000_000
        )
        port map (
            clk => clk,
            rst => rst,
            ce  => sig_en_500ms
        );

    -------------------------------------------------
    -- 2. Decimal Point Blinking Logic
    -- Toggles state periodically to create a blink
    -------------------------------------------------
    p_blink : process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                blink_toggle <= '0';                    -- Known start state
            elsif sig_en_500ms = '1' then
                blink_toggle <= not blink_toggle;       -- Toggle on pulse
            end if;
        end if;
    end process p_blink;

    -- Decimal point blinks ONLY in normal time view
    -- and remains steady during setup or alarm views
    internal_dp_ctrl <= blink_toggle
                        when (view_mode = "00" and set_en = '0')
                        else '1';

    -------------------------------------------------
    -- 3. Digit Value Assembly
    -- Converts binary values to individual digits
    -------------------------------------------------
    p_digits : process (view_mode, curr_hh, curr_mm, alarm_hh, alarm_mm)
    begin
        -- Default assignment: blank most significant digits
        d7 <= "10000";
        d6 <= "10000";
        d5 <= "10000";
        d4 <= "10000";

        case view_mode is

            -- TIME VIEW: HH:MM
            when "00" =>
                -- Static text "Hod"
                d7 <= "01101";  -- H
                d6 <= "01110";  -- o
                d5 <= "01111";  -- d
                -- d4 <= "01100";  -- _
                -- Hours tens and units
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_hh)) mod 10, 5));

                -- Minutes tens and units
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(curr_mm)) mod 10, 5));

            -- ALARM 1 VIEW
            when "01" =>
                -- Static text "AL_1"
                d7 <= "01010";  -- A
                d6 <= "01011";  -- L
                d5 <= "01100";  -- _
                d4 <= "00001";  -- index

                -- Alarm time digits
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) mod 10, 5));

            -- ALARM 2 VIEW
            when "10" =>
                d7 <= "01010"; -- A
                d6 <= "01011"; -- L
                d5 <= "01100"; -- _
                d4 <= "00010"; -- index
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) mod 10, 5));

            -- ALARM 3 VIEW
            when "11" =>
                d7 <= "01010"; -- A
                d6 <= "01011"; -- L
                d5 <= "01100"; -- _
                d4 <= "00011"; -- index
                d3 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) / 10, 5));
                d2 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_hh)) mod 10, 5));
                d1 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) / 10, 5));
                d0 <= std_logic_vector(to_unsigned(to_integer(unsigned(alarm_mm)) mod 10, 5));

            -- Fallback safety case
            when others =>
                d3 <= "10000";
                d2 <= "10000";
                d1 <= "10000";
                d0 <= "10000";
        end case;
    end process p_digits;

    -------------------------------------------------
    -- 4. Digit Counter and Segment Decoder
    -------------------------------------------------
    DIGIT_CNT : cnt_up_down
        generic map (
            g_CNT_WIDTH => 3
        )
        port map (
            clk    => clk,
            rst    => rst,
            en     => sig_en_2ms,
            cnt_up => '0',           -- Fixed direction (cyclic)
            cnt    => sig_cnt_3b
        );

    -- Converts selected digit into segment pattern
    B2S : bin2seg
        port map (
            clear => rst,
            bin   => sig_hex,
            seg   => seg_o
        );

    -------------------------------------------------
    -- 5. Multiplexing Logic
    -- Selects one digit at a time based on sig_cnt_3b
    -------------------------------------------------
    p_mux : process (
        sig_cnt_3b, d0, d1, d2, d3, d4, d5, d6, d7, internal_dp_ctrl
    )
    begin
        case sig_cnt_3b is
            when "111" =>
                sig_hex <= d7; 
                dig_o <= "01111111"; 
                dp_o <= '1';
            when "110" =>
                sig_hex <= d6; 
                dig_o <= "10111111"; 
                dp_o <= '1';
            when "101" =>
                sig_hex <= d5; 
                dig_o <= "11011111"; 
                dp_o <= '1';
            when "100" =>
                sig_hex <= d4; 
                dig_o <= "11101111"; 
                dp_o <= '1';
            when "011" =>
                sig_hex <= d3; 
                dig_o <= "11110111"; 
                dp_o <= '1';
            when "010" =>
                -- Middle separator (colon position)
                sig_hex <= d2; 
                dig_o <= "11111011";
                dp_o    <= not internal_dp_ctrl;
            when "001" =>
                sig_hex <= d1; 
                dig_o <= "11111101"; 
                dp_o <= '1';
            when others =>
                sig_hex <= d0; 
                dig_o <= "11111110"; 
                dp_o <= '1';
        end case;
    end process p_mux;

end Behavioral;
